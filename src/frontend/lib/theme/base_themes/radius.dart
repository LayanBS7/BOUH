import 'package:flutter/material.dart';

//Unified border radius constants for the app
class BRadius {
  BRadius._();

  //Button radius values
  static const double buttonSmall = 8.0;
  static const double buttonMedium = 12.0;
  static const double buttonLarge = 24.0;

  //Card and container radius
  static const double cardSmall = 8.0;
  static const double cardMedium = 12.0;
  static const double cardLarge = 16.0;

  //Input field radius
  static const double inputField = 12.0;

  //Dropdown radius
  static const double dropdown = 12.0;

  //BorderRadius shortcuts for convenience
  static BorderRadius get buttonSmallRadius => BorderRadius.circular(buttonSmall);
  static BorderRadius get buttonMediumRadius => BorderRadius.circular(buttonMedium);
  static BorderRadius get buttonLargeRadius => BorderRadius.circular(buttonLarge);
  static BorderRadius get inputFieldRadius => BorderRadius.circular(inputField);
  static BorderRadius get dropdownRadius => BorderRadius.circular(dropdown);
}