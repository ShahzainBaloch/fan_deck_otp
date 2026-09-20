import 'package:flutter/material.dart';

/// Theming and styling configuration for [FanDeckOtpField].
@immutable
class FanDeckOtpTheme {
  /// Width of each digit box. If null, automatically scales to fit within available width.
  final double? boxWidth;

  /// Height of each digit box. Defaults to 56.0.
  final double boxHeight;

  /// Spacing between boxes when in separated row layout. If null, evenly distributed.
  final double? gap;

  /// Border radius of the boxes. Defaults to `BorderRadius.circular(12)`.
  final BorderRadius borderRadius;

  /// Border color for currently focused box.
  final Color activeBorderColor;

  /// Border color for already filled boxes.
  final Color filledBorderColor;

  /// Border color for inactive empty boxes.
  final Color inactiveBorderColor;

  /// Border color when in error state.
  final Color errorBorderColor;

  /// Border width for inactive/filled boxes. Defaults to 1.2.
  final double borderWidth;

  /// Border width for active box. Defaults to 2.0.
  final double activeBorderWidth;

  /// Border width for error state. Defaults to 2.0.
  final double errorBorderWidth;

  /// Background color for the currently active/focused box.
  final Color activeFillColor;

  /// Background color for filled boxes.
  final Color filledFillColor;

  /// Background color for inactive empty boxes.
  final Color inactiveFillColor;

  /// Background color when in error state.
  final Color errorFillColor;

  /// Typography style for the entered digits.
  final TextStyle textStyle;

  /// Typography style for digits during error state.
  final TextStyle errorTextStyle;

  /// Optional shadow for standard boxes.
  final List<BoxShadow>? boxShadow;

  /// Optional shadow for the active/focused box.
  final List<BoxShadow>? activeBoxShadow;

  /// Optional shadow when in error state.
  final List<BoxShadow>? errorBoxShadow;

  /// Colors used for the neon SweepGradient rotating border loader.
  final List<Color> loaderColors;

  /// Outer glowing line stroke width for loader. Defaults to 3.0.
  final double loaderGlowWidth;

  /// Inner sharp line stroke width for loader. Defaults to 2.0.
  final double loaderLineWidth;

  /// Blur radius for the outer glow filter. Defaults to 2.0.
  final double loaderBlurRadius;

  /// Maximum angular fan-out in degrees for outer cards (e.g. ±25°).
  final double maxFanAngle;

  /// Transform pivot alignment around which cards rotate when fanning.
  /// Defaults to `Alignment(0.0, 3.0)` to create an elegant deck-like fan arc.
  final Alignment fanPivotAlignment;

  /// Duration of the 2-stage fan and collapse animation. Defaults to 900ms.
  final Duration fanDuration;

  /// Duration of the error shake oscillation. Defaults to 450ms.
  final Duration shakeDuration;

  /// Duration of the digit opacity fade out on error. Defaults to 200ms.
  final Duration dissolveDuration;

  /// Duration for one complete 360° spin of the border loader. Defaults to 1500ms.
  final Duration loaderDuration;

