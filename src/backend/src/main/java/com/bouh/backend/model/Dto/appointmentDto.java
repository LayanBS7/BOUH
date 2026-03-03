package com.bouh.backend.model.Dto;
import com.google.cloud.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class appointmentDto {
    private String appointmentId;
    private String caregiverId;
    private String doctorId;
    private String childId;
    private String date;
    private String timeSlotId;
    private String startTime;
    //REMOVE (date and startTime) on done and only on the last one, un comment it when done
    private String endTime;
    private String meetingLink;
    private Long amount;
    /** 0 = absent, 1 = present. */
    private Integer status;
    private String paymentIntentId;
    //private Timestamp startDateTime; <<Here this is what we use and send to the db better for logic computations>>
}
