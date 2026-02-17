package com.bouh.backend.service;

import com.bouh.backend.config.TimeSlotConfig;
import com.bouh.backend.model.Dto.AvailabilitySchedule.*;
import com.bouh.backend.model.repository.AvailabilityScheduleRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

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
 * - Past days are returned for display but NOT editable
 */
@Service
public class AvailabilityScheduleService {

    private final AvailabilityScheduleRepo scheduleRepo;

    public AvailabilityScheduleService(AvailabilityScheduleRepo scheduleRepo) //in spring boot constructor runs automatically
    {
        this.scheduleRepo=scheduleRepo;
    }
    
    //Allowed editing windo = today + 2 months
    private LocalDate today() { return LocalDate.now(); }
    private LocalDate maxAllowed() { return LocalDate.now().plusMonths(2); }

    private List<Boolean> defaultFalseSlots() {
        List<Boolean> list = new ArrayList<>();
        for (int i = 0; i < TimeSlotConfig.SLOT_COUNT; i++) list.add(false);
        return list;
    }

    private void validateSlotList(List<Boolean> slots, String fieldName) {
    if (slots == null) {
        throw new IllegalStateException(fieldName + " cannot be null.");
    }

    if (slots.size() != TimeSlotConfig.SLOT_COUNT) {
        throw new IllegalStateException(fieldName + " must have size " + TimeSlotConfig.SLOT_COUNT);
    }
}

private void validateDateEditable(String isoDate) {
    if (isoDate == null) throw new IllegalStateException("date cannot be null.");
    LocalDate d;
    try {
        d = LocalDate.parse(isoDate); // expects yyyy-MM-dd
    } catch (Exception e) {
        throw new IllegalStateException("Invalid date format (expected yyyy-MM-dd).");
    }
    if (d.isBefore(today())) throw new IllegalStateException("Cannot edit past dates.");
    if (d.isAfter(maxAllowed())) throw new IllegalStateException("Cannot edit beyond 2 months.");
}


    /**
     * Get Doctor Availability Schedule (for a date range)
     *
     * Logic:
     * - Returns schedule for requested window (usually current month + next month)
     * - If a day has no document in Firestore -> returns default (all slots = false)
     * - Past days are returned (UI will render them grey)
     * - Does NOT validate edit rules (read-only operation)
     *
     * Example:
     * GET window from=2026-02-01 to=2026-03-31
     *
     * @return {
     *   "days": [
     *     {
     *       "date": "2026-02-17",
     *       "doctorSlots": [true, false, true, false, false, false, false, false, false, false]
     *       "bookedSlots": [true, false, false, false, false, false, false, false, false, false]
     *     },
     *     {
     *       "date": "2026-02-18",
     *       "doctorSlots": [false, True, True, false, false, false, false, false, false, false]
     *       "bookedSlots": [false, True, True, false, false, false, false, false, false, false]

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

            //prepare response object
            AvailabilityScheduleDto response = new AvailabilityScheduleDto();
            response.setDays(new ArrayList<>());

            LocalDate cur = from;
            while (!cur.isAfter(to)) { //for every day between "from" and "to"
                String date = cur.toString(); // yyyy-MM-dd

                AvailabilityDayDto stored = scheduleRepo.getDay(doctorID, date); //call the repo to retireve the schedule from the database 
                
                List<Boolean> doctorSlots = (stored == null || stored.getDoctorSlots() == null)
                    ? defaultFalseSlots()
                    : stored.getDoctorSlots();
                List<Boolean> bookedSlots = (stored == null || stored.getBookedSlots() == null)
                    ? defaultFalseSlots()
                    : stored.getBookedSlots();

            //do this for every day (it is inside the loop)
            AvailabilityDayDto day = new AvailabilityDayDto();
                day.setDate(date);
                day.setDoctorSlots(doctorSlots);
                day.setBookedSlots(bookedSlots);

                response.getDays().add(day);
                cur = cur.plusDays(1);    
    }
   
    return response;

}
    /**
     * Update Doctor Availability Schedule
     *
     * Logic:
     * - Doctor can update multiple days before saving
     * - Each day must:
     *      - Be within allowed window (today -> today + 2 months)
     *      - Contain exactly 10 slots (4 PM -> 9 PM)
     * - If document does not exist -> it will be created
     * - If document exists -> it will be updated (merge)
     * - Doctor CANNOT change booked slots
     *
     * Example Request:
     *
     * @request {
     *   "days": [
     *     {
     *       "date": "2026-02-20",
     *       "doctorSlots": [True, True, True, false, false, false, false, false, false, false]
     *     }
     *   ]
     * }
     *
     * @response:
     *   HTTP 200 OK (no body)
     */
    public void updateSchedule(String doctorID, AvailabilityScheduleUpdateDto request)
    {
        if (request == null || request.getDays() == null || request.getDays().isEmpty()) {
            throw new IllegalStateException("No days provided for update.");
        }

        List<AvailabilityDayDto> toWrite = new ArrayList<>();

        // We will rewrite incoming days so bookedSlots are always preserved.
        // Then we pass the cleaned days list to repo.batch update.
        for (AvailabilityDayUpdateDto incoming : request.getDays()) {

            // 1) Validate date window for edit
            validateDateEditable(incoming.getDate());

            // 2) Validate doctorSlots shape
            validateSlotList(incoming.getDoctorSlots(), "doctorSlots");

            // 3) Read existing from DB (to know what is booked)
            AvailabilityDayDto existing = scheduleRepo.getDay(doctorID, incoming.getDate());

            List<Boolean> existingBooked = (existing == null || existing.getBookedSlots() == null)
                    ? defaultFalseSlots()
                    : existing.getBookedSlots();

            List<Boolean> existingDoctor = (existing == null || existing.getDoctorSlots() == null)
                    ? defaultFalseSlots()
                    : existing.getDoctorSlots();

            // 4) Block doctor from changing any slot that is already booked
            // Meaning: if bookedSlots[i] == true, doctorSlots[i] must remain the same as before.
            for (int i = 0; i < TimeSlotConfig.SLOT_COUNT; i++) {
                if (Boolean.TRUE.equals(existingBooked.get(i))) {
                    boolean oldValue = Boolean.TRUE.equals(existingDoctor.get(i));
                    boolean newValue = Boolean.TRUE.equals(incoming.getDoctorSlots().get(i));

                    if (oldValue != newValue) {
                        throw new IllegalStateException(
                                "Cannot change a booked slot. date=" + incoming.getDate() + ", index=" + i
                        );
                    }
                }
            }

            // 5) Build the day doc to write:
            // - doctorSlots = incoming doctorSlots
            // - bookedSlots = preserved from DB
            AvailabilityDayDto merged = new AvailabilityDayDto();
            merged.setDate(incoming.getDate());
            merged.setDoctorSlots(incoming.getDoctorSlots());
            merged.setBookedSlots(existingBooked);

            toWrite.add(merged);
        }

        scheduleRepo.update(doctorID, toWrite);

    }
}
