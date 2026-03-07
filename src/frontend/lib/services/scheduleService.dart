import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../dto/scheduleDto.dart';

class ScheduleService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<ScheduleDto> getDoctorScheduleByDate({
    required String doctorId,
    required String date,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    final url = Uri.parse(
      "$baseUrl/api/caregiver/doctors/$doctorId/schedule?date=$date",
    );

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Schedule status code: ${response.statusCode}");
    print("RAW schedule response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load schedule: ${response.body}");
    }

    if (response.body.trim().isEmpty) {
      return ScheduleDto(date: date, timeSlots: []);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ScheduleDto.fromJson(data);
  }
}
