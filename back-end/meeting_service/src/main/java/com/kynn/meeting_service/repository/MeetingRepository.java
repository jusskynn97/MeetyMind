package com.kynn.meeting_service.repository;

import com.kynn.meeting_service.entity.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface MeetingRepository extends JpaRepository<Meeting, UUID> {
  Meeting findByMeetingIdAndDate(UUID meetingId, LocalDate date);
  List<Meeting> findAllByCreatedByAndDate(UUID uid, LocalDate date);
  List<Meeting> findAllByMeetingIdInAndDate(List<UUID> meetingIds, LocalDate date);
}
