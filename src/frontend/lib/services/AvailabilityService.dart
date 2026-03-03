import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bouh/dto/AvailabilityDto.dart';
import 'package:bouh/config/api_config.dart';
import 'package:bouh/authentication/AuthSession.dart';

/// Service that calls backend availability schedule endpoints.
/// Builds URL from ApiConfig.baseUrl + path.
class AvailabilityService {
  /// GET /api/doctors/{doctorId}/doctorAvailability?from=yyyy-MM-dd&to=yyyy-MM-dd
  Future<List<AvailabilityDayDto>> getSchedule({
    required String doctorId,
    required String from,
    required String to,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/doctors/$doctorId/doctorAvailability?from=$from&to=$to',
    );
    final res = await http.get(url, headers: _authHeaders());

    if (res.statusCode != 200) {
      throw Exception("Failed to load schedule (${res.statusCode})");
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final rawDays = (body['days'] as List?) ?? [];

    return rawDays
        .map((d) => AvailabilityDayDto.fromJson(Map<String, dynamic>.from(d)))
        .toList();
  }

  /// PUT /api/doctors/{doctorId}/doctorAvailability

  Future<void> updateSchedule({
    required String doctorId,
    required List<Map<String, dynamic>> days,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/doctors/$doctorId/doctorAvailability',
    );

    final res = await http.put(
      url,
      headers: _authHeaders(json: true),
      body: jsonEncode({"days": days}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update schedule (${res.statusCode})");
    }
  }

  Map<String, String> _authHeaders({bool json = false}) {
    final session = AuthSession.instance;
    final token = session.idToken;

    if (token == null || token.isEmpty) {
      throw StateError('No JWT (idToken). User not logged in.');
    }

    return {
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
