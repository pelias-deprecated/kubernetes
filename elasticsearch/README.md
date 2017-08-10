# Elasticsearch Configuration

Elasticsearch is a database that definitely should not live in Kubernetes, so we use Terraform and Packer to manage setting it up.


Thanks to the following sources for inspiration and code:

http://www.paulstack.co.uk/blog/2016/01/02/building-an-elasticsearch-cluster-in-aws-with-packer-and-terraform/
https://github.com/nadnerb/terraform-elasticsearch
https://github.com/floragunncom/packer-elasticsearch/blob/master/elastic.json
