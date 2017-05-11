variable "bucket_name" {
    type = "string"
}

resource "aws_s3_bucket" "state" {
	bucket = "${var.bucket_name}"
	acl = "private"

	tags {
		Name = "Terraform Remote State"
	}

    versioning {
        enabled = true
    }
}

output "bucket_arn"  {
    value = "${aws_s3_bucket.state.arn}"
}
