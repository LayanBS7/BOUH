package com.bouh.backend.model.Dto;

import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for reading doctor data from Firestore collection "doctors" (document by doctorId).
 * Source: doctors/{doctorId} — fields name, areaOfKnowledge, profilePhotoURL.
 * Used by DoctorRepo.findById to supply doctor info when building upcoming appointment response.
 */
@Data
@NoArgsConstructor
public class doctorDto {
    private String doctorId;
    private String name;
    private String areaOfKnowledge;
    private String profilePhotoURL;
}
