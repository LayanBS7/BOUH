package com.bouh.backend.service.serviceImp;

import com.bouh.backend.model.PatientDto;
import com.bouh.backend.service.serviceInterface.PatientService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class PatientServiceImpl implements PatientService {

    @Override
    public PatientDto create(PatientDto dto) {
        return dto; // later connect repository + entity
    }

    @Override
    public List<PatientDto> getAll() {
        return new ArrayList<>();
    }

    @Override
    public PatientDto getById(Long id) {
        return new PatientDto();
    }
}
