variable "aws_region" {
	type = "string"
}

variable "environment_name" {
	type = "string"
}



output "backup_bucket_arn" {
	value = "${aws_s3_bucket.backup.arn}"
}

output "backup_bucket_name" {
	value = "${aws_s3_bucket.backup.bucket}"
}

output "hashistack_tls_kms_key_arn" {
	value = "${aws_kms_key.hashistack_tls_keys.arn}"
}

output "hashistack_tls_kms_key_id" {
	value = "${aws_kms_key.hashistack_tls_keys.key_id}"
}

output "log_bucket_arn" {
	value = "${aws_s3_bucket.log.arn}"
}

output "log_bucket_name" {
	value = "${aws_s3_bucket.log.bucket}"
}

output "openvpn_tls_kms_key_arn" {
	value = "${aws_kms_key.openvpn_tls_keys.arn}"
}

output "openvpn_tls_kms_key_id" {
	value = "${aws_kms_key.openvpn_tls_keys.key_id}"
}

output "tls_key_bucket_name" {
	value = "${aws_s3_bucket.tls_keys.bucket}"
}

output "tls_key_bucket_arn" {
	value = "${aws_s3_bucket.tls_keys.arn}"
}

output "vault_tls_kms_key_arn" {
	value = "${aws_kms_key.vault_tls_keys.arn}"
}

output "vault_tls_kms_key_id" {
	value = "${aws_kms_key.vault_tls_keys.key_id}"
}
