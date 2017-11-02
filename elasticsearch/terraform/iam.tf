resource "aws_iam_role" "elasticsearch" {
  name               = "${var.service_name}-${var.environment}-elasticsearch-discovery-role"
  assume_role_policy = "${file("${path.module}/policies/role.json")}"
}

resource "aws_iam_role_policy" "elasticsearch" {
  name   = "${var.service_name}-${var.environment}-elasticsearch-discovery-policy"
  policy = "${file("${path.module}/policies/policy.json")}"
  role   = "${aws_iam_role.elasticsearch.id}"
}

resource "aws_iam_instance_profile" "elasticsearch" {
  name = "${var.service_name}-${var.environment}-elasticsearch-discovery-profile"
  path = "/"
  role = "${aws_iam_role.elasticsearch.name}"
}
