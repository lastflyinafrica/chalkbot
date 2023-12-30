# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

resource "aws_cloudformation_stack" "lexbot_stack" {
  name          = "LexBotStack"
  template_body = file("${path.module}/cloudformation-templates/Bot.yml")
  on_failure    = "ROLLBACK"
  capabilities  = ["CAPABILITY_IAM"]

  parameters = {
    LexLambdaArn = var.lex_lambda_arn
  }

}
