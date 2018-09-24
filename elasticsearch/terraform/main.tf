resource "aws_launch_configuration" "elasticsearch" {
  name_prefix                 = "${var.service_name}-${var.environment}-elasticsearch-"
  image_id                    = "${data.aws_ami.elasticsearch_ami.id}"
  instance_type               = "${var.elasticsearch_instance_type}"
  security_groups             = ["${aws_security_group.elasticsearch.id}"]
  associate_public_ip_address = false

  # use EBS optimized instances unless launching at t2 instance
  ebs_optimized        = "${format("%.1s", var.elasticsearch_instance_type) == "t" ? false : true}"
  key_name             = "${var.ssh_key_name}"
  user_data            = "${data.template_cloudinit_config.cloud_init.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.elasticsearch.arn}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = "${var.elasticsearch_root_volume_size}"
    volume_type = "gp2"
  }

  ebs_block_device = [{
    device_name = "/dev/sdb"
    volume_size = "${var.elasticsearch_data_volume_size}"
    volume_type = "gp2"
  },
    {
      device_name = "/dev/sdc"
      volume_size = "${var.elasticsearch_log_volume_size}"
      volume_type = "gp2"
    },
  ]
}

resource "aws_autoscaling_group" "elasticsearch" {
  name                 = "${var.service_name}-${var.environment}-elasticsearch"
  max_size             = "${var.elasticsearch_max_instances}"
  min_size             = "${var.elasticsearch_min_instances}"
  desired_capacity     = "${var.elasticsearch_desired_instances}"
  default_cooldown     = 30
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.elasticsearch.id}"
  vpc_zone_identifier  = ["${data.aws_subnet_ids.all_subnets.ids}"]
  load_balancers       = ["${aws_elb.elasticsearch_elb.id}"]

  tag {
    key                 = "Name"
    value               = "${var.service_name}-${var.environment}-elasticsearch"
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = "${var.service_name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
