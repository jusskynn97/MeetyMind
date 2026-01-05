import json
import pika
import asyncio
import httpx
from utils.logger import logger
from config.settings import (
    RABBITMQ_HOST, RABBITMQ_PORT, RABBITMQ_USER, RABBITMQ_PASS,
    QUEUE_TRANSCRIPTION_REQUEST, QUEUE_TRANSCRIPTION_RESULT,
    MEETING_SERVICE_URL
)

def get_rabbitmq_connection():
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST,
        port=RABBITMQ_PORT,
        credentials=credentials,
        heartbeat=600,
        blocked_connection_timeout=300
    )
    return pika.BlockingConnection(parameters)

def publish_result_to_queue(result: dict):
    try:
        connection = get_rabbitmq_connection()
        channel = connection.channel()
        channel.queue_declare(queue=QUEUE_TRANSCRIPTION_RESULT, durable=True)

        channel.basic_publish(
            exchange='',
            routing_key=QUEUE_TRANSCRIPTION_RESULT,
            body=json.dumps(result),
            properties=pika.BasicProperties(delivery_mode=2, content_type='application/json')
        )
        connection.close()
        logger.info(f"Published result for meeting {result.get('meetingId')}")
    except Exception as e:
        logger.error(f"Failed to publish to queue: {e}")
        asyncio.run(send_result_to_meeting_service(result))

async def send_result_to_meeting_service(result: dict):
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{MEETING_SERVICE_URL}/api/meetings/transcript-callback",
                json=result
            )
            if response.status_code == 200:
                logger.info(f"Sent result to meeting service: {result.get('meetingId')}")
            else:
                logger.error(f"Meeting service error: {response.status_code}")
    except Exception as e:
        logger.error(f"Failed to send to meeting service: {e}")