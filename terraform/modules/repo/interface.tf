variable "bucket_name" {
	type = "string"
}

variable "include_stage" {
    type = "string"
}

variable "index_document" {
    type = "string"
}

variable "repo_name" {
	type = "string"
}

variable "private_zone_id" {
	type = "string"
}

variable "private_record_name" {
	type = "string"
}

variable "stage_bucket_name" {
    type = "string"
}

variable "vpc_id" {
	type = "string"
}

output "bucket_arn" {
	value = "${aws_s3_bucket.repo.arn}"
}

output "bucket" {
    value = "${aws_s3_bucket.repo.bucket}"
}

output "stage_arn" {
	value = "${aws_s3_bucket.repo_stage.arn}"
}

output "stage" {
    value = "${aws_s3_bucket.repo_stage.bucket}"
}
