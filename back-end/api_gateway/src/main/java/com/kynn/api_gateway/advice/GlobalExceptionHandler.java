package com.kynn.api_gateway.advice;
import com.kynn.api_gateway.model.*;
import com.kynn.api_gateway.response.ApiResponseDTO;
import jakarta.ws.rs.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {
    /**
     * Handles custom application exceptions.
     *
     * @param ex the AppException to handle
     * @return a ResponseEntity containing the ApiResponseDTO with error details
     */
    @ExceptionHandler(AppException.class)
    public ResponseEntity<ApiResponseDTO<String>> handleAppException(AppException ex) {
        ApiResponseDTO<String> response = new ApiResponseDTO<>();
        ErrorMessage error = ex.getErrorCode();
        response.setCode(error.getCode());
        response.setMessage(error.getMessage());
        return new ResponseEntity<>(response, error.getHttpStatus());
    }
    /**
     * Handles NotFoundException thrown by Spring Cloud Gateway when a service is unavailable.
     *
     * @param ex the NotFoundException to handle
     * @return a ResponseEntity containing the ApiResponseDTO with service unavailability details
     */
    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ApiResponseDTO<String>> handleServiceUnavailableException(NotFoundException ex) {
        ApiResponseDTO<String> response = new ApiResponseDTO<>();
        response.setCode(ErrorMessage.SERVICE_UNAVAILABLE.getCode());

        // Extract service name from error message
        String errorMessage = ex.getMessage();
        String serviceName = "a service";

        if (errorMessage.contains("Unable to find instance for")) {
            serviceName = errorMessage.substring(errorMessage.lastIndexOf(" ") + 1);
            response.setMessage("Service " + serviceName + " is currently unavailable. Please try again later.");
        } else
            response.setMessage("A required service is temporarily unavailable. Please try again later.");
        return new ResponseEntity<>(response, HttpStatus.SERVICE_UNAVAILABLE);
    }
}