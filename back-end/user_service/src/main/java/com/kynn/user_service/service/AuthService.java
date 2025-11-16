package com.kynn.user_service.service;

import com.kynn.user_service.dto.request.RegisterRequest;
import com.kynn.user_service.dto.resonse.LoginResponse;
import com.kynn.user_service.dto.resonse.UserDTO;
import com.kynn.user_service.entity.Account;
import com.kynn.user_service.entity.User;
import com.kynn.user_service.mapper.UserMapper;
import com.kynn.user_service.repository.AccountRepository;
import com.kynn.user_service.repository.UserRepository;
import com.kynn.user_service.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {
  private final AccountRepository accountRepository;
  private final UserRepository userRepository;
  private final JwtUtil jwtUtil;
  private final UserMapper userMapper;
  private final BCryptPasswordEncoder passwordEncoder;

  @Transactional
  public void register(RegisterRequest request) {
      if (accountRepository.findByEmail(request.getEmail()).isPresent()) {
          throw new RuntimeException("Email existed");
      }
      Account account = new Account();
      account.setEmail(request.getEmail());
      account.setPassword(passwordEncoder.encode(request.getPassword()));
      account = accountRepository.save(account);

      // Tạo user
      User user = new User();
      user.setAccount(account);
      user.setEmail(request.getEmail());
      user.setFirstName(request.getFirstName());
      user.setLastName(request.getLastName());
      user.setPhone(request.getPhone());
      user.setAddress(request.getAddress());
      userRepository.save(user);
    }

  public LoginResponse login(String email, String password) {
    Account acc = accountRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Invalid credentials"));
    if (!BCrypt.checkpw(password, acc.getPassword())) throw new RuntimeException("Invalid credentials");

    User user = userRepository.findByAccount_AccountId(acc.getAccountId()).orElse(null);
    UserDTO userDTO = userMapper.toDTO(user);
    String token = jwtUtil.generateToken(email, acc.getAccountId());
    return new LoginResponse(token, userDTO);
  }
}

