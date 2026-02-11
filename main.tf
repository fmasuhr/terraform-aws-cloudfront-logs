resource "aws_lambda_function" "this" {
  function_name = var.name

  runtime                        = "nodejs24.x"
  handler                        = "index.handler"
  timeout                        = 5
  reserved_concurrent_executions = 3

  environment {
    variables = {
      CLOUDWATCH_LOGS_GROUP_ARN = aws_cloudwatch_log_group.logs.arn
    }
  }

  role = aws_iam_role.lambda.arn

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = var.tags

  depends_on = [aws_cloudwatch_log_group.lambda]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src"
  output_path = ".terraform/tmp/lambda/${var.name}.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "lambda-${var.name}"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_cloudwatch_log_group" {
  name   = "cloudwatch-log-group"
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda_cloudwatch_log_group.json
}

resource "aws_iam_role_policy" "lambda_cloudwatch_log_group_logs" {
  name   = "cloudwatch-log-group-logs"
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.logs_cloudwatch_log_group.json
}

resource "aws_iam_role_policy" "lambda_s3_bucket_readonly" {
  name   = "s3-bucket-readonly"
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.s3_bucket_readonly.json
}

resource "aws_lambda_permission" "s3_bucket_invoke_function" {
  function_name = aws_lambda_function.this.arn
  action        = "lambda:InvokeFunction"

  principal  = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.this.arn
}
