import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom painter that draws a rotating neon border glow around a rounded rectangle.
class CardBorderLoaderPainter extends CustomPainter {
  /// Current angle of rotation in radians.
  final double angle;

  /// Colors used for the neon sweep gradient.
  final List<Color> colors;

  /// Border radius of the box.
  final BorderRadius borderRadius;

  /// Stroke width for the outer blur glow.
  final double glowWidth;

  /// Stroke width for the sharp inner neon line.
  final double lineWidth;

  /// Blur radius for the outer glow filter.
  final double blurRadius;

  CardBorderLoaderPainter({
    required this.angle,
    required this.colors,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.glowWidth = 3.0,
    this.lineWidth = 2.0,
    this.blurRadius = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);

    // Build gradient stops evenly distributed across the provided colors
    final count = colors.length;
    final List<double> stops;
    if (count <= 1) {
      stops = const [0.0, 1.0];
    } else {
      stops = List.generate(count, (i) => i / (count - 1));
    }

    final gradientShader = SweepGradient(
      transform: GradientRotation(angle),
      colors: count <= 1 ? [colors.first, colors.first] : colors,
      stops: stops,
    ).createShader(rect);

    // Outer Subtle Glow Paint
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius)
      ..shader = gradientShader;

    // Inner Sleek Thin Neon Line Paint
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..shader = gradientShader;

    canvas.drawRRect(rrect, glowPaint);
    canvas.drawRRect(rrect, linePaint);
  }

  @override
  bool shouldRepaint(covariant CardBorderLoaderPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.colors != colors ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.glowWidth != glowWidth ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.blurRadius != blurRadius;
  }
}

/// A ready-to-use widget that displays an animated rotating neon border loader.
class CardBorderLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final List<Color> colors;
  final double glowWidth;
  final double lineWidth;
  final double blurRadius;
  final Duration duration;

  const CardBorderLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.colors = const [
      Color(0xFF2D7BD9),
      Color(0xFF00F0FF),
      Color(0xFF2D7BD9),
    ],
    this.glowWidth = 3.0,
    this.lineWidth = 2.0,
    this.blurRadius = 2.0,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<CardBorderLoader> createState() => _CardBorderLoaderState();
}

class _CardBorderLoaderState extends State<CardBorderLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CardBorderLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: CardBorderLoaderPainter(
            angle: _controller.value * 2 * math.pi,
            colors: widget.colors,
            borderRadius: widget.borderRadius,
            glowWidth: widget.glowWidth,
            lineWidth: widget.lineWidth,
            blurRadius: widget.blurRadius,
          ),
        );
      },
    );
  }
}
