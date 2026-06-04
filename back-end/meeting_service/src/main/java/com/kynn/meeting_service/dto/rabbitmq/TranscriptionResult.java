package com.kynn.meeting_service.dto.rabbitmq;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TranscriptionResult {
  @JsonProperty("meetingId")
  private String meetingId;

  @JsonProperty("status")
  private String status;

  @JsonProperty("transcript")
  private List<TranscriptSegment> transcript;

  @JsonProperty("totalSegments")
  private Integer totalSegments;

  @JsonProperty("error")
  private String error;
}
