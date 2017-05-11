resource "aws_s3_bucket" "repo_stage" {
	count = "${var.include_stage}"

	bucket = "${var.stage_bucket_name}"
	acl = "private"

	tags {
		Name = "${var.repo_name} Stage"
	}
}
