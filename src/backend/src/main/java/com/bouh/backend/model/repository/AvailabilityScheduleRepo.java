package com.bouh.backend.model.repository;

import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityDayDto;
import com.google.cloud.firestore.*;
import org.springframework.stereotype.Repository;

import java.util.*;


@Repository
public class AvailabilityScheduleRepo {
    private final Firestore firestore;

    private static final String SCHEDULE_ID= "current"; //container doc id

    public AvailabilityScheduleRepo(Firestore firestore) {
        this.firestore = firestore;
    }

     /**
     * Builds reference to one day doc.
     * doctors/{doctorId}/schedule/current/TimeSlots/{yyyy-MM-dd} 🔁🟢
     */
    private DocumentReference dayDoc(String doctorId, String isoDate) {
        // isoDate must be yyyy-MM-dd
        return firestore.collection("doctors")
                .document(doctorId)
                .collection("schedule")
                .document(SCHEDULE_ID)
                .collection("TimeSlots")
                .document(isoDate);
    }

    /**
     * Read one day doc. (The date is the docID)
    */
    public AvailabilityDayDto getDay(String doctorId, String isoDate) {
        try {
            DocumentSnapshot snap = dayDoc(doctorId, isoDate).get().get();

            if (!snap.exists()) {
                return null; 
            }

            AvailabilityDayDto day = snap.toObject(AvailabilityDayDto.class);
            if (day == null) return null;

            day.setDate(isoDate); //date comes from docID

            if(day.getSlots()==null) day.setSlots(new ArrayList<>());
        
            return day;

        } catch (Exception e) {
            throw new RuntimeException("Error reading availability day", e);
        }
    }

    /**
     * Fetch all existing day docs between [fromIso..toIso]. 
     *
     * We return Map<dateDocId, AvailabilityDayDto> for fast lookup in service. 
     */
    public Map<String, AvailabilityDayDto> getDaysInRangeMap(String doctorId, String fromIso, String toIso) {
        try {
            QuerySnapshot snap = firestore.collection("doctors")
                    .document(doctorId)
                    .collection("schedule")
                    .document(SCHEDULE_ID)
                    .collection("TimeSlots")
                    .whereGreaterThanOrEqualTo(FieldPath.documentId(), fromIso)
                    .whereLessThanOrEqualTo(FieldPath.documentId(), toIso)
                    .get()
                    .get();

            Map<String, AvailabilityDayDto> result = new HashMap<>();

            for (DocumentSnapshot doc : snap.getDocuments()) {
                AvailabilityDayDto day = doc.toObject(AvailabilityDayDto.class);
                if (day != null) {
                    String date = doc.getId(); // docId is the date
                    day.setDate(date);         // set date for frontend
                    if (day.getSlots() == null) day.setSlots(new ArrayList<>()); // safety
                    result.put(date, day);
                }
            }

            return result;

        } catch (Exception e) {
            throw new RuntimeException("Error reading availability range", e);
        }
    }

    /**
     * Update multiple days at once.
     *
     * Uses Firestore batch:
     * - Faster
     * - Cleaner
     * - All updates committed together
     *
     * If document does not exist -> it will be created.
     * If exists -> it will be updated.
     */
    public void update(String doctorId, Map<String, AvailabilityDayDto> daysByDate) {

        try {
            WriteBatch batch = firestore.batch();

            for (Map.Entry<String, AvailabilityDayDto> entry : daysByDate.entrySet()) {
                String isoDate = entry.getKey();        // doc id = date
                AvailabilityDayDto day = entry.getValue();

                batch.set(
                        dayDoc(doctorId, isoDate),
                        day,
                        SetOptions.merge()
                );
            }

            // Commit all writes at once
            batch.commit().get();

        } catch (Exception e) {
            throw new RuntimeException("Error updating availability schedule", e);
        }
    }
    
}
