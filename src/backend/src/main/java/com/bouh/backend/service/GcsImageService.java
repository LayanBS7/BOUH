package com.bouh.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.Bucket;
import com.google.cloud.ReadChannel;
import com.google.firebase.cloud.StorageClient;
import java.io.InputStream;
import java.nio.channels.Channels;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

@Slf4j
@Service
public class GcsImageService {

    private final Bucket bucket;
    private final String bucketName;

    public GcsImageService(@Value("${gcs.bucket.name}") String bucketName) {
        this.bucket = StorageClient.getInstance().bucket(bucketName);
        this.bucketName = bucketName;
    }

    /**
     * Generate public download URL
     */
    public String generateDownloadUrl(String imagePath) {

        if (imagePath == null || imagePath.isBlank()) {
            throw new IllegalArgumentException("Invalid image path");
        }

        return String.format(
                "https://storage.googleapis.com/%s/%s",
                bucketName,
                imagePath);
    }

    /**
     * Download image (streaming)
     */
    public BufferedImage downloadImage(String imagePath) throws Exception {

        // Fetch blob reference (no download yet)
        Blob blob = bucket.get(imagePath);

        if (blob == null) {
            throw new RuntimeException("Image not found: " + imagePath);
        }

        // Stream the image instead of loading full byte[]
        // - Lower memory usage
        // - Better for large files / high concurrency
        // - Starts decoding while downloading
        try (ReadChannel reader = blob.reader();
                InputStream inputStream = Channels.newInputStream(reader)) {

            return ImageIO.read(inputStream);
        }
    }

    /**
     * Delete image
     */
    public void deleteImage(String imagePath) {

        if (imagePath == null || imagePath.isBlank()) {
            log.error("Invalid image path");
            return;
        }

        Blob blob = bucket.get(imagePath);

        if (blob != null) {
            blob.delete();
            log.info("Image deleted: {}", imagePath);
        } else {
            log.warn("Image not found: {}", imagePath);
        }
    }
}