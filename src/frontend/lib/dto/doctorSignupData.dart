import 'dart:io';

class DoctorSignupData {
  final String email;
  final String password;
  final String name;
  final String gender;
  final File? profileImage;

  const DoctorSignupData({
    required this.email,
    required this.password,
    required this.name,
    required this.gender,
    this.profileImage,
  });
}
