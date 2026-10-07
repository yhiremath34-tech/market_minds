import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0D14);
  static const Color backgroundSecondary = Color(0xFF10141E);
  static const Color surface = Color(0xFF151B28);
  static const Color surfaceElevated = Color(0xFF1D2436);
  static const Color surfaceHighlight = Color(0xFF263047);
  
  // Borders & Dividers
  static const Color border = Color(0xFF263047);
  static const Color borderSubtle = Color(0xFF1C2436);
  static const Color divider = Color(0xFF1F283C);

  // Brand / Interactive Accent
  static const Color primary = Color(0xFF00E5FF); // Electric Cyan
  static const Color primaryMuted = Color(0xFF0097A7);
  static const Color primaryDark = Color(0xFF006064);
  static const Color secondary = Color(0xFF7C4DFF); // Violet
  static const Color accentGold = Color(0xFFFFB703); // Gold / Streak / Coins

  // Financial Semantics (Restrained, high contrast, colorblind safe)
  static const Color profit = Color(0xFF00E676); // Emerald Green
  static const Color profitBackground = Color(0x1F00E676);
  static const Color loss = Color(0xFFFF5252); // Coral Red
  static const Color lossBackground = Color(0x1FFF5252);
  static const Color neutral = Color(0xFF94A3B8);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Glass / Overlay
  static const Color glassSurface = Color(0x99151B28);
  static const Color glassBorder = Color(0x3300E5FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF181F2F), Color(0xFF111623)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFFB703)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient profitGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
