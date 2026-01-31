import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/theme/base_themes/radius.dart';
import 'package:bouh/theme/base_themes/typography.dart';

/// Analysis Results Page - Shows drawing analysis results
class AnalysisResultsPage extends StatelessWidget {
  const AnalysisResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BColors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              /// Back button
              _buildBackButton(context),

              const SizedBox(height: 16),

              /// Progress stepper
              _buildProgressStepper(),

              const SizedBox(height: 24),

              /// Main content - scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Interpretations section
                      _buildInterpretationsSection(),

                      const SizedBox(height: 32),

                      /// Recommended doctors section
                      _buildDoctorsSection(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              /// Close button
              _buildCloseButton(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds back button at top left
  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: BColors.darkGrey,
              size: 20,
            ),
          ),
          Text(
            'نتيجة التحليل',
            style: BTypography.labelText,
          ),
        ],
      ),
    );
  }

  /// Builds the progress stepper showing current step
  Widget _buildProgressStepper() {
    final steps = [
      'تحميل الرسمة',
      'تحليل الرسمة',
      'نتيجة التحليل',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            return Expanded(
              child: Container(
                height: 2,
                color: BColors.primary,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= 2;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? BColors.primary : BColors.grey,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: BColors.white,
                        size: 14,
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: BTypography.labelText.copyWith(
                  fontSize: 10,
                  color: isCompleted ? BColors.primary : BColors.darkGrey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Builds the interpretations section with cards
  Widget _buildInterpretationsSection() {
    // TODO: Replace with data from backend
    final interpretations = [
      'يبدو أن طفلك يحس أنه لوحده أو ما يلقى أحد يشاركه لحظاته مثل ما يتمنى. يمكن يكون محتاج احتواء أكثر أو شخص يسمعه ويحس فيه. جرّب تقضين معه وقت ببيط تشاركينه لعب أو سؤال لطيف عن يومه. مجرد وجودك قدامه بقلبك قبل كلامك يساعده يحس أنه مو وحده.',
      'لاحظنا ان هالنوع من الرسمات طفلك يرسمه بشكل متكرر. اذا تحبين تعرفين أكثر عن الموضوع وتستشيرين مختص اقترحنا لك اطباء ممكن يساعدونك',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'تفسيرات الرسمة',
          style: BTypography.sectionTitle,
        ),
        const SizedBox(height: 16),
        ...interpretations.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInterpretationCard(text),
            )),
      ],
    );
  }

  /// Builds a single interpretation card
  Widget _buildInterpretationCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BColors.secondry,
        borderRadius: BorderRadius.circular(BRadius.cardLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Checkmark icon
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: BColors.accent,
            ),
            child: const Icon(
              Icons.check,
              color: BColors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          /// Interpretation text
          Expanded(
            child: Text(
              content,
              style: BTypography.bodyText.copyWith(
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the recommended doctors section
  Widget _buildDoctorsSection() {
    // TODO: Replace with data from backend
    final doctors = [
      'د.علي آل يحيى',
      'د.موسى السبيعي',
      'د. محمد سعد',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'الأطباء المقترحين',
          style: BTypography.sectionTitle,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: doctors.map((name) => _buildDoctorCard(name)).toList(),
        ),
      ],
    );
  }

  /// Builds a single doctor card
  Widget _buildDoctorCard(String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Doctor image placeholder
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BColors.softGrey,
            border: Border.all(
              color: BColors.primary,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.person,
            size: 40,
            color: BColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),

        /// Doctor name
        SizedBox(
          width: 90,
          child: Text(
            name,
            style: BTypography.labelText.copyWith(
              color: BColors.textDarkestBlue,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the close button at the bottom
  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // TODO: Navigate back to home
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: BColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BRadius.buttonLargeRadius,
            ),
            elevation: 0,
          ),
          child: Text(
            'اغلاق',
            style: BTypography.buttonText,
          ),
        ),
      ),
    );
  }
}
