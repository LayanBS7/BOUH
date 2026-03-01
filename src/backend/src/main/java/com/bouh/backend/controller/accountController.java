package com.bouh.backend.controller;
import com.bouh.backend.model.Dto.*;
import com.bouh.backend.service.accounts.accountsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/accounts")
public class accountController {

    private final accountsService accountService;
    public accountController(accountsService accountService) {
        this.accountService = accountService;
    }

    @PostMapping("/register/caregivers")
    public ResponseEntity<Map<String, Object>> createCaregiver(
            @RequestBody caregiverDto dto,
            Authentication authentication) {

        if (authentication == null || authentication.getName() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of(
                            "error", "UNAUTHORIZED",
                            "message", "User is not authenticated"
                    ));
        }
        //who is making this request
        String uid = authentication.getName();
        log.info("createCaregiver called for uid={}", uid);

        accountService.createCaregiverAccount(uid, dto);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }


    @PostMapping("/register/doctors")
    public ResponseEntity<Map<String, Object>> createDoctor(
            @RequestBody doctorDto dto,
            Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of(
                            "error", "UNAUTHORIZED",
                            "message", "User is not authenticated"
                    ));
        }
        log.info("createDoctor called for uid={}", authentication.getName());

        //who is making this request
        String uid = authentication.getName();

        accountService.createDoctorAccount(uid, dto);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }


    @GetMapping("/me")
    public ResponseEntity<?> me(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            //resolving users roles
            String uid = authentication.getName();
            return ResponseEntity.ok(
                    accountService.resolveAuthState(uid)
            );
        } catch (Exception e) {
            log.error("Failed to resolve role", e);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to resolve role");
        }
    }

    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteCaregiver(Authentication authentication){

        //who is making this request
        String uid = authentication.getName();
        log.info("called for user uid={}", uid);
        try {
        //if caregiver or doctor
        if(accountService.resolveAuthState(uid).getRole().equals("caregiver"))
            accountService.deleteCaregiverAccount(uid);
        else accountService.deleteDoctorAccount(uid);

        return ResponseEntity.status(HttpStatus.OK).build();
        } catch (Exception e) {
            log.error("Failed delete account", e);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed deleting the account");
        }
    }

}
