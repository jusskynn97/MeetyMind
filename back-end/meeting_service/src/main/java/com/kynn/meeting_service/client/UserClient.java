package com.kynn.meeting_service.client;

import com.kynn.meeting_service.config.FeignConfig;
import com.kynn.meeting_service.dto.response.ApiResponse;
import com.kynn.meeting_service.dto.share.UserDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;

@FeignClient(name = "user-service", configuration = FeignConfig.class)
public interface UserClient {
  @GetMapping("/api/user/me")
  ApiResponse<UserDTO> me(@RequestHeader("Authorization") String authHeader);
}
