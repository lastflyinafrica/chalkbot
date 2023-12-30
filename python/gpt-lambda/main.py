# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND.
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE.

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0).

from os import getenv
import logging
import time
import json

import boto3
from langchain.chains import LLMChain
from langchain.chat_models import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.memory.chat_message_histories import DynamoDBChatMessageHistory
from langchain.schema import SystemMessage
from langchain.prompts import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
    MessagesPlaceholder,
)

logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.info("Lambda starting up")

OPENAI_API_KEY = getenv("OPENAI_API_KEY")
CHALKBOT_RESOURCES_BUCKET = getenv("CHALKBOT_RESOURCES_BUCKET")
GPT_SETTINGS_KEY = getenv("GPT_SETTINGS_KEY")


def _gpt_settings_json_from_s3() -> dict:
    """
    GPT settings such as the prompt to give to chatGPT
    and temperature are stored in an s3 bucket and need to be retrieved

    Returns:
        dict: GPT settings
    """
    s3_client = boto3.client("s3")
    response = s3_client.get_object(
        Bucket=CHALKBOT_RESOURCES_BUCKET, Key=GPT_SETTINGS_KEY
    )
    file_contents = response["Body"].read().decode("utf-8")
    whitelist_json = json.loads(file_contents)
    logger.info(whitelist_json)
    return whitelist_json


def _get_openai_prompt(gpt_prompt: str) -> ChatPromptTemplate:
    """
    PromptTemplate to pass to OpenAI

    Args:
        gpt_prompt (str): Initial prompt given to ChatGPT

    Returns:
        ChatPromptTemplate: LangChain ChatPromptTemplate which can be used with
        an LLM chain
    """
    openai_prompt = ChatPromptTemplate.from_messages(
        [
            SystemMessage(content=gpt_prompt),
            MessagesPlaceholder(variable_name="chat_history"),
            HumanMessagePromptTemplate.from_template("{user_question}"),
        ]
    )
    return openai_prompt


def _create_llm_chain(session_id: str) -> LLMChain:
    """
    Create a langchain LLM Chain
    This will use dynamoDB backed memory to store and retrieve conversation history.

    Args:
        session_id (str): Session id used to uniquely identify a conversation

    Returns:
        LLMChain: LangChain LLMChain
    """
    gpt_settings = _gpt_settings_json_from_s3()

    llm = ChatOpenAI(
        openai_api_key=OPENAI_API_KEY,
        model_name="gpt-3.5-turbo",
        temperature=gpt_settings["temperature"],
    )

    chat_history = DynamoDBChatMessageHistory(
        table_name="GPT-Memory", session_id=session_id
    )
    memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
    memory.chat_memory = chat_history

    chat_llm_chain = LLMChain(
        llm=llm,
        prompt=_get_openai_prompt(gpt_prompt=gpt_settings["prompt"]),
        verbose=False,
        memory=memory,
    )
    return chat_llm_chain


def send_gpt_request(event):
    contactId = event["sessionState"]["sessionAttributes"]["contactId"]
    user_question = event["inputTranscript"]
    start_time = time.time()

    llm_chain = _create_llm_chain(session_id=contactId)
    answer = llm_chain.predict(user_question=user_question)

    end_time = time.time()
    logger.info(f"GPTResponseTime: {end_time - start_time} seconds.")
    logger.info(f"GPT answer: {answer}")
    return create_lex_response(event, answer)


def create_lex_response(event, gpt_answer):
    """
    Using the answer from chatGPT
    Return the answer to Lex in the format it expects
    As defined in: https://docs.aws.amazon.com/lexv2/latest/dg/lambda-response-format.html
    """
    intent = event["sessionState"]["intent"]["name"]
    response = {
        "sessionState": {
            "sessionAttributes": {"gpt_answer": gpt_answer},
            "dialogAction": {"type": "Close"},
            "intent": {"name": intent, "state": "Fulfilled"},
        },
        "messages": [{"contentType": "PlainText", "content": gpt_answer}],
    }
    logger.info(response)
    return response


def is_warm_up_request(event):
    try:
        return event["Details"]["Parameters"]["isWarmUpRequest"]["value"]
    except KeyError:
        return False


def handler(event, context):
    """
    Checks if the call was triggered by an amazon connect 'warm up call'
    Or if it was triggered by Lex and should be forwarded to OpenAI
    if it should, send the request to OpenAI
    """
    logger.info(f"Event received: {event}")

    if is_warm_up_request(event):
        logger.info("Not sending to GPT")
        return

    return send_gpt_request(event)
