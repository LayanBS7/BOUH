import 'package:bouh/View/BookAppointment/BookAppointment.dart';
import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({super.key});

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  // 0 = qualifications, 1 = booking
  int tabIndex = 0;

  // THIS IS DUMMY (replace later from controller)
  final String doctorName = "د. علي آل يحيى";
  final String doctorMajor = "قلق وتوتر";
  final double rating = 4.5;
  final int years = 10;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Scroll content (card starts at top)
            SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _DoctorInfoCard(
                    doctorName: doctorName,
                    doctorMajor: doctorMajor,
                    rating: rating,
                    years: years,
                    tabIndex: tabIndex,
                    onTapQualifications: () => setState(() => tabIndex = 0),
                    onTapBooking: () => setState(() => tabIndex = 1),
                  ),

                  const SizedBox(height: 18),

                  // Padding فقط للجزء اللي تحت
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        if (tabIndex == 0) const _QualificationsSection(),
                        if (tabIndex == 1) const BookingView(),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Back button فوق كل شيء
            SafeArea(
              child: Positioned(
                top: 8,
                right: 12,
                child: InkWell(
                  onTap: () => Navigator.pop(
                    context,
                  ), //change later connect to the list of doctors page
                  child: const Icon(Icons.chevron_left, size: 34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Doctor info card
class _DoctorInfoCard extends StatelessWidget {
  final String doctorName;
  final String doctorMajor;
  final double rating;
  final int years;
  final int tabIndex;
  final VoidCallback onTapQualifications;
  final VoidCallback onTapBooking;

  const _DoctorInfoCard({
    required this.doctorName,
    required this.doctorMajor,
    required this.rating,
    required this.years,
    required this.tabIndex,
    required this.onTapQualifications,
    required this.onTapBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
      decoration: BoxDecoration(
        color: BColors.accent.withOpacity(0.01),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        border: Border.all(color: BColors.accent.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // avatar on the right
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                //IF THERE IS PHOTO REPLACE BY THE PHOTO LATER
                child: Icon(
                  Icons.person,
                  size: 34,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(width: 7),

              //name and major
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withOpacity(0.78),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doctorMajor,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),

              //rating and years of experince
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9.52),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 34,
                          width: 32,
                          decoration: BoxDecoration(
                            color: BColors.primary.withOpacity(0.75),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "4.5", //THIS IS DUMMY DATA
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "التقييم",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 64,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9.52),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 34,
                          width: 32,
                          decoration: BoxDecoration(
                            color: BColors.primary.withOpacity(0.35),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "10", //THIS IS DUMMY
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "سنوات الخبرة",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // name/subtitle
            ],
          ),

          const SizedBox(height: 14),

          //Qualifications first, then booking
          Row(
            children: [
              Expanded(
                child: _SegmentBtn(
                  text: "المؤهلات",
                  selected: tabIndex == 0,
                  onTap: onTapQualifications,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SegmentBtn(
                  text: "ابحث عن موعد",
                  selected: tabIndex == 1,
                  onTap: onTapBooking,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Segment button
class _SegmentBtn extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentBtn({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.67),
          border: Border.all(
            color: selected
                ? BColors.primary.withOpacity(0.35)
                : Colors.black.withOpacity(0.10),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.75),
          ),
        ),
      ),
    );
  }
}

// Qualifications section
class _QualificationsSection extends StatelessWidget {
  const _QualificationsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "المؤهلات",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
          //THESE ARE DUMMY DATA (CAN BE PARAGRAH OR BULLET POINTS)
          const SizedBox(height: 10),
          Text(
            "نهج علاجي يجمع بين الدقة الطبية والإنصات الحقيقي.\n"
            "خطة واضحة، متابعة دقيقة، وأدوات عملية تساعد على التحكم بالقلق والتوتر.",
            style: TextStyle(
              fontSize: 14.5,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.60),
            ),
          ),
          const SizedBox(height: 14),
          _bullet("تشخيص شامل وربط الأعراض بالمحفزات اليومية."),
          _bullet("خطط علاج شخصية: جلسات، تمارين، ومتابعة قابلة للقياس."),
          _bullet("تثقيف مبسط للمراجع وذويه لرفع الالتزام وتقليل الانتكاس."),
          _bullet("خبرة في تنظيم المواعيد والمتابعة لضمان أفضل نتيجة."),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: BColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
