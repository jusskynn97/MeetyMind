package com.kynn.meeting_service.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

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
}
