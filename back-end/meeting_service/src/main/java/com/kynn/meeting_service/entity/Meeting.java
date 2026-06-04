package com.kynn.meeting_service.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Date;
import java.util.UUID;

@Entity
@Data
@Table(name = "meeting")
public class Meeting {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID meetingId;

  private UUID createdBy;

  private String title;
  private String description;
  private String location;
  private LocalDate date;
  private LocalTime startTime;
  private LocalTime endTime;


  @CreationTimestamp
  private Instant createdAt;
  private Instant updatedAt;

}
