import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF167A55);
  static const green2 = Color(0xFFE8F5EE);
  static const ink = Color(0xFF17251F);
  static const muted = Color(0xFF748078);
  static const line = Color(0xFFE8EEE9);
  static const rowLine = Color(0xFFF0F3F1);
  static const bg = Color(0xFFF3F6F4);
  static const red = Color(0xFFD84B4B);
  static const heroStart = Color(0xFF126B4B);
  static const heroEnd = Color(0xFF20966A);
  static const lowBg = Color(0xFFFFF3DF);
  static const lowFg = Color(0xFFA46B13);
  static const outBg = Color(0xFFFFEBEB);
  static const outFg = Color(0xFFC23B3B);
  static const iconBg = Color(0xFFF1F5F2);
  static const navActive = Color(0xFFF0F8F3);
  static const navInactive = Color(0xFF9AA59E);
  static const toast = Color(0xFF18382A);
  static const sheetBg = Color(0xFFF8FAF8);
  static const closeBg = Color(0xFFEAF0EC);
}

const TextStyle eyebrowStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: AppColors.muted,
  letterSpacing: 0.7,
);

OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color, width: width),
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.green).copyWith(
    primary: AppColors.green,
    onPrimary: Colors.white,
    error: AppColors.red,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(11));
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      errorStyle: const TextStyle(fontSize: 11, color: AppColors.red),
      border: _border(AppColors.line),
      enabledBorder: _border(AppColors.line),
      focusedBorder: _border(const Color(0xFF7EB69A), 1.5),
      errorBorder: _border(AppColors.red),
      focusedErrorBorder: _border(AppColors.red, 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 46),
        shape: shape,
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.line),
        minimumSize: const Size(0, 46),
        shape: shape,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.green,
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.toast,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
