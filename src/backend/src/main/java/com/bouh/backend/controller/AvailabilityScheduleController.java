package com.bouh.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityScheduleUpdateDto;
import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityScheduleDto;
import com.bouh.backend.service.AvailabilityScheduleService;

@RestController
@RequestMapping("/api/doctors/{doctorID}/doctorAvailability")
public class AvailabilityScheduleController {
    
    private final AvailabilityScheduleService scheduleService;

    public AvailabilityScheduleController(AvailabilityScheduleService scheduleService)
    {
        this.scheduleService=scheduleService;
    }

    @GetMapping
    public AvailabilityScheduleDto get(
        @PathVariable String doctorID,
        @RequestParam String from, 
        @RequestParam String to
    ) {
        return scheduleService.getSchedule(doctorID, from, to);
    }

    @PutMapping
    public ResponseEntity<Void> update(
        @PathVariable String doctorID,
        @RequestBody AvailabilityScheduleUpdateDto request
    )
    {
        scheduleService.updateSchedule(doctorID, request);
        return ResponseEntity.ok().build();
    }
}
