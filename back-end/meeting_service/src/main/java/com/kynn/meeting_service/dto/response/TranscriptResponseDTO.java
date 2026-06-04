package com.kynn.meeting_service.dto.response;

import com.kynn.meeting_service.dto.rabbitmq.TranscriptSegment;
import com.kynn.meeting_service.entity.Transcription;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TranscriptResponseDTO {
  private UUID transcriptId;
  private UUID meetingId;

  private String audioPath;

  private Transcription.TranscriptionStatus status;

  private List<TranscriptSegment> segments;

  private Integer totalSegments;

  private Double totalDuration;

  private String language;

  private String errorMessage;

  private LocalDateTime createdAt;

  private LocalDateTime updatedAt;

  private LocalDateTime completedAt;
}
