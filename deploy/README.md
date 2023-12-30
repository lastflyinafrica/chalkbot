# Chalkbot

This is the initial POC of Chalkbot, a phone to GPT service which allows you to interact with ChatGPT over the phone.
Users only require a phone number, no internet access is needed from the user.

## Requirements

The following are required for the installation of chalkbot:

* bash
* Docker
* [Terraform v1.5.6](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* jq
* zip

## Instructions

Follow the instructions in the backend setup section found in the main readme to create the necessary terraform backend and ECR repository and update the push GPT lambda to ECR script.

Once this is done, the following need to be set:
1. `OPENAI_API_KEY` in `deploy/scripts/terraform_aws_cli.sh` line 12 to be your openai api key.
2. `CONNECT_ADMIN_PASSWORD` in `deploy/scripts/terraform_aws_cli.sh` line 13 to be your desired password for the chalkbot-admin user which will have permissions to make any change to the amazon connect instance.

Run ./deploy/deploy.sh from the folder's directory (not from within the deploy directory)

