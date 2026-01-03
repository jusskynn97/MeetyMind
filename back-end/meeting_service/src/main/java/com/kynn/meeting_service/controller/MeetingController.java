package com.kynn.meeting_service.controller;


import com.kynn.meeting_service.dto.request.CreateMeetingRequest;
import com.kynn.meeting_service.dto.response.ApiResponse;
import com.kynn.meeting_service.dto.response.MeetingDTO;
import com.kynn.meeting_service.entity.Meeting;
import com.kynn.meeting_service.services.MeetingService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/meeting")
@RequiredArgsConstructor
public class MeetingController {

  private static final Logger log = LoggerFactory.getLogger(MeetingController.class);
  private final MeetingService meetingService;

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
}
