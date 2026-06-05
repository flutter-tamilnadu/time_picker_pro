import 'dart:math';
import 'package:flutter/material.dart';
import '../time_picker_pro.dart';

/// Renders the background dial of the clock, including ticks, numbers,
/// decorative inner tracks, and selected hour/minute highlights.
class ClockDialPainter extends CustomPainter {
  final int selectedHour;
  final int selectedMinute;
  final int selectedSecond;
  final ClockPickerThemeData theme;
  final PickerMode currentMode;
  final bool use24HourFormat;

  ClockDialPainter({
    required this.selectedHour,
    required this.selectedMinute,
    required this.selectedSecond,
    required this.theme,
    required this.currentMode,
    required this.use24HourFormat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw the clock face background circle
    final facePaint = Paint()..style = PaintingStyle.fill;

    if (theme.clockFaceGradient != null) {
      facePaint.shader = theme.clockFaceGradient!.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    } else {
      facePaint.color = theme.clockFaceBackgroundColor;
    }

    // Draw clock face shadows if present
    if (theme.clockFaceShadows != null && theme.clockFaceShadows!.isNotEmpty) {
      for (final shadow in theme.clockFaceShadows!) {
        final shadowPaint = Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
        
        canvas.drawCircle(center + shadow.offset, radius + shadow.spreadRadius, shadowPaint);
      }
    }

    // Draw the main clock face background circle
    canvas.drawCircle(center, radius, facePaint);

    // Draw outer dial border/ticks
    _drawTicks(canvas, center, radius);

    // Draw inner decorative ring track
    _drawInnerTrack(canvas, center, radius);

    // Draw numbers (1 to 12, or concentric 24h rings)
    _drawNumbers(canvas, center, radius);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = theme.outerDialTickColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tickLengthLong = radius * 0.08;
    final tickLengthShort = radius * 0.04;
    final startRadius = radius * 0.88;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * pi / 180 - pi / 2;
      final isMajor = i % 5 == 0;
      
      tickPaint.strokeWidth = isMajor ? 2.0 : 1.0;
      final currentTickLength = isMajor ? tickLengthLong : tickLengthShort;

      final startOffset = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final endOffset = Offset(
        center.dx + (startRadius + currentTickLength) * cos(angle),
        center.dy + (startRadius + currentTickLength) * sin(angle),
      );

      canvas.drawLine(startOffset, endOffset, tickPaint);
    }
  }

