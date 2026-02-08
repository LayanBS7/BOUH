import 'package:flutter/material.dart';
import 'package:bouh/View/DrawingAnalysis/RequestAnalysisPage.dart';
import 'package:bouh/theme/base_themes/colors.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOUH - تحليل رسومات الأطفال',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: BColors.primary),
        useMaterial3: true,
      ),
      home: const RequestAnalysisPage(),
    );
  }
}
