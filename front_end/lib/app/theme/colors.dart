import 'package:flutter/material.dart';

class ColorManager {
  // Primary Gradient 
  static const LinearGradient primary = LinearGradient(
    colors: [
      Color(0xFF96DEDA),
      Color(0xFF86D9D5),
      Color(0xFF7BD6D1),
      Color(0xFF69D0CB),
      Color(0xFF50C9C3),
    ],
    stops: [0.0, 0.26, 0.46, 0.65, 0.95],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary Solid
  static const Color primarySolid = Color(0xFF50C9C3);

  static const Color secondarySolid = Color(0xFF00A79E);

  static const Color floatingPrimary = Color(0xFFABE9E7);

  static const Color black = Color(0xFF000000);

  static const Color background = Colors.white;

  static const Color textPrimary = Color(0xFF1C1C1E);

  static const Color textSecondary = Color(0xFF8E8E93);

  static const Color border = Color(0xFFE5E5EA);

  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassTint = Color(0x0FFFFFFF);

  static const Color card = Color(0xFFFFFFFF);

  // Gradient phụ — dùng khi muốn cảm giác "techy" hoặc animation
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF63A4E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
