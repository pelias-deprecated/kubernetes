resource "aws_security_group" "elasticsearch" {
  /*name = "${var.security_group_name}-elasticsearch"*/
  description = "Elasticsearch ports with ssh"
  vpc_id = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.internal_cidr_blocks)}"]
  }

  # elastic ports from anywhere.. we are using private ips so shouldn't
  # have people deleting our indexes just yet
  ingress {
    from_port = 9200
    to_port = 9400
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.internal_cidr_blocks)}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.es_cluster}-elasticsearch"
    stream = "${var.stream_tag}"
    cluster = "${var.es_cluster}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elasticsearch_elb" {
  name = "elasticsearch-elb-sg"
  description = "ElasticSearch Elastic Load Balancer Security Group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 9200
    to_port   = 9200
    protocol  = "tcp"
    security_groups = ["${aws_security_group.node.id}"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ElasticSearch Load Balancer"
  }
}

