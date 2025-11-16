package com.kynn.user_service.controller;

import com.kynn.user_service.dto.request.LoginRequest;
import com.kynn.user_service.dto.request.RegisterRequest;
import com.kynn.user_service.dto.resonse.ApiResponse;
import com.kynn.user_service.dto.resonse.LoginResponse;
import com.kynn.user_service.dto.resonse.UserDTO;
import com.kynn.user_service.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

  private final AuthService authService;

  @PostMapping("/register")
  public ApiResponse<String> register(@RequestBody RegisterRequest request) {
    try {
      authService.register(request);
      return ApiResponse.success();
    } catch (RuntimeException e) {
      return ApiResponse.error(HttpStatus.INTERNAL_SERVER_ERROR.value(), e.getMessage());
    }
  }

  @PostMapping("/login")
  public ApiResponse<LoginResponse> login(@RequestBody LoginRequest req) {
    var resp = authService.login(req.getEmail(), req.getPassword());
    return ApiResponse.<LoginResponse>builder()
            .code(HttpStatus.OK.value())
            .message("Login Successful")
            .data(resp)
            .build();
  }

}
