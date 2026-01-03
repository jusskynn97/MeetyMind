package com.kynn.meeting_service.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateMeetingRequest {
  private String title;
  private String description;
  private String location;
  private LocalDate date;
  private LocalTime startTime;
  private LocalTime endTime;

  // Using for MeetingParticipant
  private List<String> participants;
//  private List<UUID> groupId;
}
