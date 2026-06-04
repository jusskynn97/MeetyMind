package com.kynn.meeting_service.repository;

import com.kynn.meeting_service.entity.Transcription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface TranscriptionRepository extends JpaRepository<Transcription, UUID> {
  Optional<Transcription> findByMeetingId(UUID meetingId);
}