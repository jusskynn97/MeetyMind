package com.kynn.user_service.service;

import com.kynn.user_service.dto.resonse.UserDTO;
import com.kynn.user_service.entity.Account;
import com.kynn.user_service.entity.User;
import com.kynn.user_service.mapper.UserMapper;
import com.kynn.user_service.repository.AccountRepository;
import com.kynn.user_service.repository.UserRepository;
import com.kynn.user_service.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

  private final JwtUtil jwtUtil;
  private final AccountRepository accountRepository;
  private final UserMapper userMapper;
  private final UserRepository userRepository;


  public UserDTO getProfileFromToken(String bearerToken) {
    if (bearerToken == null || !bearerToken.startsWith("Bearer ")) throw new RuntimeException("Missing token");
    String token = bearerToken.substring(7);
    if (!jwtUtil.validateToken(token)) throw new RuntimeException("Invalid token");
    UUID id = jwtUtil.extractId(token);
    Account acc = accountRepository.findById(id).orElseThrow(() -> new RuntimeException("Account not found"));
    User user = userRepository.findByAccount_AccountId(acc.getAccountId()).orElse(null);
    return userMapper.toDTO(user);
  }
}
