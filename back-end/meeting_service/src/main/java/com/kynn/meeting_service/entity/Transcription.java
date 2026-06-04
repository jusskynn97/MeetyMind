package com.kynn.meeting_service.entity;

import com.kynn.meeting_service.dto.rabbitmq.TranscriptSegment;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.Type;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Data
@Table(name = "transcription")
public class Transcription {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  @Column(name = "transcript_id")
  private UUID transcriptId;

  @Column(name = "meeting_id", nullable = false, unique = true)
  private UUID meetingId;

  @Column(name = "audio_path")
  private String audioPath;

  @Column(name = "status", nullable = false)
  @Enumerated(EnumType.STRING)
  private TranscriptionStatus status;

  @Type(JsonType.class)
  @Column(name = "segments", columnDefinition = "jsonb")
  private List<TranscriptSegment> segments;

  @Column(name = "total_segments")
  private Integer totalSegments;

  @Column(name = "total_duration")
  private Double totalDuration; // Tổng thời lượng (seconds)

  @Column(name = "language")
  private String language; // Ngôn ngữ phát hiện được

  @Column(name = "error_message")
  private String errorMessage;

  @Column(name = "created_at", nullable = false)
  private LocalDateTime createdAt;

  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  @Column(name = "completed_at")
  private LocalDateTime completedAt;

  @PrePersist
  protected void onCreate() {
    createdAt = LocalDateTime.now();
    if (status == null) {
      status = TranscriptionStatus.QUEUED;
    }
  }

  @PreUpdate
  protected void onUpdate() {
    updatedAt = LocalDateTime.now();
  }

  public enum TranscriptionStatus {
    QUEUED,         // Đã gửi vào queue
    PROCESSING,
    UPLOADING,// Đang xử lý transcription
    COMPLETED,      // Hoàn thành
    FAILED          // Thất bại
  }



}
