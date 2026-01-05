package com.kynn.meeting_service.services.impl;

import com.kynn.meeting_service.dto.rabbitmq.TranscriptionResult;
import com.kynn.meeting_service.dto.response.TranscriptResponseDTO;
import com.kynn.meeting_service.entity.Transcription;
import com.kynn.meeting_service.repository.TranscriptionRepository;
import com.kynn.meeting_service.services.CloudinaryService;
import com.kynn.meeting_service.services.TranscriptionService;
import com.kynn.meeting_service.utils.AudioUtils;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TranscriptionServiceImpl implements TranscriptionService {

  private final TranscriptionRepository transcriptionRepository;
  private final CloudinaryService cloudinaryService;

  @Override
  @Transactional
  public void saveTranscriptionResult(TranscriptionResult result) {
    try {
      UUID meetingId = UUID.fromString(result.getMeetingId());

      Transcription transcription = transcriptionRepository.findByMeetingId(meetingId)
              .orElseThrow(() -> new RuntimeException("Transcription not found for meeting: " + meetingId));

      if ("completed".equals(result.getStatus())) {
        transcription.setSegments(result.getTranscript());
        transcription.setTotalSegments(result.getTotalSegments());
        transcription.setStatus(Transcription.TranscriptionStatus.UPLOADING);

//        if (result.getTranscript() != null && !result.getTranscript().isEmpty()) {
//          transcription.setTotalDuration(
//                  result.getTranscript().get(result.getTranscript().size() - 1).getEnd()
//          );
//        }
        transcriptionRepository.save(transcription);
        try {
          String audioPath = transcription.getAudioPath();
          String cloudinaryUrl = cloudinaryService.uploadAudioFile(audioPath, meetingId.toString());

          // Extract public ID từ URL
          String publicId = extractPublicIdFromUrl(cloudinaryUrl);
          transcription.setStatus(Transcription.TranscriptionStatus.COMPLETED);
          transcription.setCompletedAt(LocalDateTime.now());
          transcription.setAudioPath(cloudinaryUrl);

          log.info("✅ Transcription completed and uploaded to Cloudinary for meeting: {}", meetingId);

          // Xóa file local sau khi upload thành công
          deleteLocalFile(audioPath);

        } catch (Exception e) {
          log.error("❌ Error uploading to Cloudinary: {}", e.getMessage(), e);
          transcription.setStatus(Transcription.TranscriptionStatus.FAILED);
          transcription.setErrorMessage("Failed to upload to Cloudinary: " + e.getMessage());
        }

        transcription.setCompletedAt(LocalDateTime.now());
        transcription.setStatus(Transcription.TranscriptionStatus.COMPLETED);
        log.info("Transcription completed and saved for meeting: {}", meetingId);

      } else if ("failed".equals(result.getStatus())) {
        transcription.setStatus(Transcription.TranscriptionStatus.FAILED);
        transcription.setErrorMessage(result.getError());
        log.error("Transcription failed for meeting {}: {}", meetingId, result.getError());
      }

      transcriptionRepository.save(transcription);

    } catch (Exception e) {
      log.error("Error saving transcription result: {}", e.getMessage(), e);
      throw new RuntimeException("Failed to save transcription result", e);
    }
  }

  @Override
  public TranscriptResponseDTO getTranscriptionByMeetingId(UUID meetingId) {
    Optional<Transcription> transcriptionOpt = transcriptionRepository.findByMeetingId(meetingId);

    // Nếu không tìm thấy, return null thay vì throw exception
    if (transcriptionOpt.isEmpty()) {
      log.info("📭 No transcription found for meeting: {}", meetingId);
      return null;
    }

    Transcription transcription = transcriptionOpt.get();

    return TranscriptResponseDTO.builder()
            .transcriptId(transcription.getTranscriptId())
            .meetingId(transcription.getMeetingId())
            .status(transcription.getStatus())
            .segments(transcription.getSegments())
            .audioPath(transcription.getAudioPath())
            .totalSegments(transcription.getTotalSegments())
            .totalDuration(transcription.getTotalDuration())
            .language(transcription.getLanguage())
            .errorMessage(transcription.getErrorMessage())
            .createdAt(transcription.getCreatedAt())
            .updatedAt(transcription.getUpdatedAt())
            .completedAt(transcription.getCompletedAt())
            .build();
  }

  @Override
  @Transactional
  public void createInitialTranscription(UUID meetingId, String audioPath) {
    // Kiểm tra xem đã có transcription chưa
    if (transcriptionRepository.findByMeetingId(meetingId).isPresent()) {
      log.warn("Transcription already exists for meeting: {}", meetingId);
      return;
    }

    Transcription transcription = new Transcription();
    transcription.setMeetingId(meetingId);
    transcription.setAudioPath(audioPath);
    transcription.setStatus(Transcription.TranscriptionStatus.QUEUED);

    Double duration = AudioUtils.getAudioDuration(audioPath);
    if (duration != null) {
      transcription.setTotalDuration(duration);
      log.info("Audio duration: {} seconds", duration);
    } else {
      log.warn("Could not determine audio duration for: {}", audioPath);
    }

    transcriptionRepository.save(transcription);
    log.info("Initial transcription created for meeting: {}", meetingId);
  }

  private String extractPublicIdFromUrl(String url) {
    try {
      // Extract phần sau "/upload/"
      String[] parts = url.split("/upload/");
      if (parts.length > 1) {
        String afterUpload = parts[1];
        // Remove file extension
        int lastDotIndex = afterUpload.lastIndexOf('.');
        if (lastDotIndex > 0) {
          return afterUpload.substring(0, lastDotIndex);
        }
        return afterUpload;
      }
      return null;
    } catch (Exception e) {
      log.error("Error extracting public ID from URL: {}", e.getMessage());
      return null;
    }
  }

  /**
   * Xóa file local sau khi upload thành công
   */
  private void deleteLocalFile(String filePath) {
    try {
      Path path = Paths.get(filePath);
      if (Files.exists(path)) {
        Files.delete(path);
        log.info("🗑️ Local file deleted: {}", filePath);
      }
    } catch (Exception e) {
      log.warn("⚠️ Could not delete local file {}: {}", filePath, e.getMessage());
    }
  }
}