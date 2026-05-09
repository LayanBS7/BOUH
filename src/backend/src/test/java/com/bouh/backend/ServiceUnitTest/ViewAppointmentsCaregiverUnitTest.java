package com.bouh.backend.ServiceUnitTest;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import com.bouh.backend.model.Dto.appointmentDto;
import com.bouh.backend.model.Dto.upcomingAppointmentDto;
import com.bouh.backend.model.repository.AppointmentRepo;
import com.bouh.backend.model.repository.doctorRepo;
import com.bouh.backend.model.repository.childrenRepo;
import com.bouh.backend.service.GcsImageService;
import com.bouh.backend.service.appointments.AppointmentsService;

@ExtendWith(MockitoExtension.class)
public class ViewAppointmentsCaregiverUnitTest {

        @Mock
        private AppointmentRepo appointmentRepo;

        @Mock
        private doctorRepo doctorRepo;

        @Mock
        private childrenRepo childrenRepo;

        @Mock
        private GcsImageService gcsImageService;

        @InjectMocks
        private AppointmentsService appointmentsService;

        private static final String CAREGIVER_ID = "cgVr8KmN2pQwYx5Lt7BzAhD3F1Js";
        private static final String DOCTOR_ID    = "drMq6JvW4nXkZsP9LbCyTfHa8RuE";
        private static final String CHILD_ID     = "chK7mP3nQrJ8wXyZtBvL";

        /*
         * Empty case for upcoming: when the repository returns no upcoming
         * appointments, the service must return a non-null empty list.
         */
        @Test
        void getUpcomingAppointments_shouldReturnEmptyList()
                        throws ExecutionException, InterruptedException {

                when(appointmentRepo.findUpcomingByCaregiverId(CAREGIVER_ID))
                                .thenReturn(new ArrayList<>());

                List<upcomingAppointmentDto> result = appointmentsService.getUpcomingAppointments(CAREGIVER_ID);

                verify(appointmentRepo).findUpcomingByCaregiverId(CAREGIVER_ID);
                assertNotNull(result);
                assertTrue(result.isEmpty());
        }

        /*
         * Empty case for previous: when both the past repo and the upcoming
         * repo return empty, the service must return a non-null empty list.
         */
        @Test
        void getPreviousAppointments_shouldReturnEmptyList()
                        throws ExecutionException, InterruptedException {

                when(appointmentRepo.findPastByCaregiverId(CAREGIVER_ID))
                                .thenReturn(new ArrayList<>());
                when(appointmentRepo.findUpcomingByCaregiverId(CAREGIVER_ID))
                                .thenReturn(new ArrayList<>());

                List<upcomingAppointmentDto> result = appointmentsService.getPreviousAppointments(CAREGIVER_ID);

                verify(appointmentRepo).findPastByCaregiverId(CAREGIVER_ID);
                verify(appointmentRepo).findUpcomingByCaregiverId(CAREGIVER_ID);
                assertNotNull(result);
                assertTrue(result.isEmpty());
        }

        /*
         * Sort test for upcoming: repo returns appointments in scrambled order
         * on purpose; the service is responsible for sorting them nearest-first
         * before returning.
         */
        @Test
        void getUpcomingAppointments_shouldBeOrderedNearestFirst()
                        throws ExecutionException, InterruptedException {

                String idIn1Day  = "apA1bC2dE3fG4hI5jK6l";
                String idIn3Days = "apM7nO8pQ9rS0tU1vW2x";
                String idIn7Days = "apY3zA4bC5dE6fG7hI8j";

                Instant base = Instant.now();
                appointmentDto in7Days = buildBasicAppointment(idIn7Days, base.plusSeconds(7 * 86400));
                appointmentDto in1Day  = buildBasicAppointment(idIn1Day,  base.plusSeconds(86400));
                appointmentDto in3Days = buildBasicAppointment(idIn3Days, base.plusSeconds(3 * 86400));

                when(appointmentRepo.findUpcomingByCaregiverId(CAREGIVER_ID))
                                .thenReturn(new ArrayList<>(List.of(in7Days, in1Day, in3Days)));

                List<upcomingAppointmentDto> result = appointmentsService.getUpcomingAppointments(CAREGIVER_ID);

                verify(appointmentRepo).findUpcomingByCaregiverId(CAREGIVER_ID);
                assertNotNull(result);
                assertEquals(3, result.size());
                assertEquals(idIn1Day,  result.get(0).getAppointmentId());
                assertEquals(idIn3Days, result.get(1).getAppointmentId());
                assertEquals(idIn7Days, result.get(2).getAppointmentId());
        }

        /*
         * Sort test for previous: repo returns past appointments in scrambled
         * order on purpose; the service is responsible for sorting them
         * newest-first before returning.
         */
        @Test
        void getPreviousAppointments_shouldBeOrderedNewestFirst()
                        throws ExecutionException, InterruptedException {

                String idOneDayAgo    = "apK1lM2nO3pQ4rS5tU6v";
                String idThreeDaysAgo = "apW7xY8zA9bC0dE1fG2h";
                String idSevenDaysAgo = "apI3jK4lM5nO6pQ7rS8t";

                Instant base = Instant.now();
                appointmentDto sevenDaysAgo = buildBasicAppointment(idSevenDaysAgo, base.minusSeconds(7 * 86400));
                appointmentDto oneDayAgo    = buildBasicAppointment(idOneDayAgo,    base.minusSeconds(86400));
                appointmentDto threeDaysAgo = buildBasicAppointment(idThreeDaysAgo, base.minusSeconds(3 * 86400));

                when(appointmentRepo.findPastByCaregiverId(CAREGIVER_ID))
                                .thenReturn(new ArrayList<>(List.of(sevenDaysAgo, oneDayAgo, threeDaysAgo)));
                when(appointmentRepo.findUpcomingByCaregiverId(CAREGIVER_ID))
                                .thenReturn(new ArrayList<>());

                List<upcomingAppointmentDto> result = appointmentsService.getPreviousAppointments(CAREGIVER_ID);

                verify(appointmentRepo).findPastByCaregiverId(CAREGIVER_ID);
                verify(appointmentRepo).findUpcomingByCaregiverId(CAREGIVER_ID);
                assertNotNull(result);
                assertEquals(3, result.size());
                assertEquals(idOneDayAgo,    result.get(0).getAppointmentId());
                assertEquals(idThreeDaysAgo, result.get(1).getAppointmentId());
                assertEquals(idSevenDaysAgo, result.get(2).getAppointmentId());
        }

        /*
         * Helper: builds a minimal appointmentDto with the given id and start
         * time. Used by sort tests that don't care about slot-of-day boundaries.
         */
        private appointmentDto buildBasicAppointment(String id, Instant when) {
                appointmentDto a = new appointmentDto();
                a.setAppointmentId(id);
                a.setCaregiverId(CAREGIVER_ID);
                a.setDoctorId(DOCTOR_ID);
                a.setChildId(CHILD_ID);
                a.setStartDateTime(
                                Timestamp.ofTimeSecondsAndNanos(when.getEpochSecond(), 0));
                a.setStatus(1);
                a.setRated(false);
                return a;
        }
}
