# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


# BEFORE RUNNING ENSURE THE BACKEND TERRAFORM AND ECR REPOSITORY HAVE BEEN CREATED
# AND THE PUSH_GPT_LAMBDA_TO_ECR.sh HAS BEEN CORRECTLY UPDATED
# AS PER THE README INSTRUCTIONS

# create zips of the authentication and warm up lex lambda
./deploy/scripts/zip_lambdas.sh

# build the gpt lambda image and push to ecr
./deploy/scripts/push_gpt_lambda_to_ecr.sh

# copy the lambda zips to the infrastructure dir so they can be used during tf deployment
cp python/authentication-lambda/connect-auth-lambda.zip infrastructure/lambda/connect-authentication
cp python/warm-up-lex-lambda/warm-up-lex-lambda.zip infrastructure/lambda/warm-up-lex/

# run tf plan and apply + perform necessary aws cli commands
./deploy/scripts/terraform_aws_cli.sh