import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextStyle get display => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get headline => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextTheme textTheme(
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
  ) {
    return TextTheme(
      displayLarge: display.copyWith(color: textPrimary),
      displayMedium: display.copyWith(color: textPrimary),
      displaySmall: display.copyWith(color: textPrimary),
      headlineLarge: headline.copyWith(color: textPrimary),
      headlineMedium: headline.copyWith(color: textPrimary),
      headlineSmall: headline.copyWith(color: textPrimary),
      titleLarge: title.copyWith(color: textPrimary),
      titleMedium: title.copyWith(color: textPrimary),
      titleSmall: title.copyWith(color: textSecondary),
      bodyLarge: bodyLarge.copyWith(color: textPrimary),
      bodyMedium: body.copyWith(color: textPrimary),
      bodySmall: bodySmall.copyWith(color: textSecondary),
      labelLarge: label.copyWith(color: textPrimary),
      labelMedium: label.copyWith(color: textSecondary),
      labelSmall: caption.copyWith(color: textTertiary),
    );
  }
}
