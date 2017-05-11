resource "aws_route53_record" "repo_private" {
	zone_id = "${var.private_zone_id}"
	type = "A"
	name = "${var.private_record_name}"

	alias {
		zone_id = "${aws_s3_bucket.repo.hosted_zone_id}"
		name = "${aws_s3_bucket.repo.website_domain}"
		evaluate_target_health = true
	}
}
