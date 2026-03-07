import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
class AppColors {
  // Brand
  static const primary = Color(0xFF7B61FF);
  static const primaryDark = Color(0xFF4A148C);
  static const primaryLight = Color(0xFFB39DDB);

  // Gradient
  static const gradientStart = Color(0xFF9B87F5);
  static const gradientEnd = Color(0xFFD4AAFF);

  // Backgrounds
  static const background = Color(0xFFEDE7FF);
  static const surface = Colors.white;
  static const cardBg = Color(0xFFF0EEFF);

  // Borders  ← FIX: was missing, caused errors in 4+ files
  static const border = Color(0xFFDDD6F3);
  static const cardBorder = Color(0xFFEEE8FF);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B8A);
  static const textHint = Color(0xFFAAAAAA);

  // Status
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF2196F3);

  // Health metrics
  static const heartRate = Color(0xFFEF5350);
  static const steps = Color(0xFF42A5F5);
  static const calories = Color(0xFFFF7043);
  static const sleep = Color(0xFF7E57C2);
  static const water = Color(0xFF26C6DA);
  static const weight = Color(0xFF66BB6A);
}

// ── Theme ─────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // ── Fonts ──────────────────────────────────────────────────────────────
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
        titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        bodyLarge:
            GoogleFonts.poppins(fontSize: 15, color: AppColors.textPrimary),
        bodyMedium:
            GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
      ),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // ── Elevated Button ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle:
              GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input Fields ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
        labelStyle:
            GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        errorStyle: GoogleFonts.poppins(color: AppColors.error, fontSize: 12),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      // ── Bottom Nav ─────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ── Reusable gradient decoration ───────────────────────────────────────────
  static const BoxDecoration gradientBox = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.gradientStart, AppColors.gradientEnd],
    ),
  );

  // ── Full screen gradient background ────────────────────────────────────────
  static const BoxDecoration scaffoldGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF9B87F5), Color(0xFFCFB3FF)],
    ),
  );
}
