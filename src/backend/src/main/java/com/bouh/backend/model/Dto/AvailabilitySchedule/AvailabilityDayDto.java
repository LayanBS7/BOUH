package com.bouh.backend.model.Dto.AvailabilitySchedule;

//import lombok.Data;
import java.util.List;

import com.google.cloud.firestore.annotation.Exclude;
/**
 * Represents availability of a single day.
 * slots: List<Boolean> size = 10
 */
//@Data
public class AvailabilityDayDto {
    private String date;
    private List<AvailabilityStoredSlotDto> slots; 

    @Exclude
    public String getDate() { return date; }

    @Exclude
    public void setDate(String date) { this.date = date; }

    public List<AvailabilityStoredSlotDto> getSlots() { return slots; }
    public void setSlots(List<AvailabilityStoredSlotDto> slots) { this.slots = slots; }
}
