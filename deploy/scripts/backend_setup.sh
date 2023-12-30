# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


#!/bin/bash

# create folder to store command outputs
mkdir deploy/outputs

# create the s3 bucket that will store the terraform state
TERRAFORM_STATE_BUCKET_NAME=chalkbot-kampus-terraform-state
aws s3api list-buckets --output json > deploy/outputs/buckets.json
aws s3api create-bucket --bucket $TERRAFORM_STATE_BUCKET_NAME --create-bucket-configuration LocationConstraint=eu-west-2 --output json > deploy/outputs/s3-tf.json

# # create the dynamoDB table used for terraform locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --output json > deploy/outputs/dynamodb-tf.json

# create ECR repository
ECR_REPOSITORY_NAME=chalkbot-kampus-ecr
aws ecr create-repository --repository-name $ECR_REPOSITORY_NAME --image-tag-mutability MUTABLE --output json > deploy/outputs/ecr.json
aws ecr put-lifecycle-policy --repository-name $ECR_REPOSITORY_NAME --lifecycle-policy-text "file://deploy/scripts/utils/ecr-lifecycle-policy.json"