variable "vpc_id" {
	type = "string"
}

variable "vpc_zone_id" {
	type = "string"
}

variable "dns_name" {
	type = "string"
}

variable "tls_kms_arn" {
	type = "string"
}

variable "tls_key_bucket_arn" {
	type = "string"
}

variable "log_group_name" {
	type = "string"
}

variable "consul_tld" {
	type = "string"
}

variable "subnets" {
	type = "list"
}

variable "backup_bucket_name" {
	type = "string"
}

variable "backup_bucket_arn" {
	type = "string"
}

variable "cluster_size" {
	type = "string"
}

variable "cluster_name" {
	type = "string"
}

variable "ami" {
	type = "string"
}

variable "instance_type" {
	type = "string"
}

variable "consul_serf_key" {
	type = "string"
}

variable "tls_key_bucket_name" {
	type = "string"
}

output "asg_id" {
	value = "${aws_autoscaling_group.consul_server.id}"
}

output "asg_name" {
	value = "${aws_autoscaling_group.consul_server.name}"
}

output "consul_client_sg_id" {
	value = "${aws_security_group.consul_client.id}"
}
