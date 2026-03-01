package com.bouh.backend.service.accounts;
import com.bouh.backend.model.Dto.*;
import com.bouh.backend.model.repository.caregiverRepo;
import com.bouh.backend.model.repository.doctorRepo;
import org.springframework.stereotype.Service;

@Service
public class accountsService {

    private final caregiverRepo caregiverRepository;
    private final doctorRepo doctorRepository;

    public accountsService(caregiverRepo caregiverRepo, doctorRepo doctorRepo) {
        this.caregiverRepository = caregiverRepo;
        this.doctorRepository = doctorRepo;
    }

    public void createCaregiverAccount(String uid, caregiverDto Dto) {
        try {
            caregiverRepository.createCaregiver(uid, Dto);
        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to create caregiver account for uid=" + uid, e
            );
        }
    }

    public void createDoctorAccount(String uid, doctorDto Dto) {
        try {
            doctorRepository.createDoctor(uid, Dto);
        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to create doctor account for uid=" + uid, e
            );
        }
    }

    public authDto resolveAuthState(String uid) {

        doctorDto doctor = doctorRepository.findByUid(uid);

        if (doctor!= null) {
            return new authDto(
                    uid,
                    "doctor",
                    doctor.getRegistrationStatus()
            );
        }
        if (caregiverRepository.existsByUid(uid)) {
            return new authDto(
                    uid,
                    "caregiver",
                    null
            );
        }
        //user with no profile (rare case)
        return new authDto(
                uid,
                null,
                null
        );
    }

    public void deleteCaregiverAccount(String uid) {
        try {
            caregiverRepository.deleteCaregiver(uid);
        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to delete caregiver account for uid=" + uid, e
            );
        }
    }

    public void deleteDoctorAccount(String uid) {
        try {
            doctorRepository.deleteDoctor(uid);
        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to delete doctor account for uid=" + uid, e
            );
        }
    }


}