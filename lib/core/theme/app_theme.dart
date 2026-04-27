import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme get _textTheme => GoogleFonts.notoSansKrTextTheme();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        extensions: const [AppColors.light],
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5B51D4),
          surface: Color(0xFFF6F5FF),
          onPrimary: AppColors.white,
          onSurface: Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: AppColors.light.background,
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.light.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.notoSansKr(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.light.textDark,
          ),
          iconTheme: IconThemeData(color: AppColors.light.textDark),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.light.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: AppColors.light.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: AppColors.light.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide:
                BorderSide(color: AppColors.light.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.light.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 40),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: GoogleFonts.notoSansKr(
                fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.light.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.light.border, width: 0.5),
          ),
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.light.surface,
          selectedItemColor: AppColors.light.navActive,
          unselectedItemColor: AppColors.light.navInactive,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 9),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        extensions: const [AppColors.dark],
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7B6FE8),
          surface: Color(0xFF0F0F1C),
          onPrimary: AppColors.white,
          onSurface: Color(0xFFE8E8FF),
        ),
        scaffoldBackgroundColor: AppColors.dark.background,
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.dark.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.notoSansKr(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.dark.textDark,
          ),
          iconTheme: IconThemeData(color: AppColors.dark.textDark),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.dark.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: AppColors.dark.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: AppColors.dark.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: AppColors.dark.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dark.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 40),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: GoogleFonts.notoSansKr(
                fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.dark.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.dark.border, width: 0.5),
          ),
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.dark.surface,
          selectedItemColor: AppColors.dark.navActive,
          unselectedItemColor: AppColors.dark.navInactive,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 9),
        ),
      );
}
