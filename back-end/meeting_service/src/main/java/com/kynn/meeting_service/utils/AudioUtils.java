package com.kynn.meeting_service.utils;

import lombok.extern.slf4j.Slf4j;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;

import java.io.File;

@Slf4j
public class AudioUtils {

  /**
   * Lấy độ dài của audio file tính bằng giây
   */
  public static Double getAudioDuration(String filePath) {
    try {
      File audioFile = new File(filePath);
      AudioFile f = AudioFileIO.read(audioFile);
      int durationInSeconds = f.getAudioHeader().getTrackLength();

      log.info("Audio duration for {}: {} seconds", filePath, durationInSeconds);
      return (double) durationInSeconds;

    } catch (Exception e) {
      log.error("Error reading audio duration from {}: {}", filePath, e.getMessage());
      return null;
    }
  }
}