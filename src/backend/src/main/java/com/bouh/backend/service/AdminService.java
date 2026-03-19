package com.bouh.backend.service;

import com.bouh.backend.model.Dto.accountManagment.accountResponseDto;
import com.bouh.backend.model.Dto.caregiverDto;
import com.bouh.backend.model.Dto.doctorDto;
import com.bouh.backend.model.repository.caregiverRepo;
import com.bouh.backend.model.repository.doctorRepo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class AdminService {

    private final doctorRepo doctorRepository;
    private final caregiverRepo caregiverRepository;
    private final EmailService emailService;

    public AdminService(doctorRepo doctorRepo, caregiverRepo caregiverRepo, EmailService emailService) {
        this.doctorRepository = doctorRepo;
        this.caregiverRepository = caregiverRepo;
        this.emailService = emailService;
    }

    public accountResponseDto deleteDoctor(String uid) {
        doctorDto doctor = doctorRepository.findByUid(uid);
        if (doctor == null) {
            return new accountResponseDto(false, "NOT_FOUND", "الطبيب غير موجود");
        }

        String email = doctor.getEmail();
        String name = doctor.getName();
        String result = doctorRepository.deleteDoctor(uid);

        switch (result) {
            case "deleted":
                emailService.sendAccountDeletionEmail(email, name);
                return new accountResponseDto(true, "ACCOUNT_DELETED", "تم حذف الحساب");
            case "upcoming-appointment-found":
                return new accountResponseDto(false, "HAS_UPCOMING_APPOINTMENTS",
                        "لا يمكن حذف الحساب لوجود مواعيد قادمة");
            default:
                return new accountResponseDto(false, "UNKNOWN_ERROR", "حدث خطأ غير متوقع");
        }
    }

    public accountResponseDto deleteCaregiver(String uid) {
        caregiverDto caregiver = caregiverRepository.findByUid(uid);
        if (caregiver == null) {
            return new accountResponseDto(false, "NOT_FOUND", "المستخدم غير موجود");
        }

        String email = caregiver.getEmail();
        String name = caregiver.getName();
        caregiverRepository.deleteCaregiver(uid);
        emailService.sendAccountDeletionEmail(email, name);
        return new accountResponseDto(true, "ACCOUNT_DELETED", "تم حذف الحساب");
    }

}
