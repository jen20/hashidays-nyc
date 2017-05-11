variable "availability_zones" {
	description = "List of availability zones across which to distribute subnets"
	type = "list"
}

variable "cidr_block" {
	description = "The VPC address space in CIDR notation"
	type = "string"
}

variable "private_subnets" {
	description = "List of private subnet address spaces in CIDR notation"
	type = "list"
}

variable "public_subnets" {
	description = "List of public subnet address spaces in CIDR notation"
	type = "list"
}

variable "region" {
    description = "Region into which the VPC is deployed"
    type = "string"
}

variable "vpc_name" {
	description = "The name of the VPC"
	type = "string"
}

variable "zone_name" {
	description = "The private zone name for Route 53"
	type = "string"
}



output "cidr_block" {
	value = "${aws_vpc.vpc.cidr_block}"
}

output "private_subnets" {
	value = ["${aws_subnet.private.*.id}"]
}

output "private_availability_zones" {
	value = ["${aws_subnet.private.*.availability_zone}"]
}

output "private_zone_id" {
	value = "${aws_route53_zone.vpc_private.zone_id}"
}

output "private_zone_name" {
	value = "${aws_route53_zone.vpc_private.name}"
}

output "public_availability_zones" {
	value = ["${aws_subnet.public.*.availability_zone}"]
}

output "public_subnets" {
	value = ["${aws_subnet.public.*.id}"]
}

output "vpc_name" {
	value = "${var.vpc_name}"
}

output "vpc_id" {
	value = "${aws_vpc.vpc.id}"
}

output "s3_vpce_id" {
	value = "${aws_vpc_endpoint.s3.id}"
}

