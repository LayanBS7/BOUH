import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/theme/base_themes/radius.dart';
import 'package:bouh/theme/base_themes/typography.dart';
import 'package:bouh/View/DrawingAnalysis/drawing_analysis_stepper.dart';

class AnalysisResultsPage extends StatelessWidget {
  //When true, hide the top stepper and show only the back button (when called in drawing history).
  final bool hideStepper;

  const AnalysisResultsPage({
    super.key,
    this.hideStepper = false,
  });

  //Main build
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BColors.white,
        body: SafeArea(
          child: Column(
            children: [

              SizedBox(height: hideStepper ? 8 : 38),

              //When opened from DrawingHistoryPage: back arrow
              if (hideStepper)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: BColors.darkGrey,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              if (!hideStepper) ...[
                const SizedBox(height: 16),
                const DrawingAnalysisStepper(currentStep: 2),
              ],

              const SizedBox(height: 32),

              //Main content (interpretations and doctors)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      //Interpretations section
                      _buildInterpretationsSection(),

                      const SizedBox(height: 32),

                      //Recommended doctors section
                      _buildDoctorsSection(context),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              //Close button (hidden when results are opened from drawingHistoryPage)
              if (!hideStepper) _buildCloseButton(context),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  //Builds the interpretations section with cards.
  //BACKEND: Replace mock list with widget.interpretations ?? mockList once we add
  //the optional parameter and pass API response from ProcessingAnalysisPage.
  Widget _buildInterpretationsSection() {
    //Mock data until backend is connected. Then use: widget.interpretations ?? [...]
    final interpretations = [
      'يبدو أن طفلك يحس أنه لوحده أو ما يلقى أحد يشاركه لحظاته مثل ما يتمنى. يمكن يكون محتاج احتواء أكثر أو شخص يسمعه ويحس فيه. جرّب تقضين معه وقت ببيط تشاركينه لعب أو سؤال لطيف عن يومه. مجرد وجودك قدامه بقلبك قبل كلامك يساعده يحس أنه مو وحده.',
      'لاحظنا ان هالنوع من الرسمات طفلك يرسمه بشكل متكرر. اذا تحبين تعرفين أكثر عن الموضوع وتستشيرين مختص اقترحنا لك اطباء ممكن يساعدونك',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'تفسيرات الرسمة',
            style: BTypography.sectionTitle,
            textAlign: TextAlign.right,
          ),
        ),

        const SizedBox(height: 16),

        //Builds a list of interpretation cards
        ...interpretations.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInterpretationCard(text),
            )),
      ],
    );
  }

  //Builds a single interpretation card
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
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: BColors.accent,
            ),
            child: const Icon(
              Icons.lightbulb,
              color: BColors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          //Interpretation text
          Expanded(
            child: Text(
              content,
              style: BTypography.bodyText.copyWith(
                height: 1.3,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  //Builds the recommended doctors section.
  Widget _buildDoctorsSection(BuildContext context) {
    //Mock data until backend is connected. Pass imageUrl when available.
    final doctors = [
      ('د.علي آل يحيى', null as String?),
      ('د.موسى ناصر', null as String?),
      ('د. محمد سعد', null as String?),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'الأطباء المقترحين',
            style: BTypography.sectionTitle,
            textAlign: TextAlign.right,
          ),
        ),

        const SizedBox(height: 16),

        //Builds a list of doctor cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: doctors
              .map((e) => _buildDoctorCard(context, e.$1, imageUrl: e.$2))
              .toList(),
        ),
      ],
    );
  }

  //Builds a single doctor card. Pass [imageUrl] when available to show profile image.
  //TODO: When backend is ready, onTap should route to doctor detail page.
  Widget _buildDoctorCard(BuildContext context, String name, {String? imageUrl}) {
    return GestureDetector(
      onTap: () {
        //TODO: Navigate to doctor page when backend is connected.
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: BColors.secondry,
          borderRadius: BorderRadius.circular(BRadius.cardLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Doctor image: network image if [imageUrl] provided, else placeholder icon
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: imageUrl == null ? BColors.softGrey : null,
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(
                  color: BColors.primary,
                  width: 3,
                ),
              ),
              child: imageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: BColors.darkGrey,
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            //Doctor name with overflow handling
            SizedBox(
              width: 100,
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
        ),
      ),
    );
  }

  //Builds the close button at the bottom
  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 88),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            //Pop back to the first route (ReqestAnalysis)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: BColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 10),
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