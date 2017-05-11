output "root_cert" {
	value = "${tls_self_signed_cert.root.cert_pem}"
}

output "intermediate_cert" {
	value= "${tls_locally_signed_cert.intermediate.cert_pem}"
}

output "server_cert" {
	value = "${tls_locally_signed_cert.server.cert_pem}"
}

output "server_key" {
	sensitive = true
	value = "${tls_private_key.server.private_key_pem}"
}
