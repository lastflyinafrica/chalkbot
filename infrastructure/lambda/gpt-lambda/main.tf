# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


# This file contains everything related to the deployment of the gpt-lambda function

locals {
  gpt_lambda_function_name = "gpt-lambda"
  ecr_repository_name      = "chalkbot-kampus-ecr"
  gpt_lambda_image_tag     = "latest"
}

data "aws_ecr_repository" "gpt_lambda" {
  name = local.ecr_repository_name
}

resource "aws_lambda_function" "gpt_lambda" {
  function_name    = local.gpt_lambda_function_name
  package_type     = "Image"
  image_uri        = "${data.aws_ecr_repository.gpt_lambda.repository_url}:${local.gpt_lambda_image_tag}"
  role             = aws_iam_role.gpt_lambda.arn
  timeout          = 60 * 5
  memory_size      = 512
  source_code_hash = var.commit_hash

  environment {
    variables = {
      OPENAI_API_KEY            = var.openai_api_key
      CHALKBOT_RESOURCES_BUCKET = var.chalkbot_resources_bucket_name
      GPT_SETTINGS_KEY          = var.gpt_settings_key
    }
  }
}


resource "aws_iam_policy" "gpt_lambda" {
  name        = "${local.gpt_lambda_function_name}-policy"
  description = "Policy attached to ${local.gpt_lambda_function_name} role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.gpt_lambda_log_group.arn}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:*"
        ],
        Resource = "${var.dynamobo_conversation_memory_arn}"
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

resource "aws_iam_role" "gpt_lambda" {
  name = "${local.gpt_lambda_function_name}-role"
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


resource "aws_iam_role_policy_attachment" "gpt_lambda" {
  role       = aws_iam_role.gpt_lambda.name
  policy_arn = aws_iam_policy.gpt_lambda.arn
}

resource "aws_cloudwatch_log_group" "gpt_lambda_log_group" {
  name              = "/aws/lambda/${local.gpt_lambda_function_name}"
  retention_in_days = var.cloudwatch_log_retention_days
}


