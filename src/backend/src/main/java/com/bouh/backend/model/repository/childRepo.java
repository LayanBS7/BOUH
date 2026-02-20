package com.bouh.backend.model.repository;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import org.springframework.stereotype.Repository;

import java.util.concurrent.ExecutionException;

/**
 * Repository for Firestore path caregivers/{caregiverId}/children/{childId}.
 * Caller: AppointmentsService. Used to resolve child name for appointment card.
 */
@Repository
public class childRepo {

    private final Firestore firestore;

    public childRepo(Firestore firestore) {
        this.firestore = firestore;
    }

    /**
     * Read child document from caregivers/{caregiverId}/children/{childId}. Returns the "name" field.
     * Data source: Firestore path caregivers/{caregiverId}/children/{childId}.
     */
    public String findChildName(String caregiverId, String childId) throws ExecutionException, InterruptedException {
        DocumentReference ref = firestore.collection("caregivers").document(caregiverId)
                .collection("children").document(childId);
        DocumentSnapshot doc = ref.get().get();
        if (doc == null || !doc.exists()) {
            return null;
        }
        Object v = doc.get("name");
        return v == null ? null : v.toString();
    }
}
