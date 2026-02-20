package com.bouh.backend.model.repository;

import com.bouh.backend.model.Dto.doctorDto;
import com.bouh.backend.model.Dto.timeSlotDto;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import org.springframework.stereotype.Repository;

import java.util.concurrent.ExecutionException;

/**
 * Repository for Firestore collection "doctors" and subcollection timeSlots.
 * Caller: AppointmentsService. Used to resolve doctor info and slot start/end time.
 */
@Repository
public class doctorRepo {

    private final Firestore firestore;

    public doctorRepo(Firestore firestore) {
        this.firestore = firestore;
    }

    /**
     * Read doctor document from doctors/{doctorId}. Returns name, areaOfKnowledge, profilePhotoURL for response DTO.
     * Data source: Firestore path doctors/{doctorId}.
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

    /**
     * Read time slot from doctors/{doctorId}/timeSlots/{timeSlotId}. Returns startTime and endTime for display.
     * Data source: Firestore path doctors/{doctorId}/timeSlots/{timeSlotId}.
     */
    public timeSlotDto findTimeSlot(String doctorId, String timeSlotId)
            throws ExecutionException, InterruptedException {
        DocumentReference ref = firestore.collection("doctors").document(doctorId)
                .collection("timeSlots").document(timeSlotId);
        DocumentSnapshot doc = ref.get().get();
        if (doc == null || !doc.exists()) {
            return null;
        }
        timeSlotDto dto = new timeSlotDto();
        dto.setStartTime(getString(doc, "startTime"));
        dto.setEndTime(getString(doc, "endTime"));
        return dto;
    }

    private static String getString(DocumentSnapshot doc, String field) {
        Object v = doc.get(field);
        return v == null ? null : v.toString();
    }
}
