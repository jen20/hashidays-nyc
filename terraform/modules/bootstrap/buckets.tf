resource "aws_s3_bucket" "log" {
	bucket = "${lower(replace(var.environment_name, " ", "-"))}-logs"
	acl = "private"

	tags {
		Name = "${var.environment_name} Logs"
	}
}

resource "aws_s3_bucket" "backup" {
	bucket = "${lower(replace(var.environment_name, " ", "-"))}-backups"
	acl = "private"

	tags {
		Name = "${var.environment_name} Backups"
	}
}

resource "aws_s3_bucket" "tls_keys" {
	bucket = "${lower(replace(var.environment_name, " ", "-"))}-tls-keys"
	acl = "private"

	tags {
		Name = "${var.environment_name} TLS Keys"
	}
}

resource "aws_kms_key" "openvpn_tls_keys" {
	description = "${var.environment_name} OpenVPN TLS Keys"
	deletion_window_in_days = 14
	policy = "${data.aws_iam_policy_document.tls_keys.json}"
}

resource "aws_kms_key" "vault_tls_keys" {
	description = "${var.environment_name} Vault TLS Keys"
	deletion_window_in_days = 14
	policy = "${data.aws_iam_policy_document.tls_keys.json}"
}

resource "aws_kms_key" "hashistack_tls_keys" {
	description = "${var.environment_name} HashiStack TLS Keys"
	deletion_window_in_days = 14
	policy = "${data.aws_iam_policy_document.tls_keys.json}"
}

data "aws_iam_policy_document" "tls_keys" {
	statement {
		sid = "Delegate Key Access to IAM"
		effect = "Allow"
		principals {
			type = "AWS"
			identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
		}
		actions = [
			"kms:*"
		]
		resources = ["*"]
	}
}

