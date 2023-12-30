# Chalkbot

## LICENSING

CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


## Overview

This is a service that allows you to interact with ChatGPT over the phone.
Simply call the number associated with the Amazon Connect Instance and when prompted, begin asking questions.

The service uses a combination of AWS Services along with the use of LangChain to call OpenAI's API.

## System Diagram

![Chalkbot System Diagram](./Chalkbot%20AWS%20Architecture.png)

The diagram above shows how the different AWS services combine in this service.

1. The user calls a number connected to an Amazon Connect instance.
2. The connect instance invokes an Amazon Lex bot which converts the user's question from speech to text and triggers a lambda function
3. The lambda function then passes this into an OpenAI API request and returns the answer to Lex where it is then played out.
4. DynamoDB is used to store the questions and answers for each call so each call has its own memory. LangChain is used in the lambda 
    due to its easy integration with OpenAI and DynamoDB.

## Deployment

This service was deployed using gitlab pipelines, however instructions for deploying from a local machine can be found in the `deploy` directory. Note that the backend setup is required for both methods of deployment.

### Backend Setup

**NOTE** It is assumed you have aws-cli installed and set up on your device for this.

The deployment relies on the terraform backend and an ECR repository first being created. This can be done through the console or using the script in deploy/backend_setup.sh and following the instructions below:

Certain AWS components used need to be globally unique and require renaming in order for the terraform deployment to succeed (since these names are used by an existing deployment). These are:

* S3 bucket names 
* Connect instance name
* ECR respository name

To update the S3 bucket name used to store terraform state:

1. Update the `TERRAFORM_STATE_BUCKET_NAME` variable to be globally unique in `deploy/scripts/backend_setup.sh` line 15.
2. Update the `backend-config` bucket in `deploy/scripts/terraform_aws_cli.sh` line 15 to match this.

To update the S3 bucket name used to store project resources:
* Update the S3 bucket name in `infrastructure/s3/main.tf` line 9 to be globally unique.

To update the ECR respository name:
1. Update the `ECR_REPOSITORY_NAME` variable in `deploy/scripts/backend_setup.sh` line 27 to be globally unique.
2. Update the `ecr_repository_name` in `infrastructure/lambda/gpt-lambda` locals to match this.

To update the connect instance to be globally unique.
* Update the `aws_connect_instance` `instance_alias` in `infrastructure/connect/main.tf` to be globally unique.

Running ./deploy/scripts/backend_setup.sh from within the chalkbot directory will create the necessary terraform backend and ecr repository and output the details of the created resources to deploy/outputs

The AWS lambda function that makes the OpenAI API requests is deployed using an ECR image since its zip file is too large.
1. In the `Push GPT Lambda Container to ECR` gitlab ci job (or deploy/scripts/push_gpt_lambda_to_ecr.sh), update the following variables accordingly: `ECR_URL`, `REPOSITORY_NAME`, `IMAGE_TAG` where the ECR url matches the URL and repository name created in the backend setup 
(these can be found in deploy/outputs/ecr.json if you previously ran ./deploy/scripts/backend_setup.sh.)
2. In `infrastructure/lambda/gpt-lambda/main.tf`, update the local variables `ecr_repository_name` and `gpt_lambda_image_tag` to match these.


### Gitlab Pipeline

The AWS services used are deployed using a combination of Terraform and gitlab-ci jobs which use AWS CLI to make API calls. For non-gitlab deployment instructions, see the deploy directory. The first thing needed is to ensure the terraform backend and ECR repository have been created by following the above backend setup.

In order to deploy the service, the following Gitlab CI/CD environment variables need to be set:
* AWS_CONFIG - config file as described in [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
* AWS_CREDENTIALS - credentials file as described in [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
* CONNECT_ADMIN_PASSWORD - the password that you want associated with your Amazon Connect instance admin user account
* OPENAI_API_KEY - key required to use OpenAI's API

After this is completed, running a pipeline on the main branch will result in the service being deployed and you will be able to use the service.

Note: The ECR repository and terraform backend are the only AWS services not managed through terraform.

## File Structure

Deploy - contains instructions for deploying the service using a local machine (as opposed to the intended gitlab pipelines)

Infrastructure - Contains terraform code used for deployment of main AWS services

Python - Contains the python code used for the various lambdas.

gitlab-ci.yml - Contains the code responsible for the gitlab pipeline. Including terraform plan and apply, and scripts that use aws-cli to perform actions not currently possible with terraform.

## Development

To make any changes to the services, create a merge request with the proposed changes - then when this gets approved and merged into the main branch, the terraform apply job that deploys the changes will be run. On merge requests there is a terraform plan job to allow you to see the proposed changes.

If making changes to the Amazon Connect GPT Flow contact flow, it is easiest to go into the console and use the interactive GUI flow designer.
Once you have created a flow you can then either export it from the console or use AWS CLI and jq to obtain the json file representing the contact flow:
`aws connect describe-contact-flow --instance-id <value> --contact-flow-id <value> | jq '.ContactFlow.Content | fromjson' > contact_flow.json`
Then update the aws_connect_contact_flow in `infrastructure/connect/gpt-contact-flow.json` to use this json. 
Ensure the contact flow is published so that it can be associated with a phone number.
