package com.kynn.meeting_service.services.impl;

import com.kynn.meeting_service.client.UserClient;
import com.kynn.meeting_service.dto.request.CreateMeetingRequest;
import com.kynn.meeting_service.dto.response.ApiResponse;
import com.kynn.meeting_service.dto.response.MeetingDTO;
import com.kynn.meeting_service.dto.share.UserDTO;
import com.kynn.meeting_service.entity.Meeting;
import com.kynn.meeting_service.entity.MeetingParticipant;
import com.kynn.meeting_service.entity.Permission;
import com.kynn.meeting_service.entity.SourceType;
import com.kynn.meeting_service.mapper.MeetingMapper;
import com.kynn.meeting_service.mapper.MeetingParticipantMapper;
import com.kynn.meeting_service.repository.MeetingParticipantRepository;
import com.kynn.meeting_service.repository.MeetingRepository;
import com.kynn.meeting_service.security.JwtUtil;
import com.kynn.meeting_service.services.MeetingService;
import com.kynn.meeting_service.services.TranscriptionService;
import com.kynn.meeting_service.services.rabbitmq.TranscriptionProducer;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.*;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class MeetingServiceImpl implements MeetingService {

  private final JwtUtil jwtUtil;
  private final UserClient userClient;
  private final MeetingRepository meetingRepository;
  private final MeetingParticipantRepository meetingParticipantRepository;
  private final MeetingMapper meetingMapper;
  private final MeetingParticipantMapper meetingParticipantMapper;
  private final TranscriptionProducer transcriptionProducer;
  private final TranscriptionService transcriptionService;

  @Value("${file.upload.dir:./uploads/meetings}")
  private String uploadDir;


  @Override
  @Transactional
  public void createMeeting(CreateMeetingRequest createMeetingRequest, String authHeader) {

//    if (authHeader == null || !authHeader.startsWith("Bearer ")) throw new RuntimeException("Missing token");
//    String token = authHeader.substring(7);
//    if (!jwtUtil.validateToken(token)) throw new RuntimeException("Invalid token");
//    UUID id = jwtUtil.extractId(token);

    ApiResponse<UserDTO> response = userClient.me(authHeader);
    UserDTO userDTO = response.getData();
    Meeting meeting = meetingMapper.toEntity(createMeetingRequest);
    meeting.setCreatedBy(userDTO.getUid());

    Meeting savedMeeting = meetingRepository.save(meeting);
    if (createMeetingRequest.getParticipants() != null) {
      for (String participantEmail : createMeetingRequest.getParticipants()) {
        MeetingParticipant meetingParticipant = new MeetingParticipant();
        meetingParticipant.setMeetingId(savedMeeting.getMeetingId());
        meetingParticipant.setSourceType(SourceType.MANUAL);
        meetingParticipant.setPermission(Permission.VIEW);
        UUID participantId = userClient.getUidFromEmail(authHeader, participantEmail).getData();
        meetingParticipant.setSourceId(participantId);
        meetingParticipantRepository.save(meetingParticipant);
      }
    }


    System.out.println("Meeting is created by " + userDTO.getFirstName());
  }

  @Override
  public List<MeetingDTO> getMeetings(String authHeader, LocalDate date) {

    UUID uid = userClient.me(authHeader).getData().getUid();

    List<UUID> participatedMeetingIds =
      meetingParticipantRepository.findAllBySourceId(uid)
        .stream()
        .map(MeetingParticipant::getMeetingId)
        .toList();

    List<MeetingDTO> participatedMeetings =
      meetingMapper.toDTOs(
        meetingRepository.findAllByMeetingIdInAndDate(
          participatedMeetingIds, date
        )
      );

    // 2️⃣ Meeting tạo
    List<MeetingDTO> createdMeetings =
      meetingMapper.toDTOs(
        meetingRepository.findAllByCreatedByAndDate(uid, date)
      );

    Map<UUID, MeetingDTO> uniqueMap = new LinkedHashMap<>();

    participatedMeetings.forEach(m ->
      uniqueMap.put(m.getMeetingId(), m)
    );

    createdMeetings.forEach(m ->
      uniqueMap.put(m.getMeetingId(), m)
    );

    participatedMeetings.clear();
    createdMeetings.clear();

    List<MeetingDTO> result = new ArrayList<>(uniqueMap.values());
    uniqueMap.clear();

    // 4️⃣ Set owner
    result.forEach(m ->
      m.setIsOwner(uid.equals(m.getCreatedBy()))
    );

    return result;
  }

  public String uploadAudioForMeeting(String meetingId, MultipartFile audioFile) {
    try {
      // Validate file
      if (audioFile.isEmpty()) {
        throw new IllegalArgumentException("Audio file is empty");
      }

      String[] allowedExtensions = {".mp3", ".wav", ".m4a", ".flac", ".ogg"};
      String originalFilename = audioFile.getOriginalFilename();
      String fileExtension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();

      boolean validExtension = false;
      for (String ext : allowedExtensions) {
        if (fileExtension.equals(ext)) {
          validExtension = true;
          break;
        }
      }

      if (!validExtension) {
        throw new IllegalArgumentException("Invalid file type. Allowed: mp3, wav, m4a, flac, ogg");
      }

      // Create upload directory if not exists
      Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
      if (!Files.exists(uploadPath)) {
        Files.createDirectories(uploadPath);
      }

      // Save file with unique name
      String filename = meetingId + "_" + UUID.randomUUID() + fileExtension;
      Path filePath = uploadPath.resolve(filename);
      audioFile.transferTo(filePath.toFile());

      String absolutePath = filePath.toAbsolutePath().toString();
      log.info("Audio file saved: {}", absolutePath);

      UUID meetingUUID = UUID.fromString(meetingId);
      transcriptionService.createInitialTranscription(meetingUUID, absolutePath);

      // Update meeting status
      // meetingRepository.updateStatus(meetingId, "processing");

      // Send to RabbitMQ queue
      transcriptionProducer.sendTranscriptionRequest(meetingId, absolutePath);

      return absolutePath;

    } catch (IOException e) {
      log.error("Error uploading audio file: {}", e.getMessage(), e);
      throw new RuntimeException("Failed to upload audio file", e);
    }
  }
}
