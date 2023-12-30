# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

terraform {
  backend "s3" {
    dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.12.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "gpt_memory_dynamodb" {
  source = "./dynamodb"
}

module "s3" {
  source = "./s3"
}

module "lambda" {
  source = "./lambda"

  cloudwatch_log_retention_days  = var.cloudwatch_log_retention_days
  chalkbot_resources_bucket_name = module.s3.chalkbot_resources_bucket_name
  chalkbot_resources_bucket_arn  = module.s3.chalkbot_resources_bucket_arn
  connect_whitelist_key          = module.s3.connect_whitelist_key
  gpt_settings_key               = module.s3.gpt_settings_key

  dynamobo_conversation_memory_arn = module.gpt_memory_dynamodb.dynamobo_conversation_memory_arn

  commit_hash    = var.commit_hash
  openai_api_key = var.openai_api_key
}

module "lex_bot" {
  source         = "./lex-bot"
  lex_lambda_arn = module.lambda.gpt_lambda_arn
}


module "warm_up_lex_lambda" {
  source = "./lambda/warm-up-lex"

  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days

  lex_bot_id       = lookup(module.lex_bot.lexbot_stack_output, "LexBotId", "")
  lex_bot_alias_id = lookup(module.lex_bot.lexbot_stack_output, "LexBotAliasId", "")

  depends_on = [module.lex_bot]
}

module "connect" {
  source                = "./connect"
  connect_user_password = var.connect_user_password

  connect_authentication_lambda_arn  = module.lambda.connect_auth_lambda_arn
  connect_authentication_lambda_name = module.lambda.connect_auth_lambda_fn_name

  gpt_lambda_arn  = module.lambda.gpt_lambda_arn
  gpt_lambda_name = module.lambda.gpt_lambda_name

  lex_alias_arn = lookup(module.lex_bot.lexbot_stack_output, "ChalkbotLexBotAliasArn", "")
}
