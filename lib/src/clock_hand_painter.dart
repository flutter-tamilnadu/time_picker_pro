import 'dart:math';
import 'package:flutter/material.dart';
import '../time_picker_pro.dart';

/// Renders the hour, minute, and second hands on the clock face with custom tapered
/// shapes, glowing highlights, and a center cap.
class ClockHandPainter extends CustomPainter {
  final double hour;
  final double minute;
  final double second;
  final ClockPickerThemeData theme;
  final PickerMode currentMode;
  final bool use24HourFormat;
  final bool showSeconds;

  ClockHandPainter({
    required this.hour,
    required this.minute,
    required this.second,
    required this.theme,
    required this.currentMode,
    required this.use24HourFormat,
    required this.showSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Calculate angles
    // Hour angle: 30 degrees per hour, 0.5 degrees per minute. Offset by -pi/2 to start at 12 o'clock.
    final hourAngle = (hour * 30 + minute * 0.5) * pi / 180 - pi / 2;
    // Minute angle: 6 degrees per minute.
    final minuteAngle = minute * 6 * pi / 180 - pi / 2;
    // Second angle: 6 degrees per second.
    final secondAngle = second * 6 * pi / 180 - pi / 2;

    // Radius sizes for hands
    double hourHandLength = radius * 0.52;
    if (use24HourFormat) {
      final hInt = hour.toInt();
      hourHandLength = (hInt == 0 || hInt >= 13) ? radius * 0.80 : radius * 0.52;
    }
    final minuteHandLength = radius * 0.76;
    final secondHandLength = radius * 0.83;

    // Draw second hand glow if active
    if (showSeconds && currentMode == PickerMode.second && theme.showGlow) {
      final glowPaint = Paint()
        ..color = theme.selectedHourNumberColor.withOpacity(0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * theme.glowStrength)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(secondAngle);
      canvas.drawRect(Rect.fromLTWH(-radius * 0.15, -1.0, secondHandLength + radius * 0.15, 2.0), glowPaint);
      canvas.restore();
    }

    // Draw minute hand first (so hour hand sits on top)
    _drawMinuteHand(canvas, center, radius, minuteHandLength, minuteAngle);

    // Draw hour hand
    _drawHourHand(canvas, center, radius, hourHandLength, hourAngle);

    // Draw second hand
    if (showSeconds) {
      _drawSecondHand(canvas, center, radius, secondHandLength, secondAngle);
    }

    // Draw center pin/cap
    _drawCenterPin(canvas, center, radius);
  }

  void _drawMinuteHand(Canvas canvas, Offset center, double radius, double length, double angle) {
    final isActive = currentMode == PickerMode.minute;
    final baseColor = isActive ? theme.minuteHandColor : theme.minuteHandColor.withOpacity(0.35);

    // Glow effect if enabled
    if (theme.showGlow && isActive) {
      final glowPaint = Paint()
        ..color = theme.minuteHandGlowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * theme.glowStrength)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      
      final glowPath = Path()
        ..moveTo(0, -5)
        ..lineTo(length, -1.5)
        ..lineTo(length, 1.5)
        ..lineTo(0, 5)
        ..close();
      canvas.drawPath(glowPath, glowPaint);
      canvas.restore();
    }

    // Tapered hand path
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final handPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, -4.5)
      ..lineTo(length * 0.2, -4.0)
      ..lineTo(length, -1.0)
      ..lineTo(length, 1.0)
      ..lineTo(length * 0.2, 4.0)
      ..moveTo(0, 4.5)
      ..close();

    canvas.drawPath(path, handPaint);

