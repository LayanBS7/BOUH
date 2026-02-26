package com.bouh.backend.model.Dto;
import lombok.Data;
import java.util.List;

@Data
public class caregiverDto {
    private String caregiverId;
    private String name;
    private String email;
    private String fcmToken;
    private List<childDto> children;
}