  const FanDeckOtpTheme({
    this.boxWidth,
    this.boxHeight = 56.0,
    this.gap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.activeBorderColor = const Color(0xFF2D7BD9),
    this.filledBorderColor = const Color(0x992D7BD9),
    this.inactiveBorderColor = const Color(0xFFCBD5E1),
    this.errorBorderColor = const Color(0xFFEF4444),
    this.borderWidth = 1.2,
    this.activeBorderWidth = 2.0,
    this.errorBorderWidth = 2.0,
    this.activeFillColor = const Color(0xFFEFF6FF),
    this.filledFillColor = Colors.white,
    this.inactiveFillColor = const Color(0xFFF8FAFC),
    this.errorFillColor = const Color(0xFFFEF2F2),
    this.textStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF0F172A),
    ),
    this.errorTextStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFFDC2626),
    ),
    this.boxShadow,
    this.activeBoxShadow = const [
      BoxShadow(
        color: Color(0x1F2D7BD9),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
    this.errorBoxShadow = const [
      BoxShadow(
        color: Color(0x2EEF4444),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
    this.loaderColors = const [
      Color(0xFF2D7BD9),
      Color(0xFF00F0FF),
      Color(0xFF2D7BD9),
    ],
    this.loaderGlowWidth = 3.0,
    this.loaderLineWidth = 2.0,
    this.loaderBlurRadius = 2.0,
    this.maxFanAngle = 25.0,
    this.fanPivotAlignment = const Alignment(0.0, 3.0),
    this.fanDuration = const Duration(milliseconds: 900),
    this.shakeDuration = const Duration(milliseconds: 450),
    this.dissolveDuration = const Duration(milliseconds: 200),
    this.loaderDuration = const Duration(milliseconds: 1500),
  });

  FanDeckOtpTheme copyWith({
    double? boxWidth,
    double? boxHeight,
    double? gap,
    BorderRadius? borderRadius,
    Color? activeBorderColor,
    Color? filledBorderColor,
    Color? inactiveBorderColor,
    Color? errorBorderColor,
    double? borderWidth,
    double? activeBorderWidth,
    double? errorBorderWidth,
    Color? activeFillColor,
    Color? filledFillColor,
    Color? inactiveFillColor,
    Color? errorFillColor,
    TextStyle? textStyle,
    TextStyle? errorTextStyle,
    List<BoxShadow>? boxShadow,
    List<BoxShadow>? activeBoxShadow,
    List<BoxShadow>? errorBoxShadow,
    List<Color>? loaderColors,
    double? loaderGlowWidth,
    double? loaderLineWidth,
    double? loaderBlurRadius,
    double? maxFanAngle,
    Alignment? fanPivotAlignment,
    Duration? fanDuration,
    Duration? shakeDuration,
    Duration? dissolveDuration,
    Duration? loaderDuration,
  }) {
    return FanDeckOtpTheme(
      boxWidth: boxWidth ?? this.boxWidth,
      boxHeight: boxHeight ?? this.boxHeight,
      gap: gap ?? this.gap,
      borderRadius: borderRadius ?? this.borderRadius,
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      filledBorderColor: filledBorderColor ?? this.filledBorderColor,
      inactiveBorderColor: inactiveBorderColor ?? this.inactiveBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      activeBorderWidth: activeBorderWidth ?? this.activeBorderWidth,
      errorBorderWidth: errorBorderWidth ?? this.errorBorderWidth,
      activeFillColor: activeFillColor ?? this.activeFillColor,
      filledFillColor: filledFillColor ?? this.filledFillColor,
      inactiveFillColor: inactiveFillColor ?? this.inactiveFillColor,
      errorFillColor: errorFillColor ?? this.errorFillColor,
      textStyle: textStyle ?? this.textStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      boxShadow: boxShadow ?? this.boxShadow,
      activeBoxShadow: activeBoxShadow ?? this.activeBoxShadow,
      errorBoxShadow: errorBoxShadow ?? this.errorBoxShadow,
      loaderColors: loaderColors ?? this.loaderColors,
      loaderGlowWidth: loaderGlowWidth ?? this.loaderGlowWidth,
      loaderLineWidth: loaderLineWidth ?? this.loaderLineWidth,
      loaderBlurRadius: loaderBlurRadius ?? this.loaderBlurRadius,
      maxFanAngle: maxFanAngle ?? this.maxFanAngle,
      fanPivotAlignment: fanPivotAlignment ?? this.fanPivotAlignment,
      fanDuration: fanDuration ?? this.fanDuration,
      shakeDuration: shakeDuration ?? this.shakeDuration,
      dissolveDuration: dissolveDuration ?? this.dissolveDuration,
      loaderDuration: loaderDuration ?? this.loaderDuration,
    );
  }
}
