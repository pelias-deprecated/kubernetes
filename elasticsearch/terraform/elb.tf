resource "aws_elb" "elasticsearch_elb" {
  name                      = "${var.service_name}-${var.environment}-es-elb"
  security_groups           = ["${aws_security_group.elasticsearch_elb.id}"]
  subnets                   = ["${data.aws_subnet_ids.all_subnets.ids}"]
  cross_zone_load_balancing = true
  connection_draining       = true
  internal                  = true

  tags = "${var.tags}"

  count = "${var.elb}"

  listener {
    instance_port     = 9200
    instance_protocol = "http"
    lb_port           = 9200
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    target              = "HTTP:9200/"
    timeout             = 5
  }
}
