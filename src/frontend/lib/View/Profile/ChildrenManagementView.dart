import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';

class ChildrenManagementView extends StatelessWidget {
  const ChildrenManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    // DUMMY children list (later replace from contoller) I added it as an array to make the UI ready to go over a loop
    final List<Map<String, dynamic>> children = [
      {
        "name": "دانا آل يحيى",
        "isFemale": true,
        "day": "8",
        "month": "2",
        "year": "2016",
      },
      {
        "name": "بسّام آل يحيى",
        "isFemale": false,
        "day": "12",
        "month": "6",
        "year": "2019",
      },
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {}, // TODO later
          backgroundColor: BColors.accent,
          shape: const CircleBorder(),
          elevation: 6,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Title row
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_outlined,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 80),
                    Text(
                      "ادارة الاطفال",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                //goes over every child
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 90),
                    children: [
                      ...children.map((child) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _childCard(
                            name: child["name"],
                            isFemaleSelected: child["isFemale"],
                            day: child["day"],
                            month: child["month"],
                            year: child["year"],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // CARD METHOD (call for each child later)
  Widget _childCard({
    required String name,
    required bool isFemaleSelected,
    required String day,
    required String month,
    required String year,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              _circleIconButton(
                icon: Icons.edit,
                iconColor: Colors.grey,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _circleIconButton(
                icon: Icons.delete_outline,
                iconColor: Colors.redAccent,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Name label + field
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "الاسم",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.40),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _inputBox(value: name),

          const SizedBox(height: 14),

          // Gender + DOB
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DOB
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "تاريخ الميلاد",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _tinyBox(label: "السنه", value: year),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _tinyBox(label: "الشهر", value: month),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _tinyBox(label: "اليوم", value: day),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Gender segmented control
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الجنس",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    _genderSegmented(isFemaleSelected: isFemaleSelected),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI helpers

  Widget _circleIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _inputBox({required String value}) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.21),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _tinyBox({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.89,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.35),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.21),
            border: Border.all(color: Colors.black.withOpacity(0.10)),
            color: Colors.white,
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _genderSegmented({required bool isFemaleSelected}) {
    final borderColor = Colors.black.withOpacity(0.10);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.21),
          border: Border.all(color: borderColor),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.21),
          child: Row(
            children: [
              // LEFT: Male (unselected)
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: isFemaleSelected ? Colors.white : BColors.accent,
                  child: Text(
                    "ذكر",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isFemaleSelected
                          ? Colors.black.withOpacity(0.75)
                          : Colors.white,
                    ),
                  ),
                ),
              ),

              // Divider
              Container(width: 1, color: borderColor),

              // RIGHT: Female (selected example)
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: isFemaleSelected ? BColors.accent : Colors.white,
                  child: Text(
                    "أنثى",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isFemaleSelected
                          ? Colors.white
                          : Colors.black.withOpacity(0.75),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
