import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/View/WelcomePage/welcomePage_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    this.onLogin,
    this.onForgotPassword,
    this.onCreateAccount,
  });

  /// Authentication hook.
  /// Implement login logic here (API, Firebase, etc.)
  /// Receives email and password from internal controllers.
  final Future<void> Function(String email, String password)? onLogin;

  /// Navigation hook for forgot-password flow.
  /// Can be replaced with route navigation or modal handling.
  final VoidCallback? onForgotPassword;

  /// Navigation hook for account creation.
  /// Allows overriding default navigation behavior.
  final VoidCallback? onCreateAccount;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  /// Form key reserved for future validation and submission control.
  final _formKey = GlobalKey<FormState>();

  /// Controllers used to retrieve user credentials.
  /// Required for authentication and validation stages.
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Handles login action.
  /// Validation is intentionally not enabled yet to preserve current UI.
  /// Enable validation by adding validators and calling `_formKey.currentState!.validate()`.
  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (widget.onLogin != null) {
      await widget.onLogin!(email, password);
    }
  }

  /// Handles forgot-password action.
  /// Default behavior is no-op unless overridden.
  void _handleForgotPassword() {
    widget.onForgotPassword?.call();
  }

  /// Handles account creation navigation.
  /// Falls back to default route if no override is provided.
  void _handleCreateAccount() {
    if (widget.onCreateAccount != null) {
      widget.onCreateAccount!();
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AccountTypeView()),
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
                  padding: const EdgeInsets.fromLTRB(20, 75, 20, 220),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// Header branding image.
                        Image.asset(
                          'assets/images/login_header.png',
                          width: 160,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 14),

                        /// Screen title.
                        const Text(
                          'أهلًا بعودتك!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: BColors.textDarkestBlue,
                          ),
                        ),
                        const SizedBox(height: 22),

                        /// Email input field.
                        /// Prepared for validation and keyboard navigation.
                        _LabeledField(
                          label: 'البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                          obscure: false,
                          controller: _emailCtrl,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),

                        /// Password input field.
                        /// Submission can be triggered from the keyboard.
                        _LabeledField(
                          label: 'كلمة المرور',
                          keyboardType: TextInputType.text,
                          obscure: true,
                          controller: _passwordCtrl,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 18),

                        /// Login button.
                        /// Connect loading/error states here in the next stage.
                        SizedBox(
                          width: 237,
                          height: 53,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: BColors.secondary,
                              foregroundColor: BColors.textDarkestBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),

                        /// Secondary actions (forgot password / sign up).
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: BColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: _handleForgotPassword,
                                  child: const Text(
                                    'اضغط هنا',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: BColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'لا تمتلك حساب؟',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: BColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: _handleCreateAccount,
                                  child: const Text(
                                    'سجّل الآن',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: BColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Decorative background wave.
              /// Visual-only element; must remain free of logic.
              Positioned(
                left: -350,
                bottom: -250,
                child: Transform.rotate(
                  alignment: Alignment.bottomLeft,
                  angle: 11 * math.pi / 180,
                  child: SizedBox(
                    height: 500,
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

  const _LabeledField({
    required this.label,
    required this.keyboardType,
    required this.obscure,
    required this.controller,
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

        /// TextFormField used to enable future validation
        /// without altering the current UI.
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            filled: true,
            fillColor: BColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
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
