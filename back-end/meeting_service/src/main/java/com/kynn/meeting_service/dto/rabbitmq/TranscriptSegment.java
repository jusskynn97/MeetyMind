package com.kynn.meeting_service.dto.rabbitmq;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TranscriptSegment {
  @JsonProperty("start")
  private Double start;

  @JsonProperty("end")
  private Double end;

  @JsonProperty("text")
  private String text;

  @JsonProperty("speaker")
  private String speaker;

  @JsonProperty("words")
  private List<TranscriptWord> words;
}