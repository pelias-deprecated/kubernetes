data "template_file" "setup" {
  template = "${file("${path.module}/templates/setup.sh.tpl")}"

  vars {
    elasticsearch_data_dir            = "${var.elasticsearch_data_dir}"
    elasticsearch_log_dir             = "${var.elasticsearch_log_dir}"
    es_cluster_name                   = "${var.service_name}-${var.environment}-elasticsearch"
    es_allowed_urls                   = "${var.es_allowed_urls}"
    aws_security_group                = "${aws_security_group.elasticsearch.id}"
    aws_region                        = "${var.aws_region}"
    availability_zones                = "${var.availability_zones}"
    expected_nodes                    = "${var.elasticsearch_desired_instances}"
    minimum_master_nodes              = "${var.elasticsearch_desired_instances/2 + 1}"
    elasticsearch_heap_memory_percent = "${var.elasticsearch_heap_memory_percent}"
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.setup.rendered}"
  }
}
