package com.kynn.meeting_service.repository;

import com.kynn.meeting_service.entity.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MeetingRepository extends JpaRepository<Meeting, UUID> {
}
