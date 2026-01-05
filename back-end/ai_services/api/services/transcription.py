# import torch
import whisper
from whisperx.diarize import DiarizationPipeline
from whisperx import load_align_model, align
from whisperx.diarize import assign_word_speakers
from utils.post_process import post_process_speaker_assignment
from utils.logger import logger
from config.settings import DEVICE, MODEL_NAME, HF_TOKEN

# Global models
whisper_model: whisper.Whisper | None = None
diarization_pipeline: DiarizationPipeline | None = None

def load_models():
    global whisper_model, diarization_pipeline
    if whisper_model is None:
        logger.info("Loading Whisper model...")
        whisper_model = whisper.load_model(MODEL_NAME, device=DEVICE)
        logger.info("Whisper model loaded")

    if diarization_pipeline is None:
        logger.info("Loading Diarization pipeline...")
        diarization_pipeline = DiarizationPipeline(use_auth_token=HF_TOKEN, device=DEVICE)
        logger.info("Diarization pipeline loaded")

def process_audio_transcription(audio_path: str, meeting_id: str) -> dict:
    try:
        logger.info(f"[Meeting {meeting_id}] Starting transcription process")
        load_models()

        # Transcribe
        logger.info(f"[Meeting {meeting_id}] Transcribing...")
        script = whisper_model.transcribe(audio_path)

        # Diarize
        logger.info(f"[Meeting {meeting_id}] Diarizing...")
        diarized = diarization_pipeline(audio_path)

        # Align
        logger.info(f"[Meeting {meeting_id}] Aligning...")
        model_a, metadata = load_align_model(language_code=script["language"], device=DEVICE)
        script_aligned = align(script["segments"], model_a, metadata, audio_path, DEVICE)

        # Assign speakers
        logger.info(f"[Meeting {meeting_id}] Assigning speakers...")
        result_segments, _ = list(assign_word_speakers(diarized, script_aligned).values())

        # Post-process
        result_segments = post_process_speaker_assignment(result_segments)

        # Cleanup
        try:
            if os.path.exists(audio_path):
                os.remove(audio_path)
                logger.info(f"[Meeting {meeting_id}] Audio file removed")
        except Exception as e:
            logger.warning(f"Could not remove file: {e}")

        return {
            "meetingId": meeting_id,
            "status": "completed",
            "transcript": result_segments,
            "totalSegments": len(result_segments)
        }

    except Exception as e:
        logger.error(f"[Meeting {meeting_id}] Transcription failed: {e}", exc_info=True)
        return {
            "meetingId": meeting_id,
            "status": "failed",
            "error": str(e),
            "transcript": []
        }