package com.bouh.backend.model.Dto;

import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for a single document in Firestore subcollection doctors/{doctorId}/timeSlots/{timeSlotId}.
 * Source: time slot document fields startTime, endTime.
 * Used by doctorRepo.findTimeSlot to return start/end time for an appointment.
 */
@Data
@NoArgsConstructor
public class timeSlotDto {
    private String startTime;
    private String endTime;
}
