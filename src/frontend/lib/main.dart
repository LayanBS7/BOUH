import 'package:bouh/View/Profile/CaregiverProfile.dart';
import 'package:bouh/View/BookAppointment/DoctorDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

//TEST ME
import 'package:bouh/View/DrawingAnalysis/RequestAnalysisPage.dart';
import 'package:bouh/theme/base_themes/colors.dart';
//TEST ME

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //TEST ONLY
      return MaterialApp(
      title: 'BOUH - تحليل رسومات الأطفال',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: BColors.primary),
        useMaterial3: true,
      ),
      home: const RequestAnalysisPage(),
    );
    //return MaterialApp(home: const CaregiverAccountView());
  }
}
