import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.border,
    required this.inputBorder,
    required this.cardBg,
    required this.textGrey,
    required this.textDark,
    required this.secondaryButton,
    required this.divider,
    required this.emptySection,
    required this.dashedBorder,
    required this.navActive,
    required this.navInactive,
  });

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color border;
  final Color inputBorder;
  final Color cardBg;
  final Color textGrey;
  final Color textDark;
  final Color secondaryButton;
  final Color divider;
  final Color emptySection;
  final Color dashedBorder;
  final Color navActive;
  final Color navInactive;

  static const white = Color(0xFFFFFFFF);

  static const calorieBar = Color(0xFF5B51D4);
  static const proteinBar = Color(0xFF9F8FEF);
  static const carbBar = Color(0xFFB5A8F2);
  static const fatBar = Color(0xFFC9BFF5);
  static const analysisProtein = Color(0xFF5B51D4);
  static const analysisCarb = Color(0xFF9F8FEF);
  static const analysisFat = Color(0xFFC4B8F5);

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  static const light = AppColors(
    primary: Color(0xFF5B51D4),
    primaryLight: Color(0xFFEEEDFE),
    background: Color(0xFFF6F5FF),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFEEEEEE),
    inputBorder: Color(0xFFEBE9F9),
    cardBg: Color(0xFFF8F7FF),
    textGrey: Color(0xFFAAAAAA),
    textDark: Color(0xFF1A1A2E),
    secondaryButton: Color(0xFFFAFAFA),
    divider: Color(0xFFEEEEEE),
    emptySection: Color(0xFFFAFAFA),
    dashedBorder: Color(0xFFE0E0E0),
    navActive: Color(0xFF5B51D4),
    navInactive: Color(0xFFCCCCCC),
  );

  static const dark = AppColors(
    primary: Color(0xFF7B6FE8),
    primaryLight: Color(0xFF1E1B3A),
    background: Color(0xFF0F0F1C),
    surface: Color(0xFF1A1A2E),
    border: Color(0xFF2A2A40),
    inputBorder: Color(0xFF2D2A4A),
    cardBg: Color(0xFF161628),
    textGrey: Color(0xFF888899),
    textDark: Color(0xFFE8E8FF),
    secondaryButton: Color(0xFF1A1A2E),
    divider: Color(0xFF2A2A40),
    emptySection: Color(0xFF141424),
    dashedBorder: Color(0xFF303050),
    navActive: Color(0xFF7B6FE8),
    navInactive: Color(0xFF555566),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? border,
    Color? inputBorder,
    Color? cardBg,
    Color? textGrey,
    Color? textDark,
    Color? secondaryButton,
    Color? divider,
    Color? emptySection,
    Color? dashedBorder,
    Color? navActive,
    Color? navInactive,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      inputBorder: inputBorder ?? this.inputBorder,
      cardBg: cardBg ?? this.cardBg,
      textGrey: textGrey ?? this.textGrey,
      textDark: textDark ?? this.textDark,
      secondaryButton: secondaryButton ?? this.secondaryButton,
      divider: divider ?? this.divider,
      emptySection: emptySection ?? this.emptySection,
      dashedBorder: dashedBorder ?? this.dashedBorder,
      navActive: navActive ?? this.navActive,
      navInactive: navInactive ?? this.navInactive,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      textGrey: Color.lerp(textGrey, other.textGrey, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      secondaryButton: Color.lerp(secondaryButton, other.secondaryButton, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      emptySection: Color.lerp(emptySection, other.emptySection, t)!,
      dashedBorder: Color.lerp(dashedBorder, other.dashedBorder, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
    );
  }
}
