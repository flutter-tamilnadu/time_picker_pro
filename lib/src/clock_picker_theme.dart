import 'package:flutter/material.dart';

/// Theme configuration for the [ClockTimePicker] package.
///
/// Use this class to customize all elements of the analog clock time picker,
/// including backgrounds, hand shapes, glow effects, typography, and button styles.
class ClockPickerThemeData {
  /// The background color of the main picker container.
  final Color backgroundColor;

  /// The background color (or base color) of the clock face dial.
  final Color clockFaceBackgroundColor;

  /// An optional gradient for the clock face. If provided, overrides [clockFaceBackgroundColor].
  final Gradient? clockFaceGradient;

  /// The shadows applied to the clock face to give it depth (skeuomorphic look).
  final List<BoxShadow>? clockFaceShadows;

  /// The color of the outer dial tick marks (60 minute/second marks).
  final Color outerDialTickColor;

  /// The color of the non-selected hour numbers (1 to 12) on the dial.
  final Color hourNumberColor;

  /// The color of the selected/highlighted hour number.
  final Color selectedHourNumberColor;

  /// The color of the glowing accent behind the selected hour hand tip and selected number.
  final Color selectedHourHighlightColor;

  /// The base color of the clock hands.
  final Color handColor;

  /// The highlight or accent color of the hour hand (often matching the selected hour highlight).
  final Color hourHandColor;

  /// The highlight or accent color of the minute hand.
  final Color minuteHandColor;

  /// The glow color for the hour hand.
  final Color hourHandGlowColor;

  /// The glow color for the minute hand.
  final Color minuteHandGlowColor;

  /// The text color of the "Set Time:" label.
  final Color centerLabelColor;

  /// The text color of the digital time in the clock center.
  final Color centerTimeColor;

  /// The text color of the period (Morning/Afternoon etc.) text in the center.
  final Color centerPeriodColor;

  /// The text color of the top digital display.
  final Color headerTimeColor;

  /// The text color of the main title header.
  final Color titleColor;

  /// The text color of the subtitle header.
  final Color subtitleColor;

  /// Whether to show glowing blur effects on hands, selected hour, and buttons.
  final bool showGlow;

  /// The strength of the glow effects, controlling the blur radius (typically 0.0 to 1.0).
  final double glowStrength;

  /// The background color of the confirm button.
  final Color confirmButtonBackgroundColor;

  /// The text color of the confirm button.
  final Color confirmButtonTextColor;

  /// The border color of the confirm button.
  final Color confirmButtonBorderColor;

  /// The glow/shadow color of the confirm button.
  final Color confirmButtonGlowColor;

  /// Custom TextStyle for the main title.
  final TextStyle? titleStyle;

  /// Custom TextStyle for the subtitle.
  final TextStyle? subtitleStyle;

  /// Custom TextStyle for the large top digital time.
  final TextStyle? headerTimeStyle;

  /// Custom TextStyle for the "Set Time:" label.
  final TextStyle? centerLabelStyle;

  /// Custom TextStyle for the digital time in the clock center.
  final TextStyle? centerTimeStyle;

  /// Custom TextStyle for the period (Morning/Night etc.) text in the center.
  final TextStyle? centerPeriodStyle;

  /// Custom TextStyle for the hour numbers on the clock face dial.
  final TextStyle? hourNumberStyle;

  /// Custom TextStyle for the confirm button.
  final TextStyle? confirmButtonStyle;

  const ClockPickerThemeData({
    required this.backgroundColor,
    required this.clockFaceBackgroundColor,
    this.clockFaceGradient,
    this.clockFaceShadows,
    required this.outerDialTickColor,
    required this.hourNumberColor,
    required this.selectedHourNumberColor,
    required this.selectedHourHighlightColor,
    required this.handColor,
    required this.hourHandColor,
    required this.minuteHandColor,
    required this.hourHandGlowColor,
    required this.minuteHandGlowColor,
    required this.centerLabelColor,
    required this.centerTimeColor,
    required this.centerPeriodColor,
    required this.headerTimeColor,
    required this.titleColor,
    required this.subtitleColor,
    this.showGlow = true,
    this.glowStrength = 1.0,
    required this.confirmButtonBackgroundColor,
    required this.confirmButtonTextColor,
    required this.confirmButtonBorderColor,
    required this.confirmButtonGlowColor,
    this.titleStyle,
    this.subtitleStyle,
    this.headerTimeStyle,
    this.centerLabelStyle,
    this.centerTimeStyle,
    this.centerPeriodStyle,
    this.hourNumberStyle,
    this.confirmButtonStyle,
  });

