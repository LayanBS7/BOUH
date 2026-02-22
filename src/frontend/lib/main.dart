import 'package:bouh/View/DoctorAppointment/available_schedule_screen.dart';
import 'package:bouh/View/caregiverHomepage/caregivernavbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  await initializeDateFormatting('ar_SA', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const AvailableScheduleScreen());
    //return MaterialApp(home: const CaregiverAccountView());
  }
}
