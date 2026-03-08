import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bouh/config/api_config.dart';
import 'package:bouh/authentication/AuthSession.dart';
import 'package:bouh/dto/doctorDto.dart';
import 'package:bouh/dto/doctorSummaryDto.dart';

class DoctorsService {
  static Uri _url(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Map<String, String> _authHeaders() {
    final token = AuthSession.instance.idToken;

    if (token == null || token.isEmpty) {
      throw StateError('No JWT (idToken). User not logged in.');
    }

    return {"Accept": "application/json", "Authorization": "Bearer $token"};
  }

  static Future<List<DoctorSummaryDto>> getDoctorsForCaregiver() async {
    final uri = _url('/api/caregiver/doctors');
    final headers = _authHeaders();

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
    final uri = _url('/api/caregiver/doctors/$doctorId');
    final headers = _authHeaders();

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
