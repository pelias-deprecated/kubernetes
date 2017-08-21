resource "aws_elb" "elasticsearch_elb" {
  name = "${var.service_name}-${var.environment}-elasticsearch-elb"
  security_groups = ["${aws_security_group.elasticsearch_elb.id}"]
  subnets = ["${data.aws_subnet_ids.all_subnets.ids}"]
  cross_zone_load_balancing = true
  connection_draining = true
  internal = true

  listener {
    instance_port      = 9200
    instance_protocol  = "tcp"
    lb_port            = 9200
    lb_protocol        = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    target              = "TCP:9200"
    timeout             = 5
  }
}

