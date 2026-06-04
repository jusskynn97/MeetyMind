package com.kynn.meeting_service.dto.rabbitmq;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TranscriptWord {
  @JsonProperty("word")
  private String word;

  @JsonProperty("start")
  private Double start;

  @JsonProperty("end")
  private Double end;

  @JsonProperty("score")
  private Double score;

  @JsonProperty("speaker")
  private String speaker;
}