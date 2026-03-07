import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:bouh/dto/doctorDto.dart';
import 'package:bouh/dto/doctorSummaryDto.dart';

class DoctorsService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    return {"Accept": "application/json", "Authorization": "Bearer $token"};
  }

  static Future<List<DoctorSummaryDto>> getDoctorsForCaregiver() async {
    final uri = Uri.parse("$baseUrl/api/caregiver/doctors");
    final headers = await _authHeaders();

    final res = await http.get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception("Failed: ${res.statusCode} ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    print("RAW doctors response: ${res.body}");

    if (decoded is! List) {
      throw Exception("Unexpected response shape: ${res.body}");
    }

    return decoded
        .map((e) => DoctorSummaryDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<DoctorDto> getDoctorDetails(String doctorId) async {
    final uri = Uri.parse("$baseUrl/api/caregiver/doctors/$doctorId");
    final headers = await _authHeaders();

    print("Calling details API: $uri");

    final res = await http.get(uri, headers: headers);

    print("Details status code: ${res.statusCode}");
    print("RAW doctor details response: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed: ${res.statusCode} ${res.body}");
    }

    final decoded = jsonDecode(res.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Unexpected response shape: ${res.body}");
    }

    return DoctorDto.fromJson(decoded);
  }
}
