package com.kynn.user_service.dto.resonse;

import com.kynn.user_service.entity.Account;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.data.convert.ReadingConverter;

import java.time.Instant;
import java.util.UUID;
@Data
@RequiredArgsConstructor
public class UserDTO {
  private UUID uid;
//  private Account account;
  private String firstName;
  private String lastName;
  private String email;
  private String phone;
  private String address;
  private String avatarUrl;
  private Instant createdAt;

}
