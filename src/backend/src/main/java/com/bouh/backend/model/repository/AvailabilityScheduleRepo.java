package com.bouh.backend.model.repository;

import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityDayDto;
import com.google.cloud.firestore.*;
import org.springframework.stereotype.Repository;

import java.util.*;


@Repository
public class AvailabilityScheduleRepo {
    private final Firestore firestore;

    public AvailabilityScheduleRepo(Firestore firestore) {
        this.firestore = firestore;
    }

    private DocumentReference dayDoc(String doctorId, String isoDate) {
        // isoDate must be yyyy-MM-dd
        return firestore.collection("doctorAvailability")
                .document(doctorId)
                .collection("timeSlots")
                .document(isoDate);
    }

    /**
     * Read booked and doctor slots for a given doctor and date.
    */
    public AvailabilityDayDto getDay(String doctorId, String isoDate) {
        try {
            DocumentSnapshot snap = dayDoc(doctorId, isoDate).get().get();

            if (!snap.exists()) {
                return null; // no doc for this day
            }

            return snap.toObject(AvailabilityDayDto.class);

        } catch (Exception e) {
            throw new RuntimeException("Error reading availability day", e);
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
    public void update(String doctorId, List<AvailabilityDayDto> days) {

        try {
            WriteBatch batch = firestore.batch();

            for (AvailabilityDayDto day : days) {

                batch.set(
                        dayDoc(doctorId, day.getDate()),
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
