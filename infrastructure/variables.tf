# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


variable "region" {
  type        = string
  description = "AWS region to launch services"
  default     = "eu-west-2"
}

variable "cloudwatch_log_retention_days" {
  type        = number
  description = "Number of days of retention for cloudwatch logs"
  default     = 14
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI key to allow use of their API"
  sensitive   = true
}

variable "connect_user_password" {
  type        = string
  sensitive   = true
  description = "password required to login to the "
}

variable "commit_hash" {
  type        = string
  description = "Git commit string"
}
