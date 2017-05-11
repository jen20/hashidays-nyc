provider "aws" {
	region = "us-west-2"
}

variable "state_bucket" {
    type = "string"
}

terraform {
    backend "s3" {
        key = "apt_repo/terraform.tfstate"
        region = "us-west-2"
    }
}

data "terraform_remote_state" "vpc" {
	backend = "s3"
	config {
        bucket = "${var.state_bucket}"
        region = "us-west-2"
		key = "vpc/terraform.tfstate"
	}
}

module "apt" {
	source = "../../modules/repo"

	include_stage = "1"
	bucket_name = "apt.${data.terraform_remote_state.vpc.zone_name}"
	stage_bucket_name = "apt-hashistack-stage"
	repo_name = "HashiStack APT Repo"
    index_document = "apt.key"

	vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
	private_zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
	private_record_name = "apt"
}

output "bucket_arn" {
	value = "${module.apt.bucket_arn}"
}

output "bucket" {
    value = "${module.apt.bucket}"
}

output "stage_arn" {
	value = "${module.apt.stage_arn}"
}

output "stage" {
    value = "${module.apt.stage}"
}
