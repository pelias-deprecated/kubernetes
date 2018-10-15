output "aws_elb" {
  value = "${aws_elb.elasticsearch_elb.*.dns_name}"
}
