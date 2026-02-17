package com.bouh.backend.model.Dto.AvailabilitySchedule;

import lombok.Data;
import java.util.List;

/**
 * Represents a schedule (multiple days).
 *
 * IMPORTANT:
 * - We use this DTO for BOTH:
 *   1) GET response (server -> frontend)
 *   2) PUT request  (frontend -> server)
 *
 * JSON shape:
 * {
 *   "days": [
 *     { "date": "2026-02-01", "slots": [true,false,...] },
 *     ...
 *   ]
 * }
 */
@Data
public class AvailabilityScheduleDto {
    private List<AvailabilityDayDto> days;
}
