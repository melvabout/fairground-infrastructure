data "aws_iam_policy_document" "server" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "server_policy" {

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
      ]

    resources = ["*"]
  }

}

data "aws_iam_policy_document" "populate_hosts" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "populate_hosts_policy" {

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ssm:SendCommand",
      "sns:Subscribe"
    ]

    resources = ["*"]
  }

}

data "aws_vpc" "this" {
  id = var.vpc_id
}