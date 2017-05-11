provider "aws" {
	region = "us-west-2"
}

variable "state_bucket" {
    type = "string"
}

terraform {
    backend "s3" {
        key = "consul_servers/terraform.tfstate"
        region = "us-west-2"
    }
}

module "consul" {
	source = "../../modules/consul"

	cluster_name = "HashiStack"
	cluster_size = 3
	log_group_name = "ConsulServer"

	vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
	subnets = ["${data.terraform_remote_state.vpc.private_subnet_ids}"]
	ami = "${data.aws_ami.consul.id}"
	instance_type = "t2.medium"

	dns_name = "consul.${data.terraform_remote_state.vpc.private_zone_name}"
	vpc_zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"

	consul_tld = "consul"
	consul_serf_key = "${random_id.consul_serf_key.b64_std}"

	tls_key_bucket_name = "${data.terraform_remote_state.bootstrap.tls_key_bucket_name}"
	tls_key_bucket_arn = "${data.terraform_remote_state.bootstrap.tls_key_bucket_arn}"
	tls_kms_arn = "${data.terraform_remote_state.bootstrap.hashistack_tls_kms_key_arn}"

	backup_bucket_arn = "${data.terraform_remote_state.bootstrap.backup_bucket_arn}"
	backup_bucket_name = "${data.terraform_remote_state.bootstrap.backup_bucket_name}"
}

module "asg_dns" {
	source = "../../modules/asg-route53"

	asg_name = "${module.consul.asg_name}"
	region = "us-west-2"
}

data "terraform_remote_state" "vpc" {
	backend = "s3"
	config {
        bucket = "${var.state_bucket}"
		region = "us-west-2"
        key = "vpc/terraform.tfstate"
	}
}

data "terraform_remote_state" "bootstrap" {
	backend = "s3"
	config {
        bucket = "${var.state_bucket}"
		region = "us-west-2"
        key = "bootstrap/terraform.tfstate"
	}
}

data "aws_ami" "consul" {
	most_recent = true
	owners      = ["self"]

	filter {
		name   = "tag:Component"
		values = ["ConsulServer"]
	}

	filter {
		name   = "tag:OS"
		values = ["Ubuntu-16.04"]
	}
}

resource "random_id" "consul_serf_key" {
	byte_length = 16
}

output "asg_id" {
	value = "${module.consul.asg_id}"
}

output "consul_client_sg" {
	value = "${module.consul.consul_client_sg_id}"
}

