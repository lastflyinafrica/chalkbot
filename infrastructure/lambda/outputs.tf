# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

output "connect_auth_lambda_arn" {
  value = module.connect_authentication.connect_auth_lambda_arn
}

output "connect_auth_lambda_fn_name" {
  value = module.connect_authentication.connect_auth_lambda_fn_name
}

output "gpt_lambda_arn" {
  value = module.gpt_lambda.gpt_lambda_arn
}

output "gpt_lambda_name" {
  value = module.gpt_lambda.gpt_lambda_name
}
