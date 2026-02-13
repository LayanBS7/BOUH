package com.bouh.backend.controller;

import com.bouh.backend.model.PatientDto;
import com.bouh.backend.service.serviceInterface.PatientService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/patients")
public class PatientController {

    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    @PostMapping
    public PatientDto create(@RequestBody PatientDto dto) {
        return patientService.create(dto);
    }

    @GetMapping
    public List<PatientDto> getAll() {
        return patientService.getAll();
    }

    @GetMapping("/{id}")
    public PatientDto getById(@PathVariable Long id) {
        return patientService.getById(id);
    }
}
