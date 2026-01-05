package com.kynn.meeting_service.services;

import com.kynn.meeting_service.dto.rabbitmq.TranscriptionResult;
import com.kynn.meeting_service.dto.response.TranscriptResponseDTO;

import java.util.UUID;

public interface TranscriptionService {
  void saveTranscriptionResult(TranscriptionResult result);
  TranscriptResponseDTO getTranscriptionByMeetingId(UUID meetingId);
  void createInitialTranscription(UUID meetingId, String audioPath);
}