import 'childDto.dart';

/// Single DTO for caregiver: name, email, and list of children.
/// For account creation, [caregiverId] can be null; AuthService sets it from Firebase UID before sending to backend.
class CaregiverDto {
  final String? caregiverId;
  final String name;
  final String email;
  final String? fcmToken;
  final List<ChildDto> children;

  CaregiverDto({
    this.caregiverId,
    required this.name,
    required this.email,
    this.fcmToken,
    required this.children,
  });

  Map<String, dynamic> toJson() {
    return {
      'caregiverId': caregiverId ?? '',
      'name': name,
      'email': email,
      'fcmToken': fcmToken,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}
