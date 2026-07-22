import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyle {
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Common pre-defined text styles
  static TextStyle get greeting => poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.darkGreen,
  );

  static TextStyle get sectionTitle => poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGreen,
  );

  static TextStyle get cardTitle => poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.darkGreen,
  );

  static TextStyle get buttonText =>
      poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

  static TextStyle get bodyText =>
      poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black);
  
  // Category Detail Page specific styles
  static TextStyle get kategoriTitle => poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  
  static TextStyle get alamatTitle => poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.darkGreen,
  );
  
  static TextStyle get timeDisplay => poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGreen,
  );
}
