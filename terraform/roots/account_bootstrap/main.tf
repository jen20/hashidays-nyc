provider "aws" {
    region = "us-west-2"
}

terraform {
    backend "s3" {
        key = "bootstrap/terraform.tfstate"
        region = "us-west-2"
    }
}

module "bootstrap" {
    source = "../../modules/bootstrap/"

    aws_region = "us-west-2"
    environment_name = "HashiStack AWS Staging"
}

resource "aws_route53_zone" "external" {
    name = "hashistack.gentec-systems.com"
    comment = "Public zone for hashistack.gentec-systems.com. Managed by Terraform."
}

output "hosted_zone_id" {
	value = "${aws_route53_zone.external.hosted_zone_id}"
}

output "tls_key_bucket_name" {
	value = "${module.bootstrap.tls_key_bucket_name}"
}

output "tls_key_bucket_arn" {
	value = "${module.bootstrap.tls_key_bucket_arn}"
}

output "openvpn_tls_kms_key_arn" {
	value = "${module.bootstrap.openvpn_tls_kms_key_arn}"
}

output "openvpn_tls_kms_key_id" {
	value = "${module.bootstrap.openvpn_tls_kms_key_id}"
}

output "vault_tls_kms_key_arn" {
	value = "${module.bootstrap.vault_tls_kms_key_arn}"
}

output "vault_tls_kms_key_id" {
	value = "${module.bootstrap.vault_tls_kms_key_id}"
}

output "hashistack_tls_kms_key_arn" {
	value = "${module.bootstrap.hashistack_tls_kms_key_arn}"
}

output "hashistack_tls_kms_key_id" {
	value = "${module.bootstrap.hashistack_tls_kms_key_id}"
}

output "backup_bucket_arn" {
	value = "${module.bootstrap.backup_bucket_arn}"
}

output "backup_bucket_name" {
	value = "${module.bootstrap.backup_bucket_name}"
}

output "log_bucket_arn" {
	value = "${module.bootstrap.log_bucket_arn}"
}

output "log_bucket_name" {
	value = "${module.bootstrap.log_bucket_name}"
}

