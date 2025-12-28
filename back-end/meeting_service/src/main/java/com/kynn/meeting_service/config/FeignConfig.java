package com.kynn.meeting_service.config;

import feign.RequestInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Configuration
@RequiredArgsConstructor
public class FeignConfig {

  @Bean
  public RequestInterceptor requestInterceptor() {
    return requestTemplate -> {
      ServletRequestAttributes attrs =
              (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();

      if (attrs == null) return;

      HttpServletRequest request = attrs.getRequest();

      // --- 1. Forward Authorization Header ---
      String authHeader = request.getHeader("Authorization");
      if (authHeader != null && !authHeader.isBlank()) {
        requestTemplate.header("Authorization", authHeader);
      }

      // --- 2. Forward Cookie (nếu cần) ---
      if (request.getCookies() != null) {
        StringBuilder cookieHeader = new StringBuilder();
        for (var cookie : request.getCookies()) {
          cookieHeader.append(cookie.getName())
                  .append("=")
                  .append(cookie.getValue())
                  .append("; ");
        }
        if (!cookieHeader.isEmpty()) {
          cookieHeader.setLength(cookieHeader.length() - 2); // Remove "; "
          requestTemplate.header("Cookie", cookieHeader.toString());
        }
      }
    };
  }
}
