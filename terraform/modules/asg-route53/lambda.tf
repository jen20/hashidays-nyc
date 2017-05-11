resource "aws_sns_topic" "asg_dns" {  
    name = "Route53-ASG"
    display_name = "Autoscaling Notifications to Route53"
}

resource "aws_autoscaling_notification" "asg_dns" {
    group_names = ["${var.asg_name}"]
    notifications  = [
        "autoscaling:EC2_INSTANCE_LAUNCH",
        "autoscaling:EC2_INSTANCE_TERMINATE",
    ]
    topic_arn = "${aws_sns_topic.asg_dns.arn}"
}

data "archive_file" "asg_dns" {
    type = "zip"
    source_dir = "${path.module}/lambda"
    output_path = "${path.module}/asgRoute53.zip"
}

resource "aws_lambda_function" "asg_dns" {
    depends_on = ["data.archive_file.asg_dns"]

    function_name = "asgRoute53"
    description = "Update Route53 when AutoScaling Events Occur"

    runtime = "nodejs6.10"
    handler = "asgRoute53.handler"

    role = "${aws_iam_role.asg_dns.arn}"
    timeout = 45

    filename = "${data.archive_file.asg_dns.output_path}"
    source_code_hash = "${base64sha256(file(data.archive_file.asg_dns.output_path))}"

    environment {
        variables {
            ASG_REGION = "${var.region}"
        }
    }
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        effect = "Allow"
        actions = [
            "sts:AssumeRole",
        ]
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "asg_dns" {
    name = "ASGRoute53"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

data "aws_iam_policy_document" "asg_dns" {
    statement {
        sid = "CloudwatchLogs"
        effect = "Allow"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:GetLogEvents",
            "logs:PutLogEvents"
        ]
        resources = ["arn:aws:logs:*:*:*"]
    }
	statement {
		sid = "AllowDescribeInstances"
		effect = "Allow"
		resources = ["*"]
		actions = [
			"autoscaling:DescribeAutoScalingGroups",
			"autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeTags",
			"ec2:DescribeInstances",
		]
	}
	statement {
		sid = "AllowRoute53Registration"
		effect = "Allow"
		resources = ["*"]
		actions = [
			"route53:GetHostedZone",
			"route53:ChangeResourceRecordSets",
		]
	}
}

resource "aws_iam_role_policy" "asg_dns" {  
    name = "ASGRoute53"
    role = "${aws_iam_role.asg_dns.id}"
    policy = "${data.aws_iam_policy_document.asg_dns.json}"
}


resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.asg_dns.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.asg_dns.arn}"
}

resource "aws_sns_topic_subscription" "lambda" {
    depends_on = ["aws_lambda_permission.with_sns"]
    topic_arn = "${aws_sns_topic.asg_dns.arn}"
    protocol = "lambda"
    endpoint = "${aws_lambda_function.asg_dns.arn}"
}
