import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/theme/base_themes/typography.dart';
import 'package:bouh/View/DrawingAnalysis/drawing_analysis_stepper.dart';
import 'package:bouh/View/DrawingAnalysis/AnalysisResultsPage.dart';


class ProcessingAnalysisPage extends StatefulWidget {
  //Path to the drawing image file. Send this to our backend analyze API
  final String imagePath;

  //Child name from step 0 (RequestAnalysis)
  final String? selectedChildName;

  const ProcessingAnalysisPage({
    super.key,
    required this.imagePath,
    this.selectedChildName,
  });

  @override
  State<ProcessingAnalysisPage> createState() => _ProcessingAnalysisPageState();
}

class _ProcessingAnalysisPageState extends State<ProcessingAnalysisPage>
    with SingleTickerProviderStateMixin {

  //Progress 0.0–1.0.
  double _progress = 0.0;

  //Status line under the circle.
  String _statusText = 'جاري التحليل...';

  Timer? _timer;

  //Wave fill animation.
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  //Status messages shown in order while loading.
  static const List<String> _statusMessages = [
    'جاري التحليل...',
    'تحديد الشعور',
    'جاري تحميل إجابات التحليل',
    'تقريباً جاهز...',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(_waveController);
    _startSimulatedProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  //Simulated progress.
  void _startSimulatedProgress() {
    const duration = Duration(milliseconds: 400);
    int step = 0;

    void tick() {
      if (!mounted) return;
      step++;
      final p = (step / 25).clamp(0.0, 1.0);
      setState(() {
        _progress = p;
        _statusText = _statusMessages[(step ~/ 7).clamp(0, _statusMessages.length - 1)];
      });
      if (p >= 1.0) {
        _timer?.cancel();
        //Go to results page. Use pushReplacement so Back from results exits the flow.
        //When using real API, pass result in here: AnalysisResultsPage(interpretations: ..., doctors: ...)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const AnalysisResultsPage(),
          ),
        );
        return;
      }
      _timer = Timer(duration, tick);
    }

    _timer = Timer(duration, tick);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BColors.lightGrey,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 38),

              const DrawingAnalysisStepper(currentStep: 1),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      _buildCircularProgress(),
                      
                      const SizedBox(height: 24),

                      Text(
                        _statusText,
                        style: BTypography.bodyText.copyWith(
                          color: BColors.darkerGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Ocean-style progress with animated wave: inner circle fills from the bottom,
  //top edge is a moving wave. Percentage text is centered on top.
  Widget _buildCircularProgress() {
    const double size = 210;
    final percentage = (_progress * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          //Circle border and background
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 219, 219, 219),
              border: Border.all(color: const Color.fromARGB(167, 255, 132, 75), width: 3),
            ),
          ),

          //Animated wave fill (clipped to circle)
          ClipOval(
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: _OceanWavePainter(
                    progress: _progress,
                    wavePhase: _waveAnimation.value,
                    color: BColors.accent,
                  ),
                );
              },
            ),
          ),

          //Percentage text in center
          Text(
            '$percentage%',
            style: BTypography.sectionTitle.copyWith(
              color: BColors.white,
              fontSize: 55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

//Paints the ocean fill with a wavy top edge
class _OceanWavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color color;

  _OceanWavePainter({
    required this.progress,
    required this.wavePhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width;
    final h = size.height;
    //Fill level from bottom (y increases downward). Flat level would be at y = h * (1 - progress).
    final fillLevel = h * (1 - progress);
    const waveAmplitude = 6.0;
    const waveLength = 0.020; //cycles per pixel (controls the wave shape)
    final phase = wavePhase * 2 * math.pi;

    final path = Path();
    path.moveTo(0, h);
    path.lineTo(0, fillLevel + waveAmplitude * math.sin(phase));
    for (double x = 0; x <= w; x += 2) {
      final y = fillLevel + waveAmplitude * math.sin(x * waveLength * 2 * math.pi + phase);
      path.lineTo(x, y);
    }
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_OceanWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.wavePhase != wavePhase;
  }
}