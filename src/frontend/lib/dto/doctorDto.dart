import 'scheduleDto.dart';

class DoctorDto {
  final String doctorId;
  final String name;
  final String email;
  final String gender;
  final double? averageRating;
  final String areaOfKnowledge;
  final List<String> qualifications;
  final int yearsOfExperience;
  final String scfhsNumber;
  final String iban;
  String? profilePhotoURL;
  String? fcmToken;
  final String registrationStatus;
  final List<ScheduleDto>? schedule;

  DoctorDto({
    required this.doctorId,
    required this.name,
    required this.email,
    required this.gender,
    this.averageRating,
    required this.areaOfKnowledge,
    required this.qualifications,
    required this.yearsOfExperience,
    required this.scfhsNumber,
    required this.iban,
    this.profilePhotoURL,
    this.fcmToken,
    required this.registrationStatus,
    this.schedule,
  });

  factory DoctorDto.fromJson(Map<String, dynamic> json) {
    final rawRating = json['averageRating'];

    return DoctorDto(
      doctorId: (json['doctorId'] ?? json['doctorID'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      averageRating: rawRating is num
          ? rawRating.toDouble()
          : rawRating is String
          ? double.tryParse(rawRating)
          : null,
      areaOfKnowledge: (json['areaOfKnowledge'] ?? '').toString(),
      qualifications:
          (json['qualifications'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      yearsOfExperience: (json['yearsOfExperience'] is num)
          ? (json['yearsOfExperience'] as num).toInt()
          : int.tryParse(json['yearsOfExperience']?.toString() ?? '') ?? 0,
      scfhsNumber: (json['scfhsNumber'] ?? '').toString(),
      iban: (json['iban'] ?? '').toString(),
      profilePhotoURL: json['profilePhotoURL']?.toString(),
      fcmToken: json['fcmToken']?.toString(),
      registrationStatus: (json['registrationStatus'] ?? '').toString(),
      schedule: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'name': name,
      'email': email,
      'gender': gender,
      'averageRating': averageRating,
      'areaOfKnowledge': areaOfKnowledge,
      'qualifications': qualifications,
      'yearsOfExperience': yearsOfExperience,
      'scfhsNumber': scfhsNumber,
      'iban': iban,
      'profilePhotoURL': profilePhotoURL,
      'fcmToken': fcmToken,
      'registrationStatus': registrationStatus,
      'schedule': schedule?.map((s) => s.toJson()).toList(),
    };
  }
}
