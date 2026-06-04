package com.kynn.meeting_service.repository;

import com.kynn.meeting_service.entity.MeetingParticipant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MeetingParticipantRepository extends JpaRepository<MeetingParticipant, UUID> {
  List<MeetingParticipant> findAllBySourceId(UUID sourceId);
}
