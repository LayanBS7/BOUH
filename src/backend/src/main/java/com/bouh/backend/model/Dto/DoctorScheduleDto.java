package com.bouh.backend.model.Dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityStoredSlotDto;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DoctorScheduleDto {

    private String date;
    private List<AvailabilityStoredSlotDto> timeSlots;

}