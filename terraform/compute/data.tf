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

    actions = ["ec2:DescribeInstances"]

    resources = ["*"]
  }

}

