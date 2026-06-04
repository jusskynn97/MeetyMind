package com.kynn.meeting_service.dto.share;

import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@RequiredArgsConstructor
public class UserDTO {
  private UUID uid;
  private String firstName;
  private String lastName;
  private String email;
  private String phone;
  private String address;
  private String avatarUrl;
  private Instant createdAt;

}
