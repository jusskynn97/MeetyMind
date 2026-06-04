import threading
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import py_eureka_client.eureka_client as eureka_client

from routes.ai_routes import router as ai_router
from consumers.rabbitmq_consumer import start_consumer
from utils.logger import logger
from config.settings import DEVICE

app = FastAPI(title="AI Transcription Service")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(ai_router)

@app.on_event("startup")
async def startup_event():
    try:
        await eureka_client.init_async(
            eureka_server="http://localhost:8761/eureka",
            app_name="ai-service",
            instance_port=8092,
            instance_host="localhost"
        )
        logger.info("Eureka registration successful")
    except Exception as e:
        logger.error(f"Eureka registration failed: {e}")

    # Start RabbitMQ consumer in background
    consumer_thread = threading.Thread(target=start_consumer, daemon=True)
    consumer_thread.start()
    logger.info("RabbitMQ consumer thread started")

@app.on_event("shutdown")
async def shutdown_event():
    await eureka_client.stop_async()
    logger.info("Eureka client stopped")

if __name__ == "__main__":
    logger.info("Starting AI Service...")
    logger.info(f"Device: {DEVICE}")
    uvicorn.run(app, host="0.0.0.0", port=8092)