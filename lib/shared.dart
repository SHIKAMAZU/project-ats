import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle manrope({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? letterSpacing,
  double? height,
  FontStyle? style,
}) {
  return GoogleFonts.manrope(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontStyle: style,
  );
}

TextStyle newsreader({
  double size = 20,
  FontWeight weight = FontWeight.w500,
  Color? color,
  double? letterSpacing,
  double? height,
  FontStyle? style,
}) {
  return GoogleFonts.newsreader(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontStyle: style,
  );
}

class AppColors {
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color secondaryContainer = Color(0xFFDAE2FD);
  static const Color onSecondaryFixed = Color(0xFF131B2E);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color secondary = Color(0xFF565E74);
  static const Color tertiary = Color(0xFF824500);
  static const Color surfaceDim = Color(0xFFCBD9F5);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color tertiaryContainer = Color(0xFFA65900);
  static const Color tertiaryFixed = Color(0xFFFFDCC3);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);
  static const Color inversePrimary = Color(0xFFB4C5FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
}