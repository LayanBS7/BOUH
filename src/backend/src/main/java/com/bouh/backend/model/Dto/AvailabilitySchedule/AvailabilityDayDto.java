package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;
import java.util.List;
/**
 * Represents availability of a single day.
 */
@Data
public class AvailabilityDayDto {
    private String date;
    private List<AvailabilityStoredSlotDto> slots; 
}
