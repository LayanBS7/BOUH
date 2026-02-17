package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;
import java.util.List;

/**
 * Doctor update for multiple days.
 * Used by PUT endpoint.
 */
@Data
public class AvailabilityScheduleUpdateDto {
    private List<AvailabilityDayUpdateDto> days;
}
