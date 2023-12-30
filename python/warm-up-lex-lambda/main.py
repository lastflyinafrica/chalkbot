# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND.
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE.

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0).

import string
import random
import time
import logging
import datetime
import base64
import gzip
from os import getenv

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info("Lambda starting up")

bot_id = getenv("LEX_BOT_ID")
bot_alias_id = getenv("LEX_BOT_ALIAS_ID")

if not bot_id or not bot_alias_id:
    raise Exception(
        "Required variables LEX_BOT_ID and LEX_BOT_ALIAS_ID are not provided"
    )

client = boto3.client("lexv2-runtime")


def generate_random_string(length):
    characters = string.ascii_letters + string.digits
    # Use random.choice to randomly select characters and create the string
    random_string = "".join(random.choice(characters) for _ in range(length))

    return random_string


def decode_and_decompress_lex_response(lex_response):
    text_response = lex_response["messages"]
    decoded_bytes = base64.b64decode(text_response)

    # Gzip decompress
    try:
        decompressed_bytes = gzip.decompress(decoded_bytes)
        decompressed_string = decompressed_bytes.decode("utf-8")
        return decompressed_string
    except gzip.BadGzipFile:
        logger.info("The input data is not a valid gzipped string.")
    except OSError:
        # Handle other errors, such as decoding issues
        logger.info("An error occurred during decoding or decompression.")


def send_speech_request_to_lex():
    # Specify the content type of the audio being sent (PCM)
    content_type = "audio/l16; rate=16000; channels=1"

    # Read the audio data from a file
    with open("hello.pcm", "rb") as audio_file:
        audio_data = audio_file.read()

        start_time = time.time()
        # Send the RecognizeUtterance request
        response = client.recognize_utterance(
            botId=bot_id,
            botAliasId=bot_alias_id,
            localeId="en_GB",
            sessionId=generate_random_string(11),
            requestContentType=content_type,
            responseContentType="text/plain;charset=utf-8",
            inputStream=audio_data,
        )
        end_time = time.time()
        logger.info(f"Lex response: {response}")
        logger.info(
            f"Request took: {end_time - start_time} seconds. Current time is {datetime.datetime.now()}"
        )

        return response


def handler(event, context):
    """
    Send a speech request to amazon lex.

    This will be run periodically to avoid cold starts.
    """
    logger.info(f"Event received: {event}")
    response = send_speech_request_to_lex()

    lex_answer = decode_and_decompress_lex_response(response)
    logger.info(f"Decompressed string: {lex_answer}")
