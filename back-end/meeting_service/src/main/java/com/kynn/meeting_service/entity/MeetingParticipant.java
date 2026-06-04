package com.kynn.meeting_service.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Data
@Table(name = "meeting_participant")
public class MeetingParticipant {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID meetingParticipantId;

  private UUID meetingId;

  @Enumerated(EnumType.STRING)
  private SourceType sourceType;
  // uid if sourceType is manual | groupId if sourceType is group
  private UUID sourceId;

  @Enumerated(EnumType.STRING)
  private Permission permission;

  @CreationTimestamp
  private Timestamp joinAt;
  private Timestamp leaveAt;

}
