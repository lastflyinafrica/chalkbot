# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


# This file contains everything related to the deployment of the connect-authentication lambda function

locals {
  connect_authentication_function_name = "connect-authentication"
}

resource "aws_lambda_function" "connect_authentication" {
  function_name    = local.connect_authentication_function_name
  handler          = "main.handler"
  runtime          = "python3.11"
  filename         = "${path.module}/connect-auth-lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/connect-auth-lambda.zip")
  role             = aws_iam_role.connect_authentication.arn

  timeout = 3

  environment {
    variables = {
      CHALKBOT_RESOURCES_BUCKET    = var.chalkbot_resources_bucket_name
      AUTHENTICATION_WHITELIST_KEY = var.connect_whitelist_key
    }
  }
}

resource "aws_iam_policy" "connect_authentication" {
  name        = "${local.connect_authentication_function_name}-policy"
  description = "Policy attached to ${local.connect_authentication_function_name} role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.connect_authentication_log_group.arn}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${var.chalkbot_resources_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role" "connect_authentication" {
  name = "${local.connect_authentication_function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "connect_authentication" {
  role       = aws_iam_role.connect_authentication.name
  policy_arn = aws_iam_policy.connect_authentication.arn
}

resource "aws_cloudwatch_log_group" "connect_authentication_log_group" {
  name              = "/aws/lambda/${local.connect_authentication_function_name}"
  retention_in_days = var.cloudwatch_log_retention_days
}

