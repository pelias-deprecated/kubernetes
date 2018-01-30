resource "aws_iam_role" "elasticsearch" {
  name               = "${var.service_name}-${var.environment}-elasticsearch-discovery-role"
  assume_role_policy = "${file("${path.module}/policies/role.json")}"
}

resource "aws_iam_instance_profile" "elasticsearch" {
  name = "${var.service_name}-${var.environment}-elasticsearch-discovery-profile"
  path = "/"
  role = "${aws_iam_role.elasticsearch.name}"
}

# discovery policy
resource "aws_iam_role_policy" "elasticsearch" {
  name   = "${var.service_name}-${var.environment}-elasticsearch-discovery-policy"
  policy = "${file("${path.module}/policies/policy.json")}"
  role   = "${aws_iam_role.elasticsearch.id}"
}

data "template_file" "s3_policy" {
  template = "${file("${path.module}/templates/s3_policy.json.tpl")}"

  vars {
    snapshot_s3_bucket_arn = "${var.snapshot_s3_bucket_arn}"
  }
}

# S3
resource "aws_iam_role_policy" "elasticsearch_s3" {
  name   = "${var.service_name}-${var.environment}-elasticsearch-s3-policy"
  policy = "${data.template_file.s3_policy.rendered}"
  role   = "${aws_iam_role.elasticsearch.id}"
}
