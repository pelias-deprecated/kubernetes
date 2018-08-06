# Elasticsearch Configuration

Elasticsearch is a database that definitely should not live in Kubernetes, so we use Terraform and Packer to manage setting it up.

This directory contains a Terraform module that sets up an Elasticsearch cluster suitable for usage in a full-planet, production ready Pelias install. It can of course also be used for smaller installations.

## Setup instructions

### Create a terraform user

Terraform will need an AWS IAM user account that has permissions to create all the resources needed.

#### Set up Permissions

The Terraform user will need the `AmazonEC2FullAccess` policy attached, as well as IAM permissions.

For IAM permissions the `IAMFullAccess` policy can be used, or for more fine grained control, use this policy document:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1498231117000",
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:AttachRolePolicy",
                "iam:AttachUserPolicy",
                "iam:CreateRole",
                "iam:UpdateAssumeRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:DeleteRole",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:CreatePolicy",
                "iam:DetachRolePolicy",
                "iam:DeletePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListPolicyVersions",
                "iam:DeletePolicyVersion",
                "iam:GetRole",
                "iam:PutRolePolicy",
                "iam:GetRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:PassRole"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

#### Suggested: Set up AWS credentials file

Once the AWS user has credentials, they need to be usable.

The easiest way to use AWS credentials is to put them in `~/.aws/credentials`. This file even supports several accounts which is quite nice:

```
cat ~/.aws/credentials
[default]
aws_access_key_id = defaultKey
aws_secret_access_key = defaultSecret
region = us-east-1
output = json
[site1]
aws_access_key_id = key1
aws_secret_access_key = secret1
region = us-east-1
output = json
[site2]
aws_access_key_id     = key2
aws_secret_access_key = secret2
region = us-east-1
output = json
```

Now, different keys can be selected with `export AWS_PROFILE=site1`. Run that command before anything below and the credentials will be picked up automatically.


Once the terraform user has been set up, create an access key and keep the credentials handy for the next section

## Create Packer images

Packer images are used to avoid lengthy startup times when launching new Elasticsearch instances.

Within the packer directory, create a file called `variables.json` and fill it in using the following template:

```
{
  "elasticsearch_version": "2.4.6"
}
```

Then, run packer using the following command:
```
packer build -var-file=variables.json pelias-elasticsearch.json
```

In under 5 minutes Packer should have built an AMI. The Terraform scripts are automatically configured to find it, so we are now done with packer.

### Set up Terraform Module configuration

While it can be run directly, this directory's code is best used as a [Terraform module](https://www.terraform.io/intro/getting-started/modules.html).

Create a file, for example `elasticsearch.tf`, with contents like the following:

```hcl
module "elasticsearch-prod-a" {
	source = "github.com/pelias/kubernetes//elasticsearch/terraform?ref=v1.5.2"

	aws_vpc_id   = "vpc-1234" # the ID of an existing VPC in which to create the instances
	ssh_key_name = "ssh-key-to-use"

	environment                       = "dev" # or whatever unique environment you choose
	snapshot_s3_bucket_arn            = "arn:aws:s3:::pelias-elasticsearch.nextzen.org"
	elasticsearch_max_instances       = 4 # 4 r4.xlarge instances is suitable for a minimal full-planet production build with replicas
	elasticsearch_min_instances       = 4
	elasticsearch_desired_instances   = 4
	elasticsearch_data_volume_size    = 300
	elasticsearch_instance_type       = "r4.xlarge"
	elasticsearch_heap_memory_percent = 50
	ssh_ip_range                      = "172.20.0.0/16" # adjust this if you'd like SSH access to be limited, or remove if you don't want that
	ami_env_tag_filter                = "prod" # this variable can be adjusted if you tag your AMIs differently
	subnet_name_filter                = "us-east-*"
}
```

Adjust any variables for your use case.


### Create Elasticsearch cluster with terraform

All that should be needed to create everything required for elasticsearch is to run the following:

```
terraform init
```

for initializig Terraform and fetching the module code, and then

```
terraform apply
```

Once that's done, it will print out the DNS name of the load balancer used to access Elasticsearch:

Here's some example output
```
Outputs:

aws_elb = internal-search-dev-elasticsearch-elb-XXXXXXXX.us-east-1.elb.amazonaws.com
```


### Add Elasticsearch Load Balancer to Kubernetes Cluster

If using this code with the Helm chart in this repository, this section is useful.

Copy the DNS name from the Terraform output, and use it to replace the elasticsearchHost value in the Kubernetes chart.

Update the chart with `helm update pelias ./pelias/kubernetes -f yourValues.yaml` or similar, and new API instances with the correct settings will automatically be launched.


## Thanks

Thanks to the following sources for inspiration and code:

http://www.paulstack.co.uk/blog/2016/01/02/building-an-elasticsearch-cluster-in-aws-with-packer-and-terraform/
https://github.com/nadnerb/terraform-elasticsearch
https://github.com/floragunncom/packer-elasticsearch/blob/master/elastic.json
