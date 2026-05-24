// lib/core/theme/app_theme.dart
// BarberQ Dark Theme — mirrors the web dashboard CSS palette
import 'package:flutter/material.dart';

// ── Colors ─────────────────────────────────────────────
class AppColors {
  // Ink (dark neutrals)
  static const Color ink950 = Color(0xFF080808);
  static const Color ink900 = Color(0xFF111111);
  static const Color ink800 = Color(0xFF1A1A1A);
  static const Color ink700 = Color(0xFF242424);
  static const Color ink600 = Color(0xFF2E2E2E);
  static const Color ink400 = Color(0xFF777777);
  static const Color ink200 = Color(0xFFBBBBBB);
  static const Color ink100 = Color(0xFFE0E0E0);

  // Gold (brand accent)
  static const Color gold300 = Color(0xFFFCD34D);
  static const Color gold400 = Color(0xFFFBBF24);
  static const Color gold500 = Color(0xFFF59E0B);
  static const Color gold600 = Color(0xFFD97706);

  // Status colors (matching web badge system)
  static const Color statusMenunggu = Color(0xFF60A5FA); // blue-400
  static const Color statusMenungguBg = Color(0xFF172554); // blue-950
  static const Color statusProses = Color(0xFFFBBF24); // amber-400
  static const Color statusProsesBg = Color(0xFF451A03); // amber-950
  static const Color statusSelesai = Color(0xFF4ADE80); // green-400
  static const Color statusSelesaiBg = Color(0xFF052E16); // green-950
  static const Color statusBatal = Color(0xFFF87171); // red-400
  static const Color statusBatalBg = Color(0xFF450A0A); // red-950

  // Error
  static const Color errorBg = Color(0xFF2A1111);
  static const Color errorBorder = Color(0xFF6A2323);
  static const Color errorText = Color(0xFFFFB1B1);
}

// ── Input Decoration ──────────────────────────────────
InputDecoration barberqInput(String hint, {Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14),
    filled: true,
    fillColor: AppColors.ink800,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.ink600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.ink600),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.gold500, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB23C3C)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB23C3C), width: 1.2),
    ),
    errorStyle: const TextStyle(color: AppColors.errorText, fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    suffixIcon: suffixIcon,
  );
}

// ── Card Decoration ───────────────────────────────────
BoxDecoration barberqCard({bool highlighted = false}) {
  return BoxDecoration(
    color: AppColors.ink900,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: highlighted ? AppColors.gold500.withValues(alpha: 0.4) : AppColors.ink700,
      width: highlighted ? 1.5 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

// ── Status Badge ──────────────────────────────────────
Widget statusBadge(String status) {
  Color bg, text, border;
  String label;

  switch (status) {
    case 'menunggu':
      bg = AppColors.statusMenungguBg;
      text = AppColors.statusMenunggu;
      border = AppColors.statusMenunggu.withValues(alpha: 0.3);
      label = 'Menunggu';
    case 'proses':
      bg = AppColors.statusProsesBg;
      text = AppColors.statusProses;
      border = AppColors.statusProses.withValues(alpha: 0.3);
      label = 'Proses';
    case 'selesai':
      bg = AppColors.statusSelesaiBg;
      text = AppColors.statusSelesai;
      border = AppColors.statusSelesai.withValues(alpha: 0.3);
      label = 'Selesai';
    case 'batal':
      bg = AppColors.statusBatalBg;
      text = AppColors.statusBatal;
      border = AppColors.statusBatal.withValues(alpha: 0.3);
      label = 'Batal';
    default:
      bg = AppColors.ink800;
      text = AppColors.ink400;
      border = AppColors.ink600;
      label = status;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: text,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ── Section Label (uppercase, small, tracking) ────────
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.ink400,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.5,
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.ink400,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ── Gold Filled Button ────────────────────────────────
ButtonStyle goldButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: AppColors.gold500,
    foregroundColor: AppColors.ink950,
    disabledBackgroundColor: AppColors.gold600.withValues(alpha: 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
    ),
  );
}

// ── Global ThemeData ──────────────────────────────────
ThemeData barberqTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.ink950,
    primaryColor: AppColors.gold500,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold500,
      onPrimary: AppColors.ink950,
      secondary: AppColors.gold400,
      surface: AppColors.ink900,
      onSurface: AppColors.ink100,
      error: Color(0xFFF87171),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ink900,
      foregroundColor: AppColors.ink100,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.gold500,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.ink900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.ink700),
      ),
      elevation: 0,
    ),
    dividerColor: AppColors.ink700,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.ink900,
      contentTextStyle: TextStyle(color: AppColors.ink100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.gold500,
      foregroundColor: AppColors.ink950,
      shape: StadiumBorder(),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.gold500,
    ),
    useMaterial3: true,
  );
}
