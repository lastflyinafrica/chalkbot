# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND.
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE.

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0).

import logging
from os import getenv
import json

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info("Lambda starting up")


client = boto3.client("s3")

CHALKBOT_RESOURCES_BUCKET = getenv("CHALKBOT_RESOURCES_BUCKET")
AUTHENTICATION_WHITELIST_KEY = getenv("AUTHENTICATION_WHITELIST_KEY")


def get_caller_whitelist() -> dict:
    """
    Whitelist of numbers allowed to call the service is stored in a json in S3.
    Read this and return it as a dict

    Returns:
        dict: _description_
    """
    response = client.get_object(
        Bucket=CHALKBOT_RESOURCES_BUCKET, Key=AUTHENTICATION_WHITELIST_KEY
    )
    file_contents = response["Body"].read().decode("utf-8")
    whitelist_json = json.loads(file_contents)
    logger.info(whitelist_json)
    return whitelist_json


def is_caller_allowed(caller_number: str, whitelist_json: dict) -> bool:
    """
    Check whether the whitelist is currently enabled,
    If it is, check whether the caller's number is in this whitelist
    """
    if not whitelist_json["whitelistEnabled"]:
        return True
    return caller_number in whitelist_json["whitelistNumbers"]


def handler(event, context):
    """
    Extract the caller's number from the amazon connect input event
    Check whether the whitelist (which is stored in s3) is currently enabled,
    If it is, check whether the caller's number is in this whitelist
    """
    logger.info(f"Event received: {event}")

    call_type = event["Details"]["ContactData"]["CustomerEndpoint"]["Type"]
    caller_number = event["Details"]["ContactData"]["CustomerEndpoint"]["Address"]

    if call_type == "TELEPHONE_NUMBER" and caller_number:
        logger.info(f"Checking if {caller_number} is allowed to proceed")
    else:
        logger.error(f"Error! {caller_number} is not authorised to proceed.")
        raise Exception("Error, caller does not have a valid phone number")

    caller_allowed = is_caller_allowed(caller_number, get_caller_whitelist())
    logger.info(f"{caller_number} is allowed to use the service = {caller_allowed}")
    return {"callerAllowed": caller_allowed}
