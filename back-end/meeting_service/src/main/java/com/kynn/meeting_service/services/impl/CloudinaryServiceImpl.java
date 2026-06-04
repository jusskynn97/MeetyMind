package com.kynn.meeting_service.services.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.kynn.meeting_service.services.CloudinaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.File;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class CloudinaryServiceImpl implements CloudinaryService {

  private final Cloudinary cloudinary;

  @Override
  public String uploadAudioFile(String filePath, String meetingId) throws Exception {
    try {
      File file = new File(filePath);

      if (!file.exists()) {
        throw new RuntimeException("File not found: " + filePath);
      }

      log.info("Uploading audio to Cloudinary: {}", filePath);

      // Upload với options
      Map<String, Object> uploadParams = ObjectUtils.asMap(
              "resource_type", "video",
              "folder", "meetings/audio",
              "public_id", "meeting_" + meetingId,
              "overwrite", true,
              "use_filename", false
      );

      Map uploadResult = cloudinary.uploader().upload(file, uploadParams);

      String url = (String) uploadResult.get("secure_url");
      String publicId = (String) uploadResult.get("public_id");

      log.info("   Audio uploaded to Cloudinary successfully");
      log.info("   URL: {}", url);
      log.info("   Public ID: {}", publicId);

      return url;

    } catch (Exception e) {
      log.error(" Error uploading to Cloudinary: {}", e.getMessage(), e);
      throw new Exception("Failed to upload audio to Cloudinary: " + e.getMessage());
    }
  }

  @Override
  public void deleteFile(String publicId) throws Exception {
    try {
      log.info("Deleting file from Cloudinary: {}", publicId);

      Map deleteResult = cloudinary.uploader().destroy(publicId,
              ObjectUtils.asMap("resource_type", "video"));

      log.info("File deleted from Cloudinary: {}", deleteResult.get("result"));

    } catch (Exception e) {
      log.error("Error deleting from Cloudinary: {}", e.getMessage(), e);
      throw new Exception("Failed to delete file from Cloudinary: " + e.getMessage());
    }
  }
}