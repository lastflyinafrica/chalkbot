# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

module "gpt_lambda" {
  source = "./gpt-lambda"

  cloudwatch_log_retention_days    = var.cloudwatch_log_retention_days
  dynamobo_conversation_memory_arn = var.dynamobo_conversation_memory_arn
  openai_api_key                   = var.openai_api_key
  commit_hash                      = var.commit_hash

  chalkbot_resources_bucket_arn  = var.chalkbot_resources_bucket_arn
  chalkbot_resources_bucket_name = var.chalkbot_resources_bucket_name
  gpt_settings_key               = var.gpt_settings_key
}

module "connect_authentication" {
  source = "./connect-authentication"

  cloudwatch_log_retention_days  = var.cloudwatch_log_retention_days
  chalkbot_resources_bucket_name = var.chalkbot_resources_bucket_name
  connect_whitelist_key          = var.connect_whitelist_key
  chalkbot_resources_bucket_arn  = var.chalkbot_resources_bucket_arn
}
