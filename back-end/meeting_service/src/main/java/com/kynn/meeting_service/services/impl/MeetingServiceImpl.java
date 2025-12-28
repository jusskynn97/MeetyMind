package com.kynn.meeting_service.services.impl;

import com.kynn.meeting_service.client.UserClient;
import com.kynn.meeting_service.dto.request.CreateMeetingRequest;
import com.kynn.meeting_service.dto.response.ApiResponse;
import com.kynn.meeting_service.dto.response.MeetingDTO;
import com.kynn.meeting_service.dto.share.UserDTO;
import com.kynn.meeting_service.entity.Meeting;
import com.kynn.meeting_service.mapper.MeetingMapper;
import com.kynn.meeting_service.repository.MeetingRepository;
import com.kynn.meeting_service.security.JwtUtil;
import com.kynn.meeting_service.services.MeetingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MeetingServiceImpl implements MeetingService {

  private final JwtUtil jwtUtil;
  private final UserClient userClient;
  private final MeetingRepository meetingRepository;
  private final MeetingMapper meetingMapper;


  @Override
  public void createMeeting(CreateMeetingRequest createMeetingRequest, String authHeader) {

//    if (authHeader == null || !authHeader.startsWith("Bearer ")) throw new RuntimeException("Missing token");
//    String token = authHeader.substring(7);
//    if (!jwtUtil.validateToken(token)) throw new RuntimeException("Invalid token");
//    UUID id = jwtUtil.extractId(token);

    ApiResponse<UserDTO> response = userClient.me(authHeader);
    UserDTO userDTO = response.getData();
    Meeting meeting = meetingMapper.toEntity(createMeetingRequest);
    meeting.setCreatedBy(userDTO.getUid());
    meetingRepository.save(meeting);

    System.out.println("Meeting is created by " + userDTO.getFirstName());
  }

  @Override
  public List<MeetingDTO> getMeetings(String authHeader, LocalDate date) {
    ApiResponse<UserDTO> response = userClient.me(authHeader);
    UserDTO userDTO = response.getData();



    return null;
  }

}
