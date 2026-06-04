import os
import torch

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

HF_TOKEN = os.getenv("HF_TOKEN")
MODEL_NAME = "small"
UPLOAD_DIR = "uploads"

# RabbitMQ
RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "localhost")
RABBITMQ_PORT = int(os.getenv("RABBITMQ_PORT", "5672"))
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "admin")
RABBITMQ_PASS = os.getenv("RABBITMQ_PASS", "123456")

QUEUE_TRANSCRIPTION_REQUEST = "transcription.request"
QUEUE_TRANSCRIPTION_RESULT = "transcription.result"

# Meeting Service
MEETING_SERVICE_URL = os.getenv("MEETING_SERVICE_URL", "http://localhost:8091")

# Tạo thư mục uploads
os.makedirs(UPLOAD_DIR, exist_ok=True)