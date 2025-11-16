package com.kynn.user_service.dto.resonse;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ApiResponse<T> {
  int code;
  String message;
  T data;

  public static <T> ApiResponse<T> success(T result) {
    return new ApiResponse<>(200, "Success", result);
  }

  public static <T> ApiResponse<T> success() {
    return new ApiResponse<>(200, "Success", null);
  }

  public static <T> ApiResponse<T> error(int code, String message) {
    return new ApiResponse<>(code, message, null);
  }
}