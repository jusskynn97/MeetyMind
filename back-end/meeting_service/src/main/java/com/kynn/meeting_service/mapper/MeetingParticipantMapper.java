package com.kynn.meeting_service.mapper;

import com.kynn.meeting_service.dto.response.MeetingParticipantDTO;
import com.kynn.meeting_service.entity.MeetingParticipant;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface MeetingParticipantMapper {
  List<MeetingParticipantDTO> toDTO (List<MeetingParticipant> meetingParticipants);
}
