package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;
import java.util.List;

/**
 * Represents schedule for a date range (multiple days).
 *
 * Used as GET response.
 */
@Data
public class AvailabilityScheduleDto {
    private List<AvailabilityDayDto> days;
}
