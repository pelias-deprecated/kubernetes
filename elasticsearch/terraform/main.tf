data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.tpl")}"

  vars {
    data_volume_name                  = "${var.elasticsearch_data_volume_name}"
    log_volume_name                   = "${var.elasticsearch_log_volume_name}"
    elasticsearch_data_dir            = "${var.elasticsearch_data_dir}"
    elasticsearch_log_dir             = "${var.elasticsearch_log_dir}"
    es_cluster_name                   = "${var.service_name}-${var.environment}-elasticsearch"
    es_allowed_urls                   = "${var.es_allowed_urls}"
    aws_security_group                = "${aws_security_group.elasticsearch.id}"
    aws_region                        = "${var.aws_region}"
    expected_nodes                    = "${var.elasticsearch_desired_instances}"
    minimum_master_nodes              = "${var.elasticsearch_desired_instances/2 + 1}"
    elasticsearch_heap_memory_percent = "${var.elasticsearch_heap_memory_percent}"
  }
}

resource "aws_launch_configuration" "elasticsearch" {
  name_prefix                 = "${var.service_name}-${var.environment}-elasticsearch-"
  image_id                    = "${data.aws_ami.elasticsearch_ami.id}"
  instance_type               = "${var.elasticsearch_instance_type}"
  security_groups             = ["${aws_security_group.elasticsearch.id}"]
  associate_public_ip_address = true

  # use EBS optimized instances unless launching at t2 instance
  ebs_optimized        = "${format("%.1s", var.elasticsearch_instance_type) == "t" ? false : true}"
  key_name             = "${var.ssh_key_name}"
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.elasticsearch.arn}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = "${var.elasticsearch_root_volume_size}"
    volume_type = "gp2"
  }

  # ebs volumes appear on the instance as /dev/xvdX, but must be specified
  # in the launch configuration as /dev/sdX. this is annoying, there must be a better way
  ebs_block_device = [{
    device_name = "${replace(var.elasticsearch_data_volume_name,"/xvd/","sd")}"
    volume_size = "${var.elasticsearch_data_volume_size}"
    volume_type = "gp2"
  },
    {
      device_name = "${replace(var.elasticsearch_log_volume_name,"/xvd/","sd")}"
      volume_size = "${var.elasticsearch_log_volume_size}"
      volume_type = "gp2"
    },
  ]
}

resource "aws_autoscaling_group" "elasticsearch" {
  name                 = "${aws_launch_configuration.elasticsearch.name}"
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
