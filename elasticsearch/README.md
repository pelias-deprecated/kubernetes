# Elasticsearch Configuration

Elasticsearch is a database that definitely should not live in Kubernetes, so we use Terraform and Packer to manage setting it up.

Before doing anything in this directory, set up the Kubernetes cluster running the rest of the services you'll want.

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

#### Create an access key

Once the terraform user has been set up, create an access key and keep the credentials handy for the next section

## Create Packer images

Packer images are used to avoid lengthy startup times when launching new Elasticsearch instances.

Within the packer directory, create a file called `variables.json` and fill it in using the following template:

```
{
  "elasticsearch_version": "2.4.6"
  "aws_access_key": "<terraform user access key here>",
  "aws_secret_key": "<terraform user secret key here>"
}
```

Then, run packer using the following command:
```
packer build -var-file=variables.json pelias-elasticsearch.json
```

In under 5 minutes Packer should have built an AMI. The Terraform scripts are automatically configured to find it, so we are now done with packer.

### Set up Terraform

Terraform will require similar configuration before we start. Create a file in the terraform directory called `terraform.tfvars` and fill it using the following template

```
ssh_key_name = "<the name of the SSH key pair you have configured in AWS, so you can SSH into instances>"
aws_access_key = "<terraform user access key>"
aws_secret_key = "<terraform user secret key>"
aws_vpc_id = "<Kubernetes cluster VPC id>"
```

What's the VPC ID? Kops creates all instances for the Kubernetes cluster within a [Virtual Private Cloud](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) to isolate them from all other EC2 instances. We will need to tell terraform to create the Elasticsearch instances in the same VPC. It can be found by going to the [AWS VPC Dashboard](https://console.aws.amazon.com/vpc/home) and finding the VPC matching the Kubernetes cluster created by Kops.

### Create Elasticsearch cluster with terraform

All that should be needed to create everything required for elasticsearch is to run the following:

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

Copy the DNS name from the Terraform output, and use it to replace the elasticsearchHost value in the Kubernetes chart.

Update the chart with `helm update pelias ./pelias/kubernetes -f yourValues.yaml` or similar, and new API instances with the correct settings will automatically be launched.


## Thanks

Thanks to the following sources for inspiration and code:

http://www.paulstack.co.uk/blog/2016/01/02/building-an-elasticsearch-cluster-in-aws-with-packer-and-terraform/
https://github.com/nadnerb/terraform-elasticsearch
https://github.com/floragunncom/packer-elasticsearch/blob/master/elastic.json
