package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;
import java.util.List;
/**
 * Only contains doctorSlots (no bookedSlots).
 */
@Data
public class AvailabilityDayUpdateDto {
        private String date;                 // yyyy-MM-dd
        private List<Boolean> doctorSlots;   // size = TimeSlotConfig.SLOT_COUNT
}
