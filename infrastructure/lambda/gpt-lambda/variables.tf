# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

variable "cloudwatch_log_retention_days" {
  type        = number
  description = "Number of days of retention for cloudwatch logs"
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI key to allow use of their API"
  sensitive   = true
}

variable "dynamobo_conversation_memory_arn" {
  type        = string
  description = "ARN of DynamoDB table used to store GPT conversations"
}

variable "commit_hash" {
  type        = string
  description = "Git commit string"
}

variable "chalkbot_resources_bucket_name" {
  type        = string
  description = "Name of bucket containing project resources"
}

variable "chalkbot_resources_bucket_arn" {
  type        = string
  description = "ARN of bucket containing project resources"
}

variable "gpt_settings_key" {
  type        = string
  description = "Key to gpt settings json file in chalkbot resources bucket"
}

