import 'package:bouh/View/caregiverHomepage/caregivernavbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const CaregiverNavbar());
    //return MaterialApp(home: const CaregiverAccountView());
  }
}
