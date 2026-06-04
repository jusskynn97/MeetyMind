package com.kynn.meeting_service.dto.response;

import com.kynn.meeting_service.entity.Permission;
import com.kynn.meeting_service.entity.SourceType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;
import java.util.UUID;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MeetingParticipantDTO {
  private UUID meetingParticipantId;

  private UUID meetingId;

  private SourceType sourceType;
  // uid if sourceType is manual | groupId if sourceType is group
  private UUID sourceId;

  private Permission permission;

  private Timestamp joinAt;
  private Timestamp leaveAt;

}


