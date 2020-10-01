data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "logs" {
  name = var.name

  retention_in_days = var.retention

  tags = var.tags
}

data "aws_iam_policy_document" "logs_cloudwatch_log_group" {
  statement {
    actions   = ["logs:DescribeLogStreams"]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.logs.arn}:*"]
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${var.name}"

  retention_in_days = 3

  tags = var.tags
}

data "aws_iam_policy_document" "lambda_cloudwatch_log_group" {
  statement {
    actions   = ["logs:DescribeLogStreams"]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }
}
