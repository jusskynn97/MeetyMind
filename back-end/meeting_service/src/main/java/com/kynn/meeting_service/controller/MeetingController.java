package com.kynn.meeting_service.controller;


import com.kynn.meeting_service.dto.request.CreateMeetingRequest;
import com.kynn.meeting_service.dto.response.ApiResponse;
import com.kynn.meeting_service.dto.response.MeetingDTO;
import com.kynn.meeting_service.dto.response.TranscriptResponseDTO;
import com.kynn.meeting_service.entity.Meeting;
import com.kynn.meeting_service.services.MeetingService;
import com.kynn.meeting_service.services.TranscriptionService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/meeting")
@RequiredArgsConstructor
public class MeetingController {

  private static final Logger log = LoggerFactory.getLogger(MeetingController.class);
  private final MeetingService meetingService;
  private final TranscriptionService transcriptionService;

  @GetMapping("/test-api")
  public ApiResponse<String> testApi() {
    return ApiResponse.<String>builder()
            .code(HttpStatus.OK.value())
            .message("Successful")
            .data("Meeting Service is running")
            .build();
  }

  @PostMapping("/create")
  public ApiResponse<String> createMeeting(@RequestBody CreateMeetingRequest createMeetingRequest, @RequestHeader("Authorization") String authHeader) {
    meetingService.createMeeting(createMeetingRequest, authHeader);

    log.info("Create meeting request: {}", createMeetingRequest);

    return ApiResponse.<String>builder()
            .code(HttpStatus.OK.value())
            .message("Successful")
            .data("Meeting is created")
            .build();
  }

  @GetMapping("/get")
  public ApiResponse<List<MeetingDTO>> getMeetings(@RequestHeader("Authorization") String authHeader, @RequestParam LocalDate date) {
    // Do Something
    log.info("Get meetings request: {}", date);
    List<MeetingDTO> meetingDTOs = meetingService.getMeetings(authHeader, date);

    return ApiResponse.<List<MeetingDTO>>builder()
            .code(HttpStatus.OK.value())
            .message("Successful")
            .data(meetingDTOs)
            .build();
  }

  @GetMapping("/get-detail/{meetingId}")
  public ApiResponse<String> getDetailMeeting(@RequestHeader("Authorization") String authHeader, @PathVariable String meetingId) {
    // Do Something
    log.info(meetingId);

    return ApiResponse.<String>builder()
            .code(HttpStatus.OK.value())
            .message("Successful")
            .data("Meeting is got")
            .build();
  }

  @PostMapping("/upload-audio/{meetingId}")
  public ApiResponse<String> uploadAudio(
          @PathVariable String meetingId,
          @RequestParam("file") MultipartFile file,
          @RequestHeader("Authorization") String authHeader) {

    log.info("Upload audio request for meeting: {}", meetingId);

    try {
      String filePath = meetingService.uploadAudioForMeeting(meetingId, file);

      return ApiResponse.<String>builder()
              .code(HttpStatus.OK.value())
              .message("Audio uploaded successfully. Transcription queued.")
              .data(filePath)
              .build();

    } catch (IllegalArgumentException e) {
      log.error("Invalid request: {}", e.getMessage());
      return ApiResponse.<String>builder()
              .code(HttpStatus.BAD_REQUEST.value())
              .message(e.getMessage())
              .build();

    } catch (Exception e) {
      log.error("Error uploading audio: {}", e.getMessage(), e);
      return ApiResponse.<String>builder()
              .code(HttpStatus.INTERNAL_SERVER_ERROR.value())
              .message("Failed to upload audio")
              .build();
    }
  }

  @GetMapping("/transcript/{meetingId}")
  public ApiResponse<TranscriptResponseDTO> getTranscript(
          @PathVariable String meetingId,
          @RequestHeader("Authorization") String authHeader) {

    log.info("Get transcript request for meeting: {}", meetingId);

    try {
      UUID meetingUUID = UUID.fromString(meetingId);
      TranscriptResponseDTO transcript = transcriptionService.getTranscriptionByMeetingId(meetingUUID);

      if (transcript == null) {
        // Trả về success với data null thay vì 404
        return ApiResponse.<TranscriptResponseDTO>builder()
                .code(HttpStatus.OK.value())
                .message("No transcript found")
                .data(null)
                .build();
      }

      return ApiResponse.<TranscriptResponseDTO>builder()
              .code(HttpStatus.OK.value())
              .message("Successful")
              .data(transcript)
              .build();

    } catch (RuntimeException e) {
      log.error("Transcription not found: {}", e.getMessage());
      return ApiResponse.<TranscriptResponseDTO>builder()
              .code(HttpStatus.NOT_FOUND.value())
              .message(e.getMessage())
              .build();

    } catch (Exception e) {
      log.error("Error getting transcript: {}", e.getMessage(), e);
      return ApiResponse.<TranscriptResponseDTO>builder()
              .code(HttpStatus.INTERNAL_SERVER_ERROR.value())
              .message("Failed to get transcript")
              .build();
    }
  }
}
