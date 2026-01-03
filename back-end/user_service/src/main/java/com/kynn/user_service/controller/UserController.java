package com.kynn.user_service.controller;

import com.kynn.user_service.dto.request.RegisterRequest;
import com.kynn.user_service.dto.resonse.ApiResponse;
import com.kynn.user_service.dto.resonse.UserDTO;
import com.kynn.user_service.entity.User;
import com.kynn.user_service.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

  private final UserService userService;

  @GetMapping("/me")
  public ApiResponse<UserDTO> me(@RequestHeader("Authorization") String authHeader) {
    UserDTO userDTO = userService.getProfileFromToken(authHeader);
    return ApiResponse.<UserDTO>builder()
            .code(HttpStatus.OK.value())
            .message("Login Successful")
            .data(userDTO)
            .build();
  }

  @GetMapping("/get-uid-email")
  public ApiResponse<UUID> findUidByEmail(@RequestHeader("Authorization") String authHeader, @RequestParam String email) {
    UUID uid = userService.getUidFromEmail(authHeader, email);
    return ApiResponse.<UUID>builder()
            .code(HttpStatus.OK.value())
            .message("Login Successful")
            .data(uid)
            .build();
  }

}
