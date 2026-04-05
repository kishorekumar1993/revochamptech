
import 'package:flutter/material.dart';

final LinearGradient primaryGradient = const LinearGradient(
  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ==================== PREMIUM THEME ====================
class PremiumTheme {
  static const darkNavy = Color(0xff0f172a);
  static const richBlue = Color(0xff1e3a8a);
  static const softGray = Color(0xfff8fafc);
  static const lightGray = Color(0xffeef2f6);
  static const accentGold = Color(0xffb89968);
  static const accentGoldLight = Color(0xffd4af85);
  static const textDark = Color(0xff0f172a);
  static const textMuted = Color(0xff64748b);
  static const textLight = Color(0xffa1aec3);
  static const success = Color(0xff10b981);
  static const successBg = Color(0xffd1fae5);
  static const warning = Color(0xfff59e0b);

  static const elegantGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [richBlue, Color(0xff1e40af)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xfffbfcff), Color(0xfff0f4f9), Colors.white],
  );
}

