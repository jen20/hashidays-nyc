resource "tls_private_key" "root" {
	algorithm = "RSA"
	rsa_bits = "2048"
}

resource "tls_self_signed_cert" "root" {
	key_algorithm = "${tls_private_key.root.algorithm}"
	private_key_pem = "${tls_private_key.root.private_key_pem}"

	validity_period_hours = 87600
	early_renewal_hours = 8760

	is_ca_certificate = true

	allowed_uses = ["cert_signing"]

	subject {
		common_name = "HashiStack Nomad Root CA"
		organization = "Operator Error"
		organizational_unit = "Operations"
	}
}
