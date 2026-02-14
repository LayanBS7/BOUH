import 'package:bouh/View/Profile/CaregiverProfile.dart';
import 'package:bouh/View/patient_test.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PatientTestPage(),
    );
  }
}
