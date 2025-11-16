package com.kynn.user_service.repository;

import com.kynn.user_service.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
  Optional<User> findByAccount_AccountId(UUID accountId);
}
