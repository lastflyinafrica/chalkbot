# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

variable "cloudwatch_log_retention_days" {
  type        = number
  description = "Number of days of retention for cloudwatch logs"
}

variable "chalkbot_resources_bucket_name" {
  type        = string
  description = "Name of bucket containing project resources"
}

variable "chalkbot_resources_bucket_arn" {
  type        = string
  description = "ARN of bucket containing project resources"
}

variable "connect_whitelist_key" {
  type        = string
  description = "Key to connect whitelist in chalkbot resources bucket"
}
