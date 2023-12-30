# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

variable "connect_user_password" {
  type        = string
  sensitive   = true
  description = "password required to login to the "
}

variable "connect_authentication_lambda_arn" {
  type        = string
  description = "ARN of the lambda function that will determine whether or not a caller can connect"
}

variable "connect_authentication_lambda_name" {
  type        = string
  description = "Name of the lambda function that will determine whether or not a caller can connect"
}

variable "gpt_lambda_name" {
  type        = string
  description = "ARN of the lambda function that will pass user question to GPT model"
}

variable "gpt_lambda_arn" {
  type        = string
  description = "ARN of the lambda function that will pass user question to GPT model"
}

variable "lex_alias_arn" {
  type        = string
  description = "ARN of the lex bot"
}
