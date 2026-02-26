package com.bouh.backend.model.Dto;
import lombok.Data;
import java.time.Instant;


@Data //setters,getters and constructors
public class drawingDto {
    private String drawingId;
    private String imageURL;
    private String emotionClass;
    private String emotionalInterpretation;
    private Instant createdAt;
    private String doctorsIDSuggestion;
}
