package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;

/**
 * Represents ONE offered slot. 
 *
 * Stored in:
 * doctors/{doctorId}/schedule/current/TimeSlots/{yyyy-MM-dd}
 *
 * Example:
 * { "index": 2, "booked": true }
 *
 * Notes:
 * - We store ONLY offered slots.
 * - booked=true means the slot is already booked. 
 */

@Data
public class AvailabilityStoredSlotDto {
    private int index;        // 0..9 (mapped using TimeSlotConfig)
    private boolean booked;   // true = booked, false = free
}
