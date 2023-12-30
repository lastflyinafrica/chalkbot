# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


# This file contains everything related to the deployment of the warm-up-lex lambda function

locals {
  warm_up_lex_function_name = "warm-up-lex-lambda"
}

resource "aws_lambda_function" "warm_up_lex" {
  function_name    = local.warm_up_lex_function_name
  handler          = "main.handler"
  runtime          = "python3.11"
  filename         = "${path.module}/warm-up-lex-lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/warm-up-lex-lambda.zip")
  role             = aws_iam_role.warm_up_lex.arn

  timeout = 10

  environment {
    variables = {
      LEX_BOT_ID       = var.lex_bot_id
      LEX_BOT_ALIAS_ID = var.lex_bot_alias_id
    }
  }
}

resource "aws_iam_policy" "warm_up_lex" {
  name        = "${local.warm_up_lex_function_name}-policy"
  description = "Policy attached to ${local.warm_up_lex_function_name} role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.warm_up_lex_log_group.arn}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "lex:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "warm_up_lex" {
  name = "${local.warm_up_lex_function_name}-role"
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

resource "aws_iam_role_policy_attachment" "warm_up_lex" {
  role       = aws_iam_role.warm_up_lex.name
  policy_arn = aws_iam_policy.warm_up_lex.arn
}

resource "aws_cloudwatch_log_group" "warm_up_lex_log_group" {
  name              = "/aws/lambda/${local.warm_up_lex_function_name}"
  retention_in_days = var.cloudwatch_log_retention_days
}

resource "aws_cloudwatch_event_rule" "warm_up_lex" {
  name                = "${local.warm_up_lex_function_name}-rule"
  schedule_expression = "cron(0/20 8-17 ? * MON-FRI *)"
  description         = "Rule that will trigger the warm-up-lex lambda function every 20 minutes between the hours of 9am and 6pm UK time"
}


resource "aws_cloudwatch_event_target" "warm_up_lex" {
  rule      = aws_cloudwatch_event_rule.warm_up_lex.name
  target_id = "${local.warm_up_lex_function_name}-target"
  arn       = aws_lambda_function.warm_up_lex.arn
}

resource "aws_lambda_permission" "events_invoke_" {
  statement_id  = "AllowExecutionFromCloudwatchEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.warm_up_lex.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.warm_up_lex.arn
}
