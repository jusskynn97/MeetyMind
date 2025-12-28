package com.kynn.meeting_service.dto.response;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingDTO {
  private UUID meetingId;

  private UUID createdBy;

  private String title;
  private String description;
  private String location;
  private LocalDate date;
  private LocalTime startTime;
  private LocalTime endTime;


  private Instant createdAt;
  private Instant updatedAt;

}
