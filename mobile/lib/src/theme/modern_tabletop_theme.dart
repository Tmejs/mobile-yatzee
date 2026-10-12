import 'package:flutter/material.dart';

@immutable
final class TabletopTheme extends ThemeExtension<TabletopTheme> {
  const TabletopTheme({
    required this.felt,
    required this.ivory,
    required this.gold,
    required this.error,
    required this.success,
    required this.spacing,
    required this.radius,
    required this.elevation,
    required this.titleStyle,
    required this.bodyStyle,
  });

  static const standard = TabletopTheme(
    felt: Color(0xFF123C2F),
    ivory: Color(0xFFF4EAD2),
    gold: Color(0xFFC99A2E),
    error: Color(0xFFB3261E),
    success: Color(0xFF2E7D32),
    spacing: 12,
    radius: 16,
    elevation: 3,
    titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    bodyStyle: TextStyle(fontSize: 15, height: 1.25),
  );

  final Color felt, ivory, gold, error, success;
  final double spacing, radius, elevation;
  final TextStyle titleStyle, bodyStyle;

  @override
  TabletopTheme copyWith({
    Color? felt,
    Color? ivory,
    Color? gold,
    Color? error,
    Color? success,
    double? spacing,
    double? radius,
    double? elevation,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
  }) => TabletopTheme(
    felt: felt ?? this.felt,
    ivory: ivory ?? this.ivory,
    gold: gold ?? this.gold,
    error: error ?? this.error,
    success: success ?? this.success,
    spacing: spacing ?? this.spacing,
    radius: radius ?? this.radius,
    elevation: elevation ?? this.elevation,
    titleStyle: titleStyle ?? this.titleStyle,
    bodyStyle: bodyStyle ?? this.bodyStyle,
  );

  @override
  TabletopTheme lerp(covariant TabletopTheme? other, double t) {
    if (other == null) return this;
    return TabletopTheme(
      felt: Color.lerp(felt, other.felt, t)!,
      ivory: Color.lerp(ivory, other.ivory, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      spacing: spacing + (other.spacing - spacing) * t,
      radius: radius + (other.radius - radius) * t,
      elevation: elevation + (other.elevation - elevation) * t,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      bodyStyle: TextStyle.lerp(bodyStyle, other.bodyStyle, t)!,
    );
  }
}

ThemeData modernTabletopTheme() {
  const tokens = TabletopTheme.standard;
  final scheme = ColorScheme.fromSeed(
    seedColor: tokens.felt,
    primary: tokens.felt,
    secondary: tokens.gold,
    surface: tokens.ivory,
    error: tokens.error,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.felt,
    extensions: const [tokens],
    textTheme: Typography.material2021().black.apply(
      bodyColor: tokens.felt,
      displayColor: tokens.felt,
    ),
    cardTheme: CardThemeData(
      color: tokens.ivory,
      elevation: tokens.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
    ),
  );
}
