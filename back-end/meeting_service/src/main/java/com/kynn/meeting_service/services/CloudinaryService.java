package com.kynn.meeting_service.services;

import java.io.File;

public interface CloudinaryService {
  String uploadAudioFile(String filePath, String meetingId) throws Exception;
  void deleteFile(String publicId) throws Exception;
}