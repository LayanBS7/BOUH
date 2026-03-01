package com.bouh.backend.model.repository;
import com.bouh.backend.model.Dto.doctorDto;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.auth.FirebaseAuth;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
            //to ensure full write of all fields
            WriteBatch batch = firestore.batch();

            DocumentReference doctorRef =
                    firestore.collection("doctors").document(uid);


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
            doctorData.put("profilePhotoURL", null);
            doctorData.put("registrationStatus", "PENDING");
            doctorData.put("fcmToken", null);

            batch.set(doctorRef, doctorData);

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
        if (qualifications == null) return List.of();

        return qualifications.stream()
                .map(String::trim)
                .filter(q -> !q.isEmpty())
                .limit(5) //safety limit
                .toList();
    }

    public void deleteDoctor(String uid) {
        try {
            DocumentReference doctorRef =
                    firestore.collection("doctors").document(uid);

            //to apply recursive delete on all info of the related account
            deleteAccountAppointments(uid);

            //delete all TimeSlots
            CollectionReference slotsRef =
                    doctorRef.collection("schedule")
                            .document("current")
                            .collection("TimeSlots");
            deleteAccountSchedule(slotsRef);

            //delete "current" document
            doctorRef.collection("schedule")
                    .document("current")
                    .delete()
                    .get();

            //delete Doctor
            doctorRef.delete().get();

            //delete Firebase Authentication account
            FirebaseAuth.getInstance().deleteUser(uid);

        } catch (Exception e) {
            log.error("Failed to delete doctor account for uid={}", uid, e);
            throw new RuntimeException("Failed to delete doctor account", e);
        }
    }

    private void deleteAccountAppointments(String uid) throws Exception {
        ApiFuture<QuerySnapshot> future = firestore.collection("appointments")
                .whereEqualTo("doctorId", uid)
                .get();

        List<QueryDocumentSnapshot> documents = future.get().getDocuments();

        //loops on every appointment related to that doctor
        for (QueryDocumentSnapshot doc : documents) {
            doc.getReference().delete().get();
        }
    }

    private void deleteAccountSchedule(CollectionReference collection) throws Exception {

        QuerySnapshot snapshot = collection.get().get();

        for (DocumentSnapshot doc : snapshot.getDocuments()) {
            doc.getReference().delete().get();
        }
    }
}