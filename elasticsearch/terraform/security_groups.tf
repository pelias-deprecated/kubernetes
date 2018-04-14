resource "aws_security_group" "elasticsearch" {
  name        = "${var.service_name}-${var.environment}-elasticsearch"
  description = "Elasticsearch ports with ssh"
  vpc_id      = "${var.aws_vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_ip_range}"]
  }

  # elasticsearch main port is only accessible by the ELB
  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elasticsearch_elb.id}"]
  }

  # elasticsearch coordination port is only accessible from this security group
  ingress {
    from_port = 9300
    to_port   = 9300
    protocol  = "tcp"
    self      = true
  }

  # all outbound traffic is allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elasticsearch_elb" {
  name        = "${var.service_name}-${var.environment}-elasticsearch_elb"
  description = "ElasticSearch Elastic Load Balancer Security Group"
  vpc_id      = "${var.aws_vpc_id}"

  # this is an internal only ELB, so only allow access from within EC2
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ElasticSearch Load Balancer"
  }
}
