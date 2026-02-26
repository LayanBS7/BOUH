package com.bouh.backend.model.repository;
import com.bouh.backend.model.Dto.doctorDto;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;

@Slf4j //for log debugging
@Repository
public class doctorRepo {

    //springBoot on config it will inject the globally created FireStore bean (in Config File) into this Repo instance of fireStore
    private final Firestore firestore;
    public doctorRepo(Firestore firestore) {
        this.firestore = firestore; //set the instance so this repo use it
    }

    public void createDoctor(String uid, doctorDto Dto) {
        try {
            firestore
                    .collection("doctors")
                    .document(uid)
                    .set(Dto)
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
                //maps the doctor document into doctorDto
                return snapshot.toObject(doctorDto.class);
            }
            return null;

        } catch (Exception e) {
            log.error("Failed to fetch doctor for uid={}", uid, e);
            throw new RuntimeException("Doctor fetch failed", e);
        }
    }




import com.bouh.backend.model.Dto.doctorDto;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import org.springframework.stereotype.Repository;

import java.util.concurrent.ExecutionException;


@Repository
public class doctorRepo {

    private final Firestore firestore;

    public doctorRepo(Firestore firestore) {
        this.firestore = firestore;
    }

    /**
     * Read doctor document from doctors/{doctorId}. Returns name, areaOfKnowledge, profilePhotoURL for response DTO.
     */
    public doctorDto findById(String doctorId) throws ExecutionException, InterruptedException {
        DocumentReference ref = firestore.collection("doctors").document(doctorId);
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
        Object v = doc.get(field);
        return v == null ? null : v.toString();
    }
}
