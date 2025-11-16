package com.kynn.user_service.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.GenericGenerator;

import java.time.Instant;
import java.util.UUID;

@Entity
@Data
@Table(name = "users")
public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID uid;

  @OneToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "accountId", nullable = false)
  private Account account;

  private String firstName;
  private String lastName;
  private String email;
  private String phone;
  private String address;
  private String avatarUrl;

  @CreationTimestamp
  private Instant createdAt;
}