  void _drawInnerTrack(Canvas canvas, Offset center, double radius) {
    final trackRadius = radius * 0.52;
    
    final trackPaint = Paint()
      ..color = theme.outerDialTickColor.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw 12 arcs representing the segments of the inner circle
    final rect = Rect.fromCircle(center: center, radius: trackRadius);
    const segmentAngle = 30 * pi / 180;
    const gapAngle = 6 * pi / 180;

    for (int i = 0; i < 12; i++) {
      final startAngle = i * segmentAngle - pi / 2 + gapAngle / 2;
      const sweepAngle = segmentAngle - gapAngle;
      canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);
    }
  }

  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    if (use24HourFormat && currentMode == PickerMode.hour) {
      // Concentric 24-hour rings
      // 1. Inner Ring (1 to 12)
      final innerRadius = radius * 0.52;
      for (int i = 1; i <= 12; i++) {
        final isSelected = selectedHour == i;
        final angle = (i * 30 - 90) * pi / 180;

        if (isSelected) {
          final highlightPaint = Paint()
            ..color = theme.selectedHourHighlightColor
            ..style = PaintingStyle.fill;
          final highlightCenter = Offset(
            center.dx + innerRadius * cos(angle),
            center.dy + innerRadius * sin(angle),
          );
          canvas.drawCircle(highlightCenter, radius * 0.10, highlightPaint);
        }

        final textStyle = theme.hourNumberStyle?.copyWith(
              color: isSelected ? theme.selectedHourNumberColor : theme.hourNumberColor.withOpacity(0.6),
              fontSize: isSelected ? radius * 0.14 : radius * 0.12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ) ??
            TextStyle(
              color: isSelected ? theme.selectedHourNumberColor : theme.hourNumberColor.withOpacity(0.6),
              fontSize: isSelected ? radius * 0.14 : radius * 0.12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              fontFamily: 'Outfit',
            );

        textPainter.text = TextSpan(text: '$i', style: textStyle);
        textPainter.layout();

        final x = center.dx + innerRadius * cos(angle) - textPainter.width / 2;
        final y = center.dy + innerRadius * sin(angle) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(x, y));
      }

      // 2. Outer Ring (13 to 23, 00)
      final outerRadius = radius * 0.80;
      for (int i = 13; i <= 24; i++) {
        final displayVal = i == 24 ? 0 : i;
        final isSelected = selectedHour == displayVal;
        final angle = ((i - 12) * 30 - 90) * pi / 180;

        if (isSelected) {
          final highlightPaint = Paint()
            ..color = theme.selectedHourHighlightColor
            ..style = PaintingStyle.fill;
          final highlightCenter = Offset(
            center.dx + outerRadius * cos(angle),
            center.dy + outerRadius * sin(angle),
          );
          canvas.drawCircle(highlightCenter, radius * 0.10, highlightPaint);
        }

        final textStyle = theme.hourNumberStyle?.copyWith(
              color: isSelected ? theme.selectedHourNumberColor : theme.hourNumberColor,
              fontSize: isSelected ? radius * 0.15 : radius * 0.13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ) ??
            TextStyle(
              color: isSelected ? theme.selectedHourNumberColor : theme.hourNumberColor,
              fontSize: isSelected ? radius * 0.15 : radius * 0.13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              fontFamily: 'Outfit',
            );

        final label = displayVal == 0 ? "00" : "$displayVal";
        textPainter.text = TextSpan(text: label, style: textStyle);
        textPainter.layout();

        final x = center.dx + outerRadius * cos(angle) - textPainter.width / 2;
        final y = center.dy + outerRadius * sin(angle) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(x, y));
      }
    } else {
      // Standard 12-hour/minute/second layout (1 to 12)
      final numberRadius = radius * 0.70;

      for (int i = 1; i <= 12; i++) {
        bool isSelected = false;
        if (currentMode == PickerMode.hour) {
          isSelected = selectedHour == i;
        } else if (currentMode == PickerMode.minute) {
          isSelected = (selectedMinute == i * 5) || (i == 12 && selectedMinute == 0);
        } else if (currentMode == PickerMode.second) {
          isSelected = (selectedSecond == i * 5) || (i == 12 && selectedSecond == 0);
        }

        final angle = (i * 30 - 90) * pi / 180;

        if (isSelected) {
          final highlightPaint = Paint()
            ..color = theme.selectedHourHighlightColor
            ..style = PaintingStyle.fill;
          
          final highlightCenter = Offset(
            center.dx + numberRadius * cos(angle),
            center.dy + numberRadius * sin(angle),
          );
          canvas.drawCircle(highlightCenter, radius * 0.11, highlightPaint);
        }

        final textStyle = theme.hourNumberStyle?.copyWith(
              color: isSelected ? theme.selectedHourNumberColor : theme.hourNumberColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ) ??
            TextStyle(
              color: isSelected ? theme.selectedHourNumberColor : theme.hourNumberColor,
              fontSize: isSelected ? radius * 0.17 : radius * 0.14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              fontFamily: 'Outfit',
            );

        textPainter.text = TextSpan(
          text: '$i',
          style: textStyle,
        );
        textPainter.layout();

        final x = center.dx + numberRadius * cos(angle) - textPainter.width / 2;
        final y = center.dy + numberRadius * sin(angle) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant ClockDialPainter oldDelegate) {
    return oldDelegate.selectedHour != selectedHour ||
        oldDelegate.selectedMinute != selectedMinute ||
        oldDelegate.selectedSecond != selectedSecond ||
        oldDelegate.theme != theme ||
        oldDelegate.currentMode != currentMode ||
        oldDelegate.use24HourFormat != use24HourFormat;
  }
}
