provider "aws" {
	region = "us-west-2"
}

terraform {
    backend "s3" {
        key = "vpc/terraform.tfstate"
        region = "us-west-2"
    }
}

variable "vpc_name" {
	type = "string"
	default = "HashiStack VPC"
}

variable "zone_name" {
	type = "string"
	default = "hashistack.gentec-systems.com"
}

variable "cidr_block" {
	type = "string"
	default = "172.21.0.0/16"
}

data "aws_availability_zones" "zones" {}

module "vpc" {
	source = "../../modules/vpc"

	vpc_name  = "${var.vpc_name}"
	zone_name = "${var.zone_name}"
    region = "us-west-2"

	cidr_block = "${var.cidr_block}"
	
	private_subnets = [
		"${cidrsubnet(var.cidr_block, 3, 5)}",
		"${cidrsubnet(var.cidr_block, 3, 6)}",
		"${cidrsubnet(var.cidr_block, 3, 7)}"
	]
	
	public_subnets = [
		"${cidrsubnet(var.cidr_block, 5, 0)}",
		"${cidrsubnet(var.cidr_block, 5, 1)}",
		"${cidrsubnet(var.cidr_block, 5, 2)}"
	]

	availability_zones = ["${data.aws_availability_zones.zones.names}"]
}

output "private_subnet_ids" {
	value = ["${module.vpc.private_subnets}"]
}

output "public_subnet_ids" {
	value = ["${module.vpc.public_subnets}"]
}

output "private_availability_zones" {
	value = ["${module.vpc.private_availability_zones}"]
}

output "public_availability_zones" {
	value = ["${module.vpc.public_availability_zones}"]
}

output "vpc_name" {
	value = "${module.vpc.vpc_name}"
}

output "private_zone_id" {
	value = "${module.vpc.private_zone_id}"
}

output "private_zone_name" {
	value = "${module.vpc.private_zone_name}"
}

output "zone_name" {
	value = "${var.zone_name}"
}

output "vpc_id" {
	value = "${module.vpc.vpc_id}"
}

output "s3_vpce_id" {
	value = "${module.vpc.s3_vpce_id}"
}

output "cidr_block" {
	value = "${module.vpc.cidr_block}"
}

