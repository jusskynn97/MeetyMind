package com.kynn.meeting_service.services;

import com.kynn.meeting_service.dto.request.CreateMeetingRequest;
import com.kynn.meeting_service.dto.response.MeetingDTO;

import java.time.LocalDate;
import java.util.List;

public interface MeetingService {

  void createMeeting(CreateMeetingRequest createMeetingRequest, String authHeader);

  List<MeetingDTO> getMeetings(String authHeader, LocalDate date);
}
