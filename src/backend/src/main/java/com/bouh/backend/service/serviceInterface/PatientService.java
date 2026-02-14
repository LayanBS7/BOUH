package com.bouh.backend.service.serviceInterface;

import com.bouh.backend.model.PatientDto;
import java.util.List;

public interface PatientService {
    PatientDto create(PatientDto dto);
    List<PatientDto> getAll();
    PatientDto getById(Long id);
}
