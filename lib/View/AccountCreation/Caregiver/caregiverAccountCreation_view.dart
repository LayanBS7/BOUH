import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/View/AccountCreation/Caregiver/AddChildern_view.dart';

class CaregiverSignupView extends StatefulWidget {
  const CaregiverSignupView({super.key, this.onNext, this.onSubmitCredentials});

  /// Navigation hook for the next step.
  /// Override to replace default navigation behavior.
  final VoidCallback? onNext;

  /// Submission hook for credentials (API/Firebase/etc.).
  /// Override to perform signup/auth before proceeding.
  final Future<void> Function({
    required String email,
    required String password,
    required String confirmPassword,
    required String caregiverName,
  })?
  onSubmitCredentials;

  @override
  State<CaregiverSignupView> createState() => _CaregiverSignupViewState();
}

class _CaregiverSignupViewState extends State<CaregiverSignupView> {
  /// Form key reserved for future validation and submission control.
  final _formKey = GlobalKey<FormState>();

  /// Controllers used to retrieve user input for signup/auth integration.
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  /// Enables the "Next" button only when all fields are filled.
  /// Validation (email format / password match) is intentionally not enabled yet.
  bool get _isFormComplete =>
      _emailCtrl.text.trim().isNotEmpty &&
      _passwordCtrl.text.isNotEmpty &&
      _confirmPasswordCtrl.text.isNotEmpty &&
      _nameCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Handles the "Next" action.
  /// Next stage:
  /// - Add validators and call `_formKey.currentState!.validate()`.
  /// - Enforce password match and backend errors.
  Future<void> _handleNext(BuildContext context) async {
    if (!_isFormComplete) return;

    if (widget.onSubmitCredentials != null) {
      await widget.onSubmitCredentials!(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmPasswordCtrl.text,
        caregiverName: _nameCtrl.text.trim(),
      );
    }

    if (widget.onNext != null) {
      widget.onNext!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CaregiverAccountCreationStep2()),
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
              /// Scrollable container to support small screens and keyboard overlap.
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 30, 22, 240),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Header area (branding + guidance text).
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/login_header.png',
                                width: 60,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 35),
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
                        const SizedBox(height: 28),

                        /// Email field.
                        _LabeledField(
                          label: 'البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                          obscure: false,
                          controller: _emailCtrl,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),

                        /// Password field.
                        _LabeledField(
                          label: 'كلمة المرور',
                          keyboardType: TextInputType.text,
                          obscure: true,
                          controller: _passwordCtrl,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),

                        /// Confirm password field.
                        _LabeledField(
                          label: 'تأكيد كلمة المرور',
                          keyboardType: TextInputType.text,
                          obscure: true,
                          controller: _confirmPasswordCtrl,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),

                        /// Caregiver name field.
                        /// Arabic input is supported by default; keyboard type remains name/text.
                        _LabeledField(
                          label: 'اسم مقدم الرعاية',
                          keyboardType: TextInputType.name,
                          obscure: false,
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleNext(context),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 30),

                        /// Next button.
                        /// Disabled until all fields are filled.
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isFormComplete
                                ? () => _handleNext(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: BColors.secondary,
                              foregroundColor: BColors.textDarkestBlue,
                              disabledBackgroundColor: BColors.secondary
                                  .withOpacity(0.4),
                              disabledForegroundColor: BColors.textDarkestBlue
                                  .withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
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
              ),

              /// Back arrow overlay (consistent across account creation flows).
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

              /// Decorative bottom wave (visual only).
              Positioned(
                left: -400,
                bottom: -290,
                child: Transform.rotate(
                  alignment: Alignment.bottomLeft,
                  angle: 11 * math.pi / 180,
                  child: SizedBox(
                    height: 520,
                    child: Image.asset(
                      'assets/images/wave_login.jpg',
                      fit: BoxFit.cover,
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

class _LabeledField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextInputType keyboardType;

  /// Controller injected from parent for data access and validation.
  final TextEditingController controller;

  /// Enables keyboard navigation between fields.
  final TextInputAction? textInputAction;

  /// Allows triggering submit logic directly from the keyboard.
  final ValueChanged<String>? onFieldSubmitted;

  /// Keeps button state in sync with typing without changing UI.
  final ValueChanged<String> onChanged;

  const _LabeledField({
    required this.label,
    required this.keyboardType,
    required this.obscure,
    required this.controller,
    required this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
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

        /// TextFormField used to enable future validation without altering UI.
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          textAlign: TextAlign.right,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: BColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: BColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: BColors.primary.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }
}
