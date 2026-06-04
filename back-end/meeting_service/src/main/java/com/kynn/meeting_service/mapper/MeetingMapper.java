package com.kynn.meeting_service.mapper;

import com.kynn.meeting_service.dto.request.CreateMeetingRequest;
import com.kynn.meeting_service.dto.response.MeetingDTO;
import com.kynn.meeting_service.entity.Meeting;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface MeetingMapper {
  Meeting toEntity(CreateMeetingRequest createMeetingRequest);
  Meeting toEntity(MeetingDTO meetingDTO);

  MeetingDTO toDTO(Meeting meeting);
  List<MeetingDTO> toDTOs(List<Meeting> meetings);
}