    // Draw bright inner neon line on active/dark mode hand to match reference image
    if (theme.showGlow && theme.minuteHandColor != theme.handColor && isActive) {
      final neonPaint = Paint()
        ..color = theme.minuteHandColor.withOpacity(0.9)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(10, 0), Offset(length - 5, 0), neonPaint);
    }

    canvas.restore();
  }

  void _drawHourHand(Canvas canvas, Offset center, double radius, double length, double angle) {
    final isActive = currentMode == PickerMode.hour;
    final baseColor = isActive ? theme.hourHandColor : theme.hourHandColor.withOpacity(0.35);
    final tipRadius = radius * 0.045;
    final tipCenter = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    // Glow for hour hand
    if (theme.showGlow && isActive) {
      final glowPaint = Paint()
        ..color = theme.hourHandGlowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * theme.glowStrength)
        ..style = PaintingStyle.fill;

      // Glow behind the hand body
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      
      final bodyGlow = Path()
        ..moveTo(0, -7)
        ..lineTo(length, -3.5)
        ..lineTo(length, 3.5)
        ..lineTo(0, 7)
        ..close();
      canvas.drawPath(bodyGlow, glowPaint);
      canvas.restore();

      // Glow behind the selector circle
      canvas.drawCircle(tipCenter, tipRadius * 2.2, glowPaint);
    }

    // Draw hour hand body
    final handPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final bodyPath = Path()
      ..moveTo(0, -6.5)
      ..lineTo(length * 0.2, -5.5)
      ..lineTo(length - tipRadius, -2.5)
      ..lineTo(length - tipRadius, 2.5)
      ..lineTo(length * 0.2, 5.5)
      ..lineTo(0, 6.5)
      ..close();

    canvas.drawPath(bodyPath, handPaint);

    // Draw bright inner neon line on hand body
    if (theme.showGlow && theme.hourHandColor != theme.handColor && isActive) {
      final neonPaint = Paint()
        ..color = theme.hourHandColor.withOpacity(0.9)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(10, 0), Offset(length - tipRadius - 5, 0), neonPaint);
    }
    canvas.restore();

    // Draw Selector Circle at the end of the Hour hand
    final selectorPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    
    // Draw the outer indicator ring
    canvas.drawCircle(tipCenter, tipRadius * 1.5, selectorPaint);

    // Draw the inner contrast dot or fill
    final innerPaint = Paint()
      ..color = theme.backgroundColor // matches background to look like a ring hole
      ..style = PaintingStyle.fill;
    canvas.drawCircle(tipCenter, tipRadius * 0.8, innerPaint);

    // Draw center dot inside the ring
    final dotPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(tipCenter, tipRadius * 0.35, dotPaint);
  }

  void _drawSecondHand(Canvas canvas, Offset center, double radius, double length, double angle) {
    final isActive = currentMode == PickerMode.second;
    final color = isActive ? theme.selectedHourNumberColor : theme.selectedHourNumberColor.withOpacity(0.35);

    final secondPaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw second hand line with a nice counterweight tail
    final tailLength = radius * 0.15;
    final startOffset = Offset(
      center.dx - tailLength * cos(angle),
      center.dy - tailLength * sin(angle),
    );
    final endOffset = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    canvas.drawLine(startOffset, endOffset, secondPaint);

    // Draw a small decorative accent dot on the second hand tip
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final dotOffset = Offset(
      center.dx + (length - 15) * cos(angle),
      center.dy + (length - 15) * sin(angle),
    );
    canvas.drawCircle(dotOffset, 3.0, dotPaint);
  }

  void _drawCenterPin(Canvas canvas, Offset center, double radius) {
    final pinRadius = radius * 0.055;

    // Shadow under the center pin
    if (theme.showGlow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(center + const Offset(0, 1.5), pinRadius, shadowPaint);
    }

    final pinPaint = Paint()
      ..color = theme.handColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, pinRadius, pinPaint);

    // Inner subtle metallic/glow reflection on cap
    final reflectionPaint = Paint()
      ..color = (theme.showGlow ? theme.hourHandColor : Colors.white).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pinRadius * 0.45, reflectionPaint);
  }

  @override
  bool shouldRepaint(covariant ClockHandPainter oldDelegate) {
    return oldDelegate.hour != hour ||
        oldDelegate.minute != minute ||
        oldDelegate.second != second ||
        oldDelegate.theme != theme ||
        oldDelegate.currentMode != currentMode ||
        oldDelegate.use24HourFormat != use24HourFormat ||
        oldDelegate.showSeconds != showSeconds;
  }
}
