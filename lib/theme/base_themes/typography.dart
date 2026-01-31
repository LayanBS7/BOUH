import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Typography constants using Cairo font (best for Arabic apps)
class BTypography {
  BTypography._();

  /// Font family name
  static const String fontFamily = 'Cairo';

  /// Get Cairo text style with custom properties
  static TextStyle cairo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = BColors.textBlack,
    double? height,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Predefined text styles

  /// Page title - large bold text
  static TextStyle get pageTitle => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: BColors.textDarkestBlue,
      );

  /// Section title - medium bold text
  static TextStyle get sectionTitle => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: BColors.textDarkestBlue,
      );

  /// Button text - medium weight
  static TextStyle get buttonText => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: BColors.white,
      );

  /// Button text secondary - for outlined buttons
  static TextStyle get buttonTextSecondary => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: BColors.primary,
      );

  /// Body text - regular
  static TextStyle get bodyText => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: BColors.textBlack,
      );

  /// Label text - small
  static TextStyle get labelText => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: BColors.darkerGrey,
      );

  /// Dropdown hint text
  static TextStyle get dropdownHint => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: BColors.darkGrey,
      );

  /// Dropdown selected text
  static TextStyle get dropdownSelected => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: BColors.textDarkestBlue,
      );
}
