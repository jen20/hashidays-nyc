resource "aws_cloudwatch_log_group" "vpc_log_group" {
	name = "${lower(replace(var.vpc_name, " ", "-"))}-vpc-flow-logs"
}

resource "aws_iam_role" "vpc_role" {
	name = "${replace(var.vpc_name, " ", "-")}-VPCFlowLogs"
	assume_role_policy = "${data.aws_iam_policy_document.flow_log_assume_role.json}"
}

data "aws_iam_policy_document" "flow_log_assume_role" {
	statement {
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["vpc-flow-logs.amazonaws.com"]
		}
		actions = ["sts:AssumeRole"]
	}
}

data "aws_iam_policy_document" "flow_log" {
	statement {
		effect = "Allow"
		resources = ["*"]
		actions = [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:PutLogEvents",
			"logs:DescribeLogGroups",
			"logs:DescribeLogStreams"
		]
	}
}

resource "aws_iam_role_policy" "vpc_role_policy" {
	name = "${replace(var.vpc_name, " ", "-")}-FlowLogs"
	role   = "${aws_iam_role.vpc_role.id}"
	policy = "${data.aws_iam_policy_document.flow_log.json}"
}

resource "aws_flow_log" "vpc_flow_log" {
	log_group_name = "${aws_cloudwatch_log_group.vpc_log_group.name}"
	iam_role_arn   = "${aws_iam_role.vpc_role.arn}"
	vpc_id         = "${aws_vpc.vpc.id}"
	traffic_type   = "ALL"
}
