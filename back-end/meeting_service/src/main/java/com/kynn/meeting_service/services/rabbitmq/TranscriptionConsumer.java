package com.kynn.meeting_service.services.rabbitmq;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kynn.meeting_service.config.RabbitMQConfig;
import com.kynn.meeting_service.dto.rabbitmq.TranscriptionResult;
import com.kynn.meeting_service.dto.rabbitmq.TranscriptSegment;
import com.kynn.meeting_service.services.TranscriptionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class TranscriptionConsumer {

  private final ObjectMapper objectMapper;
  private final TranscriptionService transcriptionService;

  @RabbitListener(queues = RabbitMQConfig.QUEUE_TRANSCRIPTION_RESULT)
  public void handleTranscriptionResult(TranscriptionResult result) {
    try {
      log.info("📨 Received transcription result for meeting: {}", result.getMeetingId());
      log.info("   Status: {}", result.getStatus());

      // Lưu vào database
      transcriptionService.saveTranscriptionResult(result);

      if ("completed".equals(result.getStatus())) {
        log.info("✅ Transcription completed successfully");
        log.info("   Total segments: {}", result.getTotalSegments());

        // Log transcript details
        logTranscript(result);

      } else if ("failed".equals(result.getStatus())) {
        log.error("❌ Transcription failed for meeting {}: {}",
                result.getMeetingId(), result.getError());
      }

    } catch (Exception e) {
      log.error("❌ Error handling transcription result: {}", e.getMessage(), e);
    }
  }

  private void logTranscript(TranscriptionResult result) {
    try {
      log.info("==================== TRANSCRIPT ====================");
      log.info("Meeting ID: {}", result.getMeetingId());
      log.info("Total Segments: {}", result.getTotalSegments());
      log.info("===================================================");

      if (result.getTranscript() != null && !result.getTranscript().isEmpty()) {
        for (int i = 0; i < result.getTranscript().size(); i++) {
          TranscriptSegment segment = result.getTranscript().get(i);
          log.info("[{}] Speaker: {} | Time: {:.2f}s - {:.2f}s",
                  i + 1,
                  segment.getSpeaker(),
                  segment.getStart(),
                  segment.getEnd()
          );
          log.info("    Text: {}", segment.getText());
          log.info("    Words count: {}",
                  segment.getWords() != null ? segment.getWords().size() : 0);
          log.info("---------------------------------------------------");
        }

        // Log as JSON for easy copy
        String jsonTranscript = objectMapper.writerWithDefaultPrettyPrinter()
                .writeValueAsString(result.getTranscript());
        log.info("Full Transcript JSON:\n{}", jsonTranscript);
      } else {
        log.warn("No transcript segments found");
      }

      log.info("===================================================");

    } catch (Exception e) {
      log.error("Error logging transcript: {}", e.getMessage());
    }
  }
}