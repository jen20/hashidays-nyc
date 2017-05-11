resource "aws_s3_bucket" "repo" {
	bucket = "${var.bucket_name}"
	acl = "private"

	tags {
		Name = "${var.repo_name}"
	}

	website {
		index_document = "${var.index_document}"
	}
}

data "aws_iam_policy_document" "repo" {
	statement {
		sid = "AllowReadFromVPC"
		effect = "Allow"
		principals {
			type = "AWS"
			identifiers = ["*"]
		}
		actions = ["s3:GetObject"]
		resources = [
			"${aws_s3_bucket.repo.arn}",
			"${aws_s3_bucket.repo.arn}/*"
		]
		condition {
			test = "StringEquals"
			variable = "aws:sourceVpc"
			values = ["${var.vpc_id}"]
		}
	}
}

resource "aws_s3_bucket_policy" "repo" {
	bucket = "${aws_s3_bucket.repo.bucket}"
	policy = "${data.aws_iam_policy_document.repo.json}"
}
