package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;
import java.util.List;
/**
 * Represents availability of a single day.
 * slots: List<Boolean> size = 10
 */
@Data
public class AvailabilityDayDto {
    private String date;
    private List<Boolean> slots;
}
