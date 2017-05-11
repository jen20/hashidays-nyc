resource "aws_cloudtrail" "audit" {
	name = "Audit"
	s3_bucket_name = "${aws_s3_bucket.cloudtrail.bucket}"
	is_multi_region_trail = true
	enable_log_file_validation = true
	
	tags {
		Name = "${var.environment_name} CloudTrail"
	}

	depends_on = ["aws_s3_bucket_policy.cloudtrail"]
}

resource "aws_s3_bucket" "cloudtrail" {
	bucket = "${lower(replace(var.environment_name, " ", "-"))}-cloudtrail"

	tags {
		Name = "${var.environment_name} CloudTrail"
	}
}

resource "aws_s3_bucket_policy" "cloudtrail" {
	bucket = "${aws_s3_bucket.cloudtrail.bucket}"
	policy = "${data.aws_iam_policy_document.cloudtrail_bucket.json}"
}

data "aws_iam_policy_document" "cloudtrail_bucket" {
	statement {
		sid = "AWSCloudTrailAclCheck20150319"
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["cloudtrail.amazonaws.com"]
		}
		actions = [
			"s3:GetBucketAcl"
		]
		resources = [
			"${aws_s3_bucket.cloudtrail.arn}"
		]
	}

	statement {
		sid = "AWSCloudTrailWrite20150319"
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["cloudtrail.amazonaws.com"]
		}
		actions = [
			"s3:PutObject"
		]
		resources = [
			"${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
		]
		condition {
			test = "StringEquals"
			variable = "s3:x-amz-acl"
			values = ["bucket-owner-full-control"]
		}
	}
}
