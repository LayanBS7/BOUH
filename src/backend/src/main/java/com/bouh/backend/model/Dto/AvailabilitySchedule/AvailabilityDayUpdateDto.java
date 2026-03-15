package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;
import java.util.List;
/**
 * Doctor update for ONE day. 
 *
 * Why needed?
 * - Doctor only chooses which slots are offered (by index). 
 *
 * Example PUT item:
 * {
 *   "date": "2026-02-20",
 *   "offeredSlotIndexes": [0,2,5]
 * }
 */
@Data
public class AvailabilityDayUpdateDto {
        private String date;                 // yyyy-MM-dd
        private List<Integer> offeredSlotIndexes;   // size = TimeSlotConfig.SLOT_COUNT
}
