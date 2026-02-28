package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;

/**
 * Slot used in GET response DTO for frontend.
 *
 * Returned as:
 * { "index": 2, "booked": true }
 *
 * Note:
 * - Not stored directly in Firestore in the new schema.
 * - It is derived from TimeSlots/{index}.status:
 *   BOOKED -> booked=true, AVAILABLE -> booked=false
 */

@Data
public class AvailabilityStoredSlotDto {
    private int index;        // 0..9 (mapped using TimeSlotConfig)
    private boolean booked;   // true = booked, false = free
}
