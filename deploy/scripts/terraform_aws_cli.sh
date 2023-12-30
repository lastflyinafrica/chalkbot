# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


#!/bin/bash

cd infrastructure

terraform init \
    -input=false \
    -backend-config "bucket=chalkbot-kampus-terraform-state" \
    -backend-config "key=state/terraform.tfstate" \
    -backend-config "region=eu-west-2" \
    -backend-config "dynamodb_table=terraform-locks"

OPENAI_API_KEY=your-openai-api-key #your-openai_api_key
CONNECT_ADMIN_PASSWORD=your-connect-password # should be between 8 to 64 characters, and must contain at least one uppercase letter, one lowercase letter, and one number.
CI_COMMIT_SHA=$(echo $RANDOM)

terraform plan \
    -var "openai_api_key=$OPENAI_API_KEY" \
    -var "connect_user_password=$CONNECT_ADMIN_PASSWORD" \
    -var "commit_hash=$CI_COMMIT_SHA" \
    -out terraform.plan

terraform apply -auto-approve terraform.plan

terraform output -json > terraform.json

# due to lack of tf support for lex v2 and connect, need to perform some actions using aws cli
CONNECT_INSTANCE_ID=$(jq -r '.connect_instance_id.value' terraform.json)
LEX_ALIAS_ARN=$(jq -r '.lexbot_stack_output.value.ChalkbotLexBotAliasArn' terraform.json)
CONNECT_PHONE_NUMBER_ID=$(jq -r '.connect_phone_number_id.value' terraform.json)
CONNECT_CONTACT_FLOW_ARN=$(jq -r '.connect_contact_flow_arn.value' terraform.json)

aws connect associate-bot --instance-id $CONNECT_INSTANCE_ID --lex-v2-bot AliasArn=$LEX_ALIAS_ARN
aws connect associate-phone-number-contact-flow \
        --phone-number-id $CONNECT_PHONE_NUMBER_ID \
        --instance-id $CONNECT_INSTANCE_ID \
        --contact-flow-id $CONNECT_CONTACT_FLOW_ARN