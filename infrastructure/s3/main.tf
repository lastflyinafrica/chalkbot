# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

resource "aws_s3_bucket" "chalkbot_resources" {
  bucket = "chalkbot-kampus-resources"

}

resource "aws_s3_object" "connect_whitelist" {
  key          = "connect-authentication/whitelist.json"
  bucket       = aws_s3_bucket.chalkbot_resources.id
  content_type = "application/json"
  content      = file("${path.module}/connect-whitelist.json")
  source_hash  = filebase64sha256("${path.module}/connect-whitelist.json")
}


resource "aws_s3_object" "gpt_settings" {
  key          = "gpt-settings.json"
  bucket       = aws_s3_bucket.chalkbot_resources.id
  content_type = "application/json"
  content      = file("${path.module}/gpt-settings.json")
  source_hash  = filebase64sha256("${path.module}/gpt-settings.json")
}
