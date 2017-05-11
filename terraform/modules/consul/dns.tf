resource "aws_route53_record" "config" {
	zone_id = "${var.vpc_zone_id}"
	name = "${var.dns_name}"
	type = "TXT"
	ttl = "300"
	records = ["serf:${var.consul_serf_key} tld:${var.consul_tld} rev:${data.aws_vpc.vpc.cidr_block}"]
}

data "aws_vpc" "vpc" {
	id = "${var.vpc_id}"	
}
