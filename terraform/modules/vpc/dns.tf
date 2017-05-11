resource "aws_route53_zone" "vpc_private" {
	name = "${var.zone_name}"
	vpc_id = "${aws_vpc.vpc.id}"
	comment = "Private zone for ${var.zone_name}. Managed by Terraform"
}

resource "aws_vpc_dhcp_options" "vpc" {
	domain_name = "${var.zone_name}"
	domain_name_servers = ["AmazonProvidedDNS"]

	tags {
		Name = "${var.vpc_name} Options"
	}
}

resource "aws_vpc_dhcp_options_association" "vpc" {
	vpc_id = "${aws_vpc.vpc.id}"
	dhcp_options_id = "${aws_vpc_dhcp_options.vpc.id}"
}
