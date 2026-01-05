package com.kynn.meeting_service.mapper;

import com.kynn.meeting_service.dto.response.TranscriptResponseDTO;
import com.kynn.meeting_service.entity.Transcription;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface TranscriptMapper {
  TranscriptResponseDTO toDTO(Transcription transcription);

}
