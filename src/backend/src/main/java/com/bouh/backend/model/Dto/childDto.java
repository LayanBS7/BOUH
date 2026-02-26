package com.bouh.backend.model.Dto;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class childDto {
    private String childId;
    private String name;
    private LocalDate dateOfBirth;
    private String gender;
    private List<drawingDto> drawings;
}
