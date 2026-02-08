import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bouh/View/AccountCreation/Doctor/doctor_account_creation_work_info.dart';

class DoctorAccountCreationStep1 extends StatefulWidget {
  const DoctorAccountCreationStep1({super.key, this.onNext, this.onPickImage});

  final VoidCallback? onNext;
  final Future<File?> Function()? onPickImage;

  @override
  State<DoctorAccountCreationStep1> createState() =>
      _DoctorAccountCreationStep1State();
}

class _DoctorAccountCreationStep1State
    extends State<DoctorAccountCreationStep1> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String _gender = 'female';
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  bool get _isFormComplete =>
      _emailCtrl.text.trim().isNotEmpty &&
      _passCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty &&
      _nameCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (widget.onPickImage != null) {
      final file = await widget.onPickImage!();
      if (file == null) return;
      setState(() => _profileImage = file);
      return;
    }

    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    setState(() => _profileImage = File(x.path));
  }

  void _handleNext() {
    if (!_isFormComplete) return;

    if (widget.onNext != null) {
      widget.onNext!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DoctorAccountCreationStep2()),
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: BColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: BColors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: BColors.primary.withOpacity(0.6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BColors.white,
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ================== CONTENT ==================
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/login_header.png',
                              width: 56,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 18),
                            const Expanded(
                              child: Text(
                                'دقائق قليلة ويكتمل إنشاء الحساب',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: BColors.textDarkestBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      const _StepProgress(
                        rightLabel: 'المعلومات الشخصية',
                        leftLabel: 'معلومات العمل',
                        activeRight: true,
                      ),
                      const SizedBox(height: 18),

                      _LabeledTextField(
                        label: 'البريد الإلكتروني',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        obscure: false,
                        decoration: _inputDecoration(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),

                      _LabeledTextField(
                        label: 'كلمة المرور',
                        controller: _passCtrl,
                        keyboardType: TextInputType.text,
                        obscure: true,
                        decoration: _inputDecoration(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),

                      _LabeledTextField(
                        label: 'تأكيد كلمة المرور',
                        controller: _confirmCtrl,
                        keyboardType: TextInputType.text,
                        obscure: true,
                        decoration: _inputDecoration(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),

                      _LabeledTextField(
                        label: 'الاسم',
                        controller: _nameCtrl,
                        keyboardType: TextInputType.name,
                        obscure: false,
                        decoration: _inputDecoration(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'الجنس',
                          style: TextStyle(
                            fontSize: 13,
                            color: BColors.darkGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      _GenderSegment(
                        value: _gender,
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'صورة شخصية',
                          style: TextStyle(
                            fontSize: 13,
                            color: BColors.darkGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        height: 46,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: BColors.grey),
                          color: BColors.white,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(
                                Icons.download_rounded,
                                color: BColors.primary,
                              ),
                            ),
                            const Spacer(),
                            if (_profileImage != null)
                              const Text(
                                'تم اختيار صورة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: BColors.darkGrey,
                                ),
                              ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isFormComplete ? _handleNext : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: BColors.secondary,
                            foregroundColor: BColors.textDarkestBlue,
                            disabledBackgroundColor: BColors.secondary
                                .withOpacity(0.4),
                            disabledForegroundColor: BColors.textDarkestBlue
                                .withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'التالي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================== BACK ARROW (ON TOP) ==================
              Positioned(
                top: -10,
                right: 30,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: BColors.textDarkestBlue,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final String rightLabel;
  final String leftLabel;
  final bool activeRight;

  const _StepProgress({
    required this.rightLabel,
    required this.leftLabel,
    required this.activeRight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          rightLabel,
          style: const TextStyle(fontSize: 12, color: BColors.darkGrey),
        ),
        const SizedBox(width: 10),
        _Dot(active: activeRight),
        const SizedBox(width: 10),
        const _MiniDots(),
        const SizedBox(width: 10),
        _Dot(active: !activeRight),
        const SizedBox(width: 10),
        Text(
          leftLabel,
          style: const TextStyle(fontSize: 12, color: BColors.darkGrey),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? BColors.primary : BColors.grey,
          width: 2,
        ),
      ),
      child: active
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}

class _MiniDots extends StatelessWidget {
  const _MiniDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: BColors.grey,
          ),
        ),
      ),
    );
  }
}

class _GenderSegment extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GenderSegment({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isFemale = value == 'female';

    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BColors.grey),
        color: BColors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegButton(
              text: 'أنثى',
              selected: isFemale,
              onTap: () => onChanged('female'),
            ),
          ),
          Expanded(
            child: _SegButton(
              text: 'ذكر',
              selected: !isFemale,
              onTap: () => onChanged('male'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SegButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? BColors.accent : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? BColors.textDarkestBlue : BColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final InputDecoration decoration;
  final ValueChanged<String> onChanged;

  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.obscure,
    required this.decoration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: BColors.darkGrey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: decoration,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
