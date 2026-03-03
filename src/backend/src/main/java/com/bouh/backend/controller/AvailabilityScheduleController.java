package com.bouh.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityScheduleUpdateDto;
import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityScheduleDto;
import com.bouh.backend.service.AvailabilityScheduleService;
import org.springframework.security.core.Authentication;


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
        Authentication authentication,
        @RequestParam String from, 
        @RequestParam String to
    ) {
        return scheduleService.getSchedule(authentication.getName(), from, to);
    }

    @PutMapping
    public ResponseEntity<Void> update(
        Authentication authentication,
        @RequestBody AvailabilityScheduleUpdateDto request
    )
    {
        scheduleService.updateSchedule(authentication.getName(), request);
        return ResponseEntity.ok().build();
    }
}
