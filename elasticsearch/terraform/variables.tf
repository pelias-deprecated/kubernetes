## AWS Gobal settings

variable "ssh_key_name" {
  description = "Name of AWS key pair"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "AWS region to launch servers."
  default     = "us-east-1a,us-east-1b,us-east-1c,us-east-1d,us-east-1e"
}

variable "aws_vpc_id" {
  description = "These templates assume a VPC already exists"
}

variable "subnet_name_filter" {
  description = "Filter subnets within the VPC by using this name"
  default     = "Elasticsearch"
}

# security settings
variable "ssh_ip_range" {
  description = "Range of IPs able to SSH into the Elasticsearch nodes"
  default = "0.0.0.0/0"
}

# Autoscaling Group Settings

# r4.xlarge is a good economic default for full planet builds
# for more performance, use c4.4xlarge or similar. High throughput
# geocoders really love having lots of CPU available
variable "elasticsearch_instance_type" {
  description = "Elasticsearch instance type."
  default     = "r4.xlarge"
}

# Elasticsearch ASG instance counts
# a minimum of 5 r4.xlarge instances is needed for a full planet build
variable "elasticsearch_min_instances" {
  description = "total instances"
  default     = "5"
}

variable "elasticsearch_desired_instances" {
  description = "total instances"
  default     = "5"
}

variable "elasticsearch_max_instances" {
  description = "total instances"
  default     = "5"
}

# higher values here tune elasticsearch for use on smaller clusters
# lower values give better performance if there is lots of RAM available
variable "elasticsearch_heap_memory_percent" {
  description = "Elasticsearch heap size as a percent of system RAM"
  default     = "60"
}

## Launch Configuration settings

variable "elasticsearch_root_volume_size" {
  default = "8"
}

variable "elasticsearch_data_volume_size" {
  default = "200"
}

variable "elasticsearch_log_volume_size" {
  default = "5"
}

# AMI Settings

variable "ami_env_tag_filter" {
  default = "production"
}

# elasticsearch.yml settings

variable "elasticsearch_data_dir" {
  default = "/usr/local/var/data/elasticsearch"
}

variable "elasticsearch_log_dir" {
  default = "/usr/local/var/log/elasticsearch"
}

variable "es_allowed_urls" {
  description = "List of URLs to allow creating snapshot repositories from"
  default     = ""
}

variable "elasticsearch_fielddata_limit" {
  description = "fielddata circuit breaker limit"
  default     = "30%"
}

## snapshot loading settings
variable "snapshot_s3_bucket" {
  description = "The bucket where ES snapshots can be loaded from S3."
}

variable "snapshot_base_path" {
  description = "The path within the snapshot repository where the snapshot to load is found"
  default = ""
}

variable "snapshot_name" {
  description = "The name of the snapshot to load from S3. If blank, no snapshot will be loaded"
  default = ""
}

variable "snapshot_replica_count" {
  description = "The number of replicas to add to the loaded snapshot. Default 1"
  default = "1"
}

variable "snapshot_alias_name" {
  description = "The alias to give to the loaded snapshot. None made if blank"
  default = ""
}

variable "snapshot_repository_read_only" {
  description = "Whether the snapshot repository is read_only. Default true"
  default = "true"
}

# General settings
variable "service_name" {
  description = "Used as a prefix for all instances in case you are running several distinct services"
  default     = "pelias"
}

variable "environment" {
  description = "Which environment (dev, staging, prod, etc) this group of machines is for"
  default     = "dev"
}

variable "tags" {
  description = "Custom tags to add to all resources"
  default     = {}
}

variable "elb" {
  description = "Whether or not to launch an ELB"
  default     = true
}
