import json
import pika
import threading
import time
from utils.logger import logger
from utils.rabbitmq import get_rabbitmq_connection, publish_result_to_queue
from services.transcription import process_audio_transcription
from config.settings import QUEUE_TRANSCRIPTION_REQUEST

def callback(ch, method, properties, body):
    meeting_id = None
    try:
        message = json.loads(body.decode('utf-8'))
        meeting_id = message.get('meetingId')
        audio_path = message.get('audioPath')

        logger.info(f"[Meeting {meeting_id}] Processing queued request")

        if not meeting_id or not audio_path:
            raise ValueError("Missing meetingId or audioPath")

        result = process_audio_transcription(audio_path, meeting_id)
        publish_result_to_queue(result)

        ch.basic_ack(delivery_tag=method.delivery_tag)

    except Exception as e:
        logger.error(f"[Meeting {meeting_id}] Consumer error: {e}", exc_info=True)
        if meeting_id:
            publish_result_to_queue({
                "meetingId": meeting_id,
                "status": "failed",
                "error": str(e),
                "transcript": []
            })
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

def start_consumer():
    while True:
        try:
            logger.info("Starting RabbitMQ consumer...")
            connection = get_rabbitmq_connection()
            channel = connection.channel()

            channel.queue_declare(queue=QUEUE_TRANSCRIPTION_REQUEST, durable=True)
            channel.basic_qos(prefetch_count=1)
            channel.basic_consume(queue=QUEUE_TRANSCRIPTION_REQUEST, on_message_callback=callback)

            logger.info(f"Consumer waiting on queue: {QUEUE_TRANSCRIPTION_REQUEST}")
            channel.start_consuming()

        except Exception as e:
            logger.error(f"Consumer error: {e}")
            time.sleep(5)