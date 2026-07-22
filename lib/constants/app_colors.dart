import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFDDF3D8);
  static const Color yellow = Color(0xFFF9E18C);
  static const Color orange = Color(0xFFE98A63);
  static const Color pink = Color(0xFFF2B5C8);
  static const Color pastelGreen = Color(0xFFBFE8BF);
  static const Color capsuleYellow = Color(0xFFFFF5C4);
  
  // Address card gradient
  static const Color addressLight = Color(0xFFD7F3D6);
  static const Color addressDark = Color(0xFFBEE2BE);
  
  static final Color shadow = Colors.black.withValues(alpha: 0.15);
  
  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryGreen, darkGreen],
  );
  
  static const LinearGradient addressGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [addressLight, addressDark],
  );
}
