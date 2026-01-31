import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/theme/base_themes/radius.dart';
import 'package:bouh/theme/base_themes/typography.dart';

/// Request Analysis Page - First page for drawing analysis feature
/// Allows user to select a child and start analysis
class RequestAnalysisPage extends StatefulWidget {
  const RequestAnalysisPage({super.key});

  @override
  State<RequestAnalysisPage> createState() => _RequestAnalysisPageState();
}

class _RequestAnalysisPageState extends State<RequestAnalysisPage> {
  /// Selected child name from dropdown
  String? _selectedChild;

  /// Mock list of children names (will be replaced with actual data)
  final List<String> _childrenNames = [
    'أحمد',
    'سارة',
    'محمد',
    'فاطمة',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BColors.white,
        body: Stack(
          children: [
            /// Brush/wave effect decoration at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: const Size(double.infinity, 280),
                painter: _BrushStrokePainter(),
              ),
            ),
            /// Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    /// Top row with previous drawings button
                    _buildTopBar(),

                    const Spacer(flex: 2),

                    /// Page title
                    _buildTitle(),

                    const SizedBox(height: 40),

                    /// Child selection dropdown
                    _buildChildDropdown(),

                    const SizedBox(height: 48),

                    /// Start button
                    _buildStartButton(),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top bar with previous drawings button
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to previous drawings page
          },
          icon: const Icon(
            Icons.history,
            color: BColors.white,
            size: 18,
          ),
          label: Text(
            'الرسومات السابقة',
            style: BTypography.buttonText.copyWith(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: BColors.accent,
            foregroundColor: BColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BRadius.buttonMediumRadius,
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  /// Builds the page title
  Widget _buildTitle() {
    return Text(
      'حلل رسمة طفلك اليوم!',
      style: BTypography.pageTitle,
      textAlign: TextAlign.center,
    );
  }

  /// Builds the child selection dropdown
  Widget _buildChildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label for dropdown
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'اختر اسم الطفل',
            style: BTypography.labelText,
          ),
        ),

        /// Dropdown container
        Container(
          decoration: BoxDecoration(
            color: BColors.softGrey,
            borderRadius: BRadius.dropdownRadius,
            border: Border.all(color: BColors.grey, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedChild,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'اسم الطفل',
                  style: BTypography.dropdownHint,
                ),
              ),
              isExpanded: true,
              icon: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: BColors.darkGrey,
                ),
              ),
              borderRadius: BRadius.dropdownRadius,
              dropdownColor: BColors.secondry,
              items: _childrenNames.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      name,
                      style: BTypography.dropdownSelected,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedChild = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the start analysis button
  Widget _buildStartButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _selectedChild != null
            ? () {
                // TODO: Navigate to drawing upload/capture page
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: BColors.accent,
          disabledBackgroundColor: BColors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BRadius.buttonLargeRadius,
          ),
          elevation: 0,
        ),
        child: Text(
          'بدء',
          style: BTypography.buttonText,
        ),
      ),
    );
  }
}

/// Custom painter for brush stroke effect with texture
class _BrushStrokePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    
    // Start from top-left
    path.moveTo(2, 0);
    
    // Top edge
    path.lineTo(size.width, 0);
    
    // Right edge - slight curve down then back
    path.lineTo(size.width, size.height * 0.08);
    path.quadraticBezierTo(
      size.width * 0.92, size.height * 0.12,
      size.width * 0.85, size.height * 0.18,
    );
    
    // First drip (right side) - tallest
    path.quadraticBezierTo(
      size.width * 0.80, size.height * 0.28,
      size.width * 0.78, size.height * 0.50,
    );
    path.quadraticBezierTo(
      size.width * 0.76, size.height * 0.70,
      size.width * 0.72, size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.68, size.height * 0.98,
      size.width * 0.62, size.height * 0.90,
    );
    path.quadraticBezierTo(
      size.width * 0.56, size.height * 0.82,
      size.width * 0.58, size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.60, size.height * 0.40,
      size.width * 0.55, size.height * 0.25,
    );
    
    // Second drip (middle) - medium
    path.quadraticBezierTo(
      size.width * 0.50, size.height * 0.18,
      size.width * 0.45, size.height * 0.22,
    );
    path.quadraticBezierTo(
      size.width * 0.40, size.height * 0.30,
      size.width * 0.38, size.height * 0.48,
    );
    path.quadraticBezierTo(
      size.width * 0.36, size.height * 0.62,
      size.width * 0.32, size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.28, size.height * 0.48,
      size.width * 0.30, size.height * 0.32,
    );
    path.quadraticBezierTo(
      size.width * 0.32, size.height * 0.20,
      size.width * 0.25, size.height * 0.22,
    );
    
    // Third drip (left side) - smallest
    path.quadraticBezierTo(
      size.width * 0.18, size.height * 0.26,
      size.width * 0.15, size.height * 0.38,
    );
    path.quadraticBezierTo(
      size.width * 0.12, size.height * 0.48,
      size.width * 0.08, size.height * 0.42,
    );
    path.quadraticBezierTo(
      size.width * 0.04, size.height * 0.36,
      size.width * 0.05, size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.06, size.height * 0.15,
      0, size.height * 0.18,
    );
    
    // Back to start
    path.lineTo(0, 0);
    path.close();
    
    // Main fill
    final mainPaint = Paint()
      ..color = BColors.primary
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, mainPaint);
    
    // Clip for texture
    canvas.save();
    canvas.clipPath(path);
    
    // 3 subtle diagonal strokes
    final linePaint = Paint()
      ..color = const Color(0xFF5D8FA6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 45.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width * 0.15, -20),
      Offset(size.width * 0.50, size.height * 0.9),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.40, -20),
      Offset(size.width * 0.75, size.height * 0.9),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, -20),
      Offset(size.width * 1.0, size.height * 0.9),
      linePaint,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
