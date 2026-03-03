package com.bouh.backend.service;

import com.bouh.backend.config.TimeSlotConfig;
import com.bouh.backend.model.Dto.AvailabilitySchedule.*;
import com.bouh.backend.model.repository.AvailabilityScheduleRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Availability Schedule Service
 *
 * Responsible for:
 * - Loading doctor's availability schedule
 * - Updating availability for multiple days
 *
 * Notes:
 * - Time slots are fixed (4:00 PM -> 9:00 PM, 30 minutes, total = 10 slots)
 * - Editing allowed only from today up to 2 months ahead
 */
@Service
public class AvailabilityScheduleService {

    private final AvailabilityScheduleRepo scheduleRepo;

    public AvailabilityScheduleService(AvailabilityScheduleRepo scheduleRepo) //in spring boot constructor runs automatically
    {
        this.scheduleRepo=scheduleRepo;
    }
    
    //Allowed editing window = today + 2 months
    private LocalDate today() { return LocalDate.now(); }
    private LocalDate maxAllowed() { return LocalDate.now().plusMonths(2); }


    private void validateDateEditable(String isoDate) {
        if (isoDate == null) {
            throw new IllegalStateException("date cannot be null.");
        }

        LocalDate d;
        try {
            d = LocalDate.parse(isoDate); // expects yyyy-MM-dd
        } catch (Exception e) {
            throw new IllegalStateException("Invalid date format. Expected yyyy-MM-dd.");
        }

        if (d.isBefore(today())) throw new IllegalStateException("Cannot edit past dates.");
        if (d.isAfter(maxAllowed())) throw new IllegalStateException("Cannot edit beyond 2 months.");
    }

    // Validation: indexes must be unique and 0..SLOT_COUNT-1
    private void validateIndexes(List<Integer> indexes) {
        if (indexes == null) throw new IllegalStateException("offeredSlotIndexes cannot be null.");

        Set<Integer> seen = new HashSet<>();
        for (Integer idx : indexes) {
            if (idx == null) throw new IllegalStateException("slot index cannot be null.");
            if (idx < 0 || idx >= TimeSlotConfig.SLOT_COUNT)
                throw new IllegalStateException("slot index out of range: " + idx);
            if (!seen.add(idx))
                throw new IllegalStateException("duplicate slot index: " + idx);
        }
    }
    /**
     * Get Doctor Availability Schedule (for a date range)
     *
     * Logic:
     * - Returns every day in [from..to] inclusive
     * - Each day contains ONLY offered slots (may be empty list)
     * - Missing day doc => slots=[]
     * - We do a single query to fetch all existing docs for performance 
     *
     * Example:
     * GET window from=2026-02-01 to=2026-03-31
     *
     * @return {
     *   "days": [
     *     {
     *       "date": "2026-02-20",
     *       "slots": [
     *         { "index": 0, "booked": false },
     *         { "index": 2, "booked": true }
     *       ]
     *     },
     *     {
     *       "date": "2026-02-21",
     *       "slots": []
     *     }
     *   ]
     * }
     */

    public AvailabilityScheduleDto getSchedule(String doctorID, String fromIso, String toIso)
    {
        LocalDate from= LocalDate.parse(fromIso);
        LocalDate to= LocalDate.parse(toIso);


        LocalDate startOfCurrentMonth = LocalDate.of(today().getYear(), today().getMonth(), 1);
            if (from.isBefore(startOfCurrentMonth)) from = startOfCurrentMonth;
            if (to.isAfter(maxAllowed())) to = maxAllowed();

            //Pull all existing day docs once (keyed by date docId)
            Map<String, AvailabilityDayDto> storedByDate =
                scheduleRepo.getDaysInRangeMap(doctorID, from.toString(), to.toString());

            AvailabilityScheduleDto response = new AvailabilityScheduleDto();
             response.setDays(new ArrayList<>(storedByDate.values()));

            LocalDate cur=from;
            while(!cur.isAfter(to))
            {
                String date=cur.toString();
                AvailabilityDayDto day= storedByDate.get(date);

                if(day==null)
                {
                    day=new AvailabilityDayDto();
                    day.setDate(date);
                    day.setSlots(new ArrayList<>());
                }
                
                response.getDays().add(day);
                cur= cur.plusDays(1);

            }

        return response;
}


