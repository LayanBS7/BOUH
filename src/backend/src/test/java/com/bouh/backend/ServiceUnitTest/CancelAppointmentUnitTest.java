package com.bouh.backend.ServiceUnitTest;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anySet;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityDayDto;
import com.bouh.backend.model.Dto.AvailabilitySchedule.AvailabilityStoredSlotDto;
import com.bouh.backend.model.Dto.appointmentDto;
import com.bouh.backend.model.repository.AppointmentRepo;
import com.bouh.backend.model.repository.AvailabilityScheduleRepo;
import com.bouh.backend.model.repository.caregiverRepo;
import com.bouh.backend.model.repository.childrenRepo;
import com.bouh.backend.model.repository.doctorRepo;
import com.bouh.backend.service.GcsImageService;
import com.bouh.backend.service.appointments.AppointmentsService;
import com.google.cloud.Timestamp;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;

@ExtendWith(MockitoExtension.class)
public class CancelAppointmentUnitTest {

    @Mock
    private AppointmentRepo appointmentRepo;

    @Mock
    private doctorRepo doctorRepo;

    @Mock
    private childrenRepo childrenRepo;

    @Mock
    private caregiverRepo caregiverRepo;

    @Mock
    private AvailabilityScheduleRepo availabilityScheduleRepo;

    @Mock
    private GcsImageService gcsImageService;

    @InjectMocks
    private AppointmentsService appointmentsService;

    @Test
    void cancelAppointment_shouldCancelSuccessfully() throws Exception {

        // Create fake appointment
        appointmentDto appointment = new appointmentDto();
        appointment.setAppointmentId("appt1");
        appointment.setCaregiverId("caregiver1");
        appointment.setDoctorId("doctor1");

        // Appointment after 2 hours
       ZonedDateTime future = ZonedDateTime.now(ZoneId.of("Asia/Riyadh"))
        .plusDays(1)
        .withHour(16)
        .withMinute(30)
        .withSecond(0)
        .withNano(0);

appointment.setStartDateTime(
        Timestamp.ofTimeSecondsAndNanos(
                future.toEpochSecond(),
                future.getNano()
        )
);

     appointment.setStartDateTime(
        Timestamp.ofTimeSecondsAndNanos(
                future.toEpochSecond(),
                future.getNano()
        )
);

        // Mock repo
        when(appointmentRepo.findById("appt1"))
                .thenReturn(appointment);

        // Fake availability slot
        AvailabilityStoredSlotDto slot = new AvailabilityStoredSlotDto();
        slot.setIndex(1);
        slot.setBooked(true);

        AvailabilityDayDto day = new AvailabilityDayDto();
        day.setSlots(List.of(slot));

        when(availabilityScheduleRepo.getDay(anyString(), anyString()))
                .thenReturn(day);

        // Call service
        appointmentsService.cancelAppointment("caregiver1", "appt1");

        // Verify delete called
        verify(appointmentRepo).deleteByIdAtomically("appt1");

        // Verify availability updated
        verify(availabilityScheduleRepo).update(
                anyString(),
                anyMap(),
                anySet()
        );
    }

 @Test
void cancelAppointment_shouldThrowWhenAppointmentNotFound() throws Exception {
  // Mock repo to return null appointment
    when(appointmentRepo.findById("appt1"))
            .thenReturn(null);
    // Verify exception is thrown
    assertThrows(
            IllegalArgumentException.class,
            () -> appointmentsService.cancelAppointment("caregiver1", "appt1")
    );
}



    @Test
void cancelAppointment_shouldThrowWhenLessThan30Minutes() throws Exception {
   // Create fake appointment
        appointmentDto appointment = new appointmentDto();
        appointment.setCaregiverId("caregiver1");
        appointment.setDoctorId("doctor1");

        // Appointment after 10 minutes
        Instant future = Instant.now().plusSeconds(600);

        appointment.setStartDateTime(
                Timestamp.ofTimeSecondsAndNanos(
                        future.getEpochSecond(),
                        future.getNano()
                )
        );
    // Mock repo
        when(appointmentRepo.findById("appt1"))
                .thenReturn(appointment);
    // Verify exception is thrown
        assertThrows(
                IllegalStateException.class,
                () -> appointmentsService.cancelAppointment("caregiver1", "appt1")
        );
    }

}