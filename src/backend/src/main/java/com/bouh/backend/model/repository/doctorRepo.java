package com.bouh.backend.model.repository;
import com.bouh.backend.model.Dto.doctorDto;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;
import com.google.cloud.firestore.DocumentReference;
import java.util.concurrent.ExecutionException;


@Slf4j // for log debugging
@Repository
public class doctorRepo {

    // Spring Boot will inject the globally created Firestore bean (from Config)
    private final Firestore firestore;

    public doctorRepo(Firestore firestore) {
        this.firestore = firestore;
    }

    public void createDoctor(String uid, doctorDto dto) {
        try {
            firestore
                    .collection("doctors")
                    .document(uid)
                    .set(dto)
                    .get(); // wait for completion (important for error visibility)

        } catch (Exception e) {
            // Log with context (VERY important for debugging)
            log.error("Failed to create doctor profile for uid={}", uid, e);

            // Re-throw so higher layers can react
            throw new RuntimeException("Failed to create doctor profile", e);
        }
    }

    public doctorDto findByUid(String uid) {
        try {
            DocumentSnapshot snapshot = firestore
                    .collection("doctors")
                    .document(uid)
                    .get()
                    .get();

            if (snapshot.exists()) {
                // Maps the doctor document into doctorDto
                return snapshot.toObject(doctorDto.class);
            }

            return null;

        } catch (Exception e) {
            log.error("Failed to fetch doctor for uid={}", uid, e);
            throw new RuntimeException("Doctor fetch failed", e);
        }
    }

    /**
     * Read doctor document from doctors/{doctorId}.
     * Returns name, areaOfKnowledge, profilePhotoURL.
     */
    public doctorDto findById(String doctorId)
            throws ExecutionException, InterruptedException {

        DocumentReference ref =
                firestore.collection("doctors").document(doctorId);

        DocumentSnapshot doc = ref.get().get();

        if (doc == null || !doc.exists()) {
            return null;
        }

        doctorDto dto = new doctorDto();
        dto.setDoctorId(doctorId);
        dto.setName(getString(doc, "name"));
        dto.setAreaOfKnowledge(getString(doc, "areaOfKnowledge"));
        dto.setProfilePhotoURL(getString(doc, "profilePhotoURL"));

        return dto;
    }

    private static String getString(DocumentSnapshot doc, String field) {
        Object value = doc.get(field);
        return value == null ? null : value.toString();
    }
}