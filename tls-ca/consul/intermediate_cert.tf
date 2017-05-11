resource "tls_private_key" "intermediate" {
	algorithm = "RSA"
	rsa_bits = "2048"
}

resource "tls_cert_request" "intermediate" {
	key_algorithm = "${tls_private_key.intermediate.algorithm}"
	private_key_pem = "${tls_private_key.intermediate.private_key_pem}"

	subject {
		common_name = "HashiStack Consul Intermediate CA"
		organization = "Operator Error"
		organizational_unit = "Operations"
	}
}

resource "tls_locally_signed_cert" "intermediate" {
	cert_request_pem = "${tls_cert_request.intermediate.cert_request_pem}"

	ca_key_algorithm = "${tls_private_key.root.algorithm}"
	ca_private_key_pem = "${tls_private_key.root.private_key_pem}"
	ca_cert_pem = "${tls_self_signed_cert.root.cert_pem}"

	validity_period_hours = 17520
	early_renewal_hours = 8760

	is_ca_certificate = true

	allowed_uses = ["cert_signing"]
}
