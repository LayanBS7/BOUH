package com.bouh.backend.model.repository;
import com.bouh.backend.model.Dto.doctorDto;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.auth.FirebaseAuth;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import com.google.firebase.cloud.StorageClient;
import com.google.cloud.storage.Bucket;
import com.google.cloud.storage.Blob;

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
            // to ensure full write of all fields
            WriteBatch batch = firestore.batch();

            DocumentReference doctorRef = firestore.collection("doctors").document(uid);

            Map<String, Object> doctorData = new HashMap<>();

            doctorData.put("name", dto.getName() != null ? dto.getName() : "");
            doctorData.put("email", dto.getEmail());
            doctorData.put("gender", dto.getGender());
            doctorData.put("areaOfKnowledge", dto.getAreaOfKnowledge());
            doctorData.put("qualifications", cleanQualifications(dto.getQualifications()));
            doctorData.put("yearsOfExperience", dto.getYearsOfExperience());
            doctorData.put("scfhsNumber", dto.getScfhsNumber());
            doctorData.put("iban", dto.getIban());
            doctorData.put("averageRating", 0.0);
            doctorData.put("profilePhotoURL", dto.getProfilePhotoURL());
            doctorData.put("registrationStatus", "PENDING");
            doctorData.put("fcmToken", null);

            batch.set(doctorRef, doctorData);
            batch.commit().get();

        } catch (Exception e) {
            log.error("Failed to create doctor profile for uid={}", uid, e);
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
            log.error("Failed to fetch doctor for uid={}", uid);
            log.error("Exception type: {}", e.getClass().getName());
            log.error("Message: {}", e.getMessage());
            throw new RuntimeException("Doctor fetch failed", e);
        }
    }

    
    /**
     * Read doctor document from doctors/{doctorId}.
     * Returns name, areaOfKnowledge, profilePhotoURL.
     * --------REMOVE ON DONE------------
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

    private List<String> cleanQualifications(List<String> qualifications) {
        if (qualifications == null)
            return List.of();

        return qualifications.stream()
                .map(String::trim)
                .filter(q -> !q.isEmpty())
                .limit(5) // safety limit
                .toList();
    }

    public String deleteDoctor(String uid) {
        try {

            doctorDto doctor = findByUid(uid);
            if (doctor == null) {
                throw new RuntimeException("Doctor not found. Aborting deletion.");
            }

            // check if no upcoming exists to allow account delete
            if (!deleteAccountAppointments(uid)) {
                return "upcoming-appointment-found";
            }

            DocumentReference doctorRef = firestore.collection("doctors").document(uid);

            // delete doctor profile image if exists
            String ImagePathToDelete = doctor.getProfilePhotoURL();
            if (ImagePathToDelete != null) {
                deleteAccountProfileImage(ImagePathToDelete);
            }

            firestore.recursiveDelete(doctorRef).get();

            // delete Firebase Authentication account
            FirebaseAuth.getInstance().deleteUser(uid);

            return "deleted";
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete doctor account", e);
        }
    }

    public void deleteAccountProfileImage(String ImagePath) {

        Bucket bucket = StorageClient.getInstance().bucket("bouh-94761.firebasestorage.app");
        Blob blob = bucket.get(ImagePath);

        if (blob != null) {
            blob.delete();
            log.info("Image deleted successfully: " + ImagePath);
        } else {
            log.error("image not found " + ImagePath);
        }

    }

    private Boolean deleteAccountAppointments(String uid) throws Exception {

        Timestamp now = Timestamp.now();

        // fetch the frist upcoming appointemnt
        ApiFuture<QuerySnapshot> upcomingFuture = firestore.collection("appointments")
                .whereEqualTo("doctorId", uid)
                .whereGreaterThan("startDateTime", now)
                .limit(1)
                .get();

        // if doctor has upcomings, abort account deletion
        if (!upcomingFuture.get().isEmpty()) {
            return false;
        }

        // delete all appointments for this doctor
        ApiFuture<QuerySnapshot> allAppointmentsFuture = firestore.collection("appointments")
                .whereEqualTo("doctorId", uid)
                .get();

        List<QueryDocumentSnapshot> documents = allAppointmentsFuture.get().getDocuments();
        for (QueryDocumentSnapshot doc : documents) {
            doc.getReference().delete().get();
        }
        return true;
    }
}