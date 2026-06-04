package com.kynn.meeting_service.services.rabbitmq;

import com.kynn.meeting_service.config.RabbitMQConfig;
import com.kynn.meeting_service.dto.rabbitmq.TranscriptionRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class TranscriptionProducer {

  private final RabbitTemplate rabbitTemplate;

  public void sendTranscriptionRequest(String meetingId, String audioPath) {
    try {
      TranscriptionRequest request = TranscriptionRequest.builder()
              .meetingId(meetingId)
              .audioPath(audioPath)
              .build();

      rabbitTemplate.convertAndSend(
              RabbitMQConfig.QUEUE_TRANSCRIPTION_REQUEST,
              request
      );

      log.info("✅ Sent transcription request to queue for meeting: {}", meetingId);

    } catch (Exception e) {
      log.error("❌ Error sending transcription request for meeting {}: {}",
              meetingId, e.getMessage(), e);
      throw new RuntimeException("Failed to send transcription request", e);
    }
  }
}