package com.bouh.backend.model.Dto;
import com.google.cloud.firestore.annotation.DocumentId;
import lombok.Data;
import java.util.List;

@Data //setters,getters and constructors
public class childDto {
    @DocumentId
    private String childId;

    private String name;
    private String dateOfBirth; // "2018-05-12"
    private String gender;
    private List<drawingDto> drawings;
}