  /// The default Clean White Theme, matching the left side of the reference image.
  factory ClockPickerThemeData.light() {
    return ClockPickerThemeData(
      backgroundColor: const Color(0xFFF8FAFC), // Soft clean background
      clockFaceBackgroundColor: const Color(0xFFF1F5F9),
      clockFaceGradient: const RadialGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF1F5F9),
        ],
        center: Alignment.center,
        radius: 0.9,
      ),
      clockFaceShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.95),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(-4, -4),
        ),
      ],
      outerDialTickColor: const Color(0xFF94A3B8), // slate-400
      hourNumberColor: const Color(0xFF334155), // slate-700
      selectedHourNumberColor: const Color(0xFF3B82F6), // blue-500
      selectedHourHighlightColor: const Color(0xFF3B82F6).withOpacity(0.12),
      handColor: const Color(0xFF1E293B), // slate-800
      hourHandColor: const Color(0xFF3B82F6), // blue-500
      minuteHandColor: const Color(0xFF1E293B), // slate-800
      hourHandGlowColor: const Color(0xFF3B82F6).withOpacity(0.35),
      minuteHandGlowColor: const Color(0xFF1E293B).withOpacity(0.08),
      centerLabelColor: const Color(0xFF64748B), // slate-500
      centerTimeColor: const Color(0xFF1E293B), // slate-800
      centerPeriodColor: const Color(0xFF64748B), // slate-500
      headerTimeColor: const Color(0xFF1E293B), // slate-800
      titleColor: const Color(0xFF1E293B), // slate-800
      subtitleColor: const Color(0xFF64748B), // slate-500
      showGlow: true,
      glowStrength: 0.8,
      confirmButtonBackgroundColor: Colors.white,
      confirmButtonTextColor: const Color(0xFF475569), // slate-600
      confirmButtonBorderColor: const Color(0xFFCBD5E1), // slate-300
      confirmButtonGlowColor: Colors.black.withOpacity(0.04),
    );
  }

  /// The default Sleek Dark Mode Theme, matching the right side of the reference image.
  factory ClockPickerThemeData.dark() {
    return ClockPickerThemeData(
      backgroundColor: const Color(0xFF0F172A), // Slate-900
      clockFaceBackgroundColor: const Color(0xFF1E293B), // Slate-800
      clockFaceGradient: const RadialGradient(
        colors: [
          Color(0xFF1E293B),
          Color(0xFF0F172A),
        ],
        center: Alignment.center,
        radius: 1.0,
      ),
      clockFaceShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 24,
          spreadRadius: 2,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF1E293B).withOpacity(0.15),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(-4, -4),
        ),
      ],
      outerDialTickColor: const Color(0xFF475569), // slate-600
      hourNumberColor: const Color(0xFF94A3B8), // slate-400
      selectedHourNumberColor: const Color(0xFF14B8A6), // teal-500
      selectedHourHighlightColor: const Color(0xFF14B8A6).withOpacity(0.35),
      handColor: const Color(0xFF0F172A), // Slate-900 base
      hourHandColor: const Color(0xFF14B8A6), // teal-500
      minuteHandColor: const Color(0xFF0D9488), // teal-600
      hourHandGlowColor: const Color(0xFF14B8A6).withOpacity(0.6),
      minuteHandGlowColor: const Color(0xFF0D9488).withOpacity(0.3),
      centerLabelColor: const Color(0xFF64748B), // slate-500
      centerTimeColor: Colors.white,
      centerPeriodColor: const Color(0xFF94A3B8), // slate-400
      headerTimeColor: Colors.white,
      titleColor: Colors.white,
      subtitleColor: const Color(0xFF94A3B8), // slate-400
      showGlow: true,
      glowStrength: 1.0,
      confirmButtonBackgroundColor: const Color(0xFF0F172A),
      confirmButtonTextColor: const Color(0xFF14B8A6), // teal-500
      confirmButtonBorderColor: const Color(0xFF0D9488).withOpacity(0.4),
      confirmButtonGlowColor: const Color(0xFF14B8A6).withOpacity(0.25),
    );
  }

  /// Copies this theme data but with the given fields replaced.
  ClockPickerThemeData copyWith({
    Color? backgroundColor,
    Color? clockFaceBackgroundColor,
    Gradient? clockFaceGradient,
    List<BoxShadow>? clockFaceShadows,
    Color? outerDialTickColor,
    Color? hourNumberColor,
    Color? selectedHourNumberColor,
    Color? selectedHourHighlightColor,
    Color? handColor,
    Color? hourHandColor,
    Color? minuteHandColor,
    Color? hourHandGlowColor,
    Color? minuteHandGlowColor,
    Color? centerLabelColor,
    Color? centerTimeColor,
    Color? centerPeriodColor,
    Color? headerTimeColor,
    Color? titleColor,
    Color? subtitleColor,
    bool? showGlow,
    double? glowStrength,
    Color? confirmButtonBackgroundColor,
    Color? confirmButtonTextColor,
    Color? confirmButtonBorderColor,
    Color? confirmButtonGlowColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? headerTimeStyle,
    TextStyle? centerLabelStyle,
    TextStyle? centerTimeStyle,
    TextStyle? centerPeriodStyle,
    TextStyle? hourNumberStyle,
    TextStyle? confirmButtonStyle,
  }) {
    return ClockPickerThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      clockFaceBackgroundColor: clockFaceBackgroundColor ?? this.clockFaceBackgroundColor,
      clockFaceGradient: clockFaceGradient ?? this.clockFaceGradient,
      clockFaceShadows: clockFaceShadows ?? this.clockFaceShadows,
      outerDialTickColor: outerDialTickColor ?? this.outerDialTickColor,
      hourNumberColor: hourNumberColor ?? this.hourNumberColor,
      selectedHourNumberColor: selectedHourNumberColor ?? this.selectedHourNumberColor,
      selectedHourHighlightColor: selectedHourHighlightColor ?? this.selectedHourHighlightColor,
      handColor: handColor ?? this.handColor,
      hourHandColor: hourHandColor ?? this.hourHandColor,
      minuteHandColor: minuteHandColor ?? this.minuteHandColor,
      hourHandGlowColor: hourHandGlowColor ?? this.hourHandGlowColor,
      minuteHandGlowColor: minuteHandGlowColor ?? this.minuteHandGlowColor,
      centerLabelColor: centerLabelColor ?? this.centerLabelColor,
      centerTimeColor: centerTimeColor ?? this.centerTimeColor,
      centerPeriodColor: centerPeriodColor ?? this.centerPeriodColor,
      headerTimeColor: headerTimeColor ?? this.headerTimeColor,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      showGlow: showGlow ?? this.showGlow,
      glowStrength: glowStrength ?? this.glowStrength,
      confirmButtonBackgroundColor: confirmButtonBackgroundColor ?? this.confirmButtonBackgroundColor,
      confirmButtonTextColor: confirmButtonTextColor ?? this.confirmButtonTextColor,
      confirmButtonBorderColor: confirmButtonBorderColor ?? this.confirmButtonBorderColor,
      confirmButtonGlowColor: confirmButtonGlowColor ?? this.confirmButtonGlowColor,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      headerTimeStyle: headerTimeStyle ?? this.headerTimeStyle,
      centerLabelStyle: centerLabelStyle ?? this.centerLabelStyle,
      centerTimeStyle: centerTimeStyle ?? this.centerTimeStyle,
      centerPeriodStyle: centerPeriodStyle ?? this.centerPeriodStyle,
      hourNumberStyle: hourNumberStyle ?? this.hourNumberStyle,
      confirmButtonStyle: confirmButtonStyle ?? this.confirmButtonStyle,
    );
  }
}