    /**
     * Update Doctor Availability (offered slots) for multiple days
     *
     * Purpose:
     * - Doctor selects which slot indexes are OFFERED for each day.
     * - Backend preserves the "booked" status for any already-booked offered slot.
     * - Backend prevents doctor from removing a slot that is already booked.
     *
     * Time Slot Rules:
     * - All doctors share the same fixed slots (4:00 PM → 9:00 PM, 30 minutes).
     * - SLOT_COUNT = 10
     * - Slot indexes are 0..9
     *
     * Logic:
     * - For each day in request:
     *   - Validate date is within editable window (today -> today + 2 months)
     *   - Validate indexes are unique and within range 0..9
     *   - Read existing day doc to know which offered slots are already booked
     *   - If request removes any booked slot -> reject
     *   - Save offered slots only (as objects {index, booked})
     *
     * Example Request Body:
     * {
     *   "days": [
     *     {
     *       "date": "2026-02-20",
     *       "offeredSlotIndexes": [0, 2, 5]
     *     },
     *     {
     *       "date": "2026-02-21",
     *       "offeredSlotIndexes": [1, 3]
     *     }
     *   ]
     * }
     *
     * @response
     * - 200 OK (no body) if update succeeds
     * - 400/500 with message if validation fails (e.g., removing a booked slot)
     */

    public void updateSchedule(String doctorID, AvailabilityScheduleUpdateDto request) {

        if (request == null || request.getDays() == null || request.getDays().isEmpty()) {
            throw new IllegalStateException("No days provided for update.");
        }

        // collect all dates first
        List<String> dates = new ArrayList<>();
        for (AvailabilityDayUpdateDto d : request.getDays()) {
            validateDateEditable(d.getDate());
            validateIndexes(d.getOfferedSlotIndexes());
            dates.add(d.getDate());
        }

        // single Firestore call instead of N calls
        Map<String, AvailabilityDayDto> existingByDate = scheduleRepo.getDaysByDates(doctorID, dates);

        Map<String, AvailabilityDayDto> toWrite = new HashMap<>();
        Set<String> toDelete = new HashSet<>();

        for (AvailabilityDayUpdateDto incoming : request.getDays()) {

            AvailabilityDayDto existing = existingByDate.get(incoming.getDate());

            Map<Integer, Boolean> existingBooked = new HashMap<>();
            if (existing != null && existing.getSlots() != null) {
                for (AvailabilityStoredSlotDto s : existing.getSlots()) {
                    existingBooked.put(s.getIndex(), s.isBooked());
                }
            }

            // prevent removing booked
            for (Map.Entry<Integer, Boolean> e : existingBooked.entrySet()) {
                int idx = e.getKey();
                boolean booked = Boolean.TRUE.equals(e.getValue());
                if (booked && !incoming.getOfferedSlotIndexes().contains(idx)) {
                    throw new IllegalStateException(
                        "Cannot remove a booked slot. date=" + incoming.getDate() + ", index=" + idx
                    );
                }
            }

            if (incoming.getOfferedSlotIndexes().isEmpty()) {
                toDelete.add(incoming.getDate());
                continue;
            }

            List<AvailabilityStoredSlotDto> newSlots = new ArrayList<>();
            for (int idx : incoming.getOfferedSlotIndexes()) {
                AvailabilityStoredSlotDto s = new AvailabilityStoredSlotDto();
                s.setIndex(idx);
                s.setBooked(Boolean.TRUE.equals(existingBooked.get(idx)));
                newSlots.add(s);
            }

            AvailabilityDayDto dayToStore = new AvailabilityDayDto();
            dayToStore.setSlots(newSlots);
            toWrite.put(incoming.getDate(), dayToStore);
        }

        scheduleRepo.update(doctorID, toWrite, toDelete);
    }
}
