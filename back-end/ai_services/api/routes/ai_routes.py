from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from models.response import ApiResponse
from utils.logger import logger
from utils.rabbitmq import get_rabbitmq_connection
from config.settings import QUEUE_TRANSCRIPTION_REQUEST, UPLOAD_DIR
import os
import uuid
from datetime import datetime

router = APIRouter(prefix="/api/ai", tags=["AI Service"])

@router.get("/health")
async def health():
    from services.transcription import whisper_model, diarization_pipeline
    from config.settings import DEVICE, RABBITMQ_HOST, RABBITMQ_PORT

    return ApiResponse.success({
        "status": "healthy",
        "device": str(DEVICE),
        "rabbitmq_host": RABBITMQ_HOST,
        "rabbitmq_port": RABBITMQ_PORT,
        "whisper_model_loaded": whisper_model is not None,
        "diarization_loaded": diarization_pipeline is not None
    })

@router.get("/test-api")
async def test_api():
    from config.settings import DEVICE
    return ApiResponse.success({
        "message": "AI Service is working",
        "device": str(DEVICE),
        "timestamp": datetime.now().isoformat()
    })

@router.post("/process-transcription")
async def process_transcription(
    file: UploadFile = File(...),
    meeting_id: str = Form(...)
):
    allowed_extensions = ['.mp3', '.wav', '.m4a', '.flac', '.ogg']
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in allowed_extensions:
        raise HTTPException(status_code=400, detail=f"Invalid file type. Allowed: {', '.join(allowed_extensions)}")

    unique_filename = f"{meeting_id}_{uuid.uuid4()}{ext}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)

    with open(file_path, "wb") as f:
        content = await file.read()
        f.write(content)

    try:
        connection = get_rabbitmq_connection()
        channel = connection.channel()
        channel.queue_declare(queue=QUEUE_TRANSCRIPTION_REQUEST, durable=True)

        message = {"meetingId": meeting_id, "audioPath": file_path}
        channel.basic_publish(
            exchange='',
            routing_key=QUEUE_TRANSCRIPTION_REQUEST,
            body=json.dumps(message),
            properties=pika.BasicProperties(delivery_mode=2)
        )
        connection.close()

        return ApiResponse.success({
            "meeting_id": meeting_id,
            "status": "queued",
            "message": "Transcription request queued successfully"
        })

    except Exception as e:
        logger.error(f"Queue publish error: {e}")
        raise HTTPException(status_code=500, detail="Failed to queue request")