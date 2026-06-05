// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'time_of_day_with_seconds.dart';

// Define enum outside the widget so it's accessible everywhere
enum PickerMode { hour, minute, second }

class CustomTimePicker extends StatefulWidget {
  final Function(TimeOfDayWithSeconds) onTimeSelected;
  final TimeOfDayWithSeconds? initialTime;
  final bool showSeconds;
  final bool use24HourFormat;

  // Title customization
  final String? titleText;
  final TextStyle? titleStyle;
  final TextAlign? titleAlignment;
  final AlignmentGeometry? titlePosition;
  final EdgeInsetsGeometry? titlePadding;
  final bool showTitle;

  // Typography customization
  final TextStyle? timeSegmentStyle;
  final TextStyle? activeTimeSegmentStyle;
  final TextStyle? separatorStyle;
  final TextStyle? amPmTextStyle;
  final TextStyle? activeAmPmTextStyle;

  // Shapes & borders customization
  final BorderRadius? borderRadius;
  final BorderRadius? segmentBorderRadius;

  // Customization styling
  final Color? primaryColor;
  final Color? accentColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? dialBackgroundColor;
  final Color? dialTextColor;
  final Color? dialSelectedTextColor;
  final Color? handColor;
  final Color? selectionBubbleColor;
  final double? strokeWidth;
  final double? centerDotRadius;

  const CustomTimePicker({
    super.key,
    required this.onTimeSelected,
    this.initialTime,
    this.showSeconds = false,
    this.use24HourFormat = false,
    this.titleText,
    this.titleStyle,
    this.titleAlignment,
    this.titlePosition,
    this.titlePadding,
    this.showTitle = true,
    this.timeSegmentStyle,
    this.activeTimeSegmentStyle,
    this.separatorStyle,
    this.amPmTextStyle,
    this.activeAmPmTextStyle,
    this.borderRadius,
    this.segmentBorderRadius,
    this.primaryColor,
    this.accentColor,
    this.textColor,
    this.backgroundColor,
    this.dialBackgroundColor,
    this.dialTextColor,
    this.dialSelectedTextColor,
    this.handColor,
    this.selectionBubbleColor,
    this.strokeWidth,
    this.centerDotRadius,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late bool isAM;

  late PickerMode _currentMode;

  late double hourAngle;
  late double minuteAngle;
  late double secondAngle;

  DateTime _lastHapticTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize with provided time or defaults
    if (widget.initialTime != null) {
      final initTime = widget.initialTime!;
      _selectedMinute = initTime.minute;
      _selectedSecond = initTime.second;

      if (widget.use24HourFormat) {
        _selectedHour = initTime.hour; // 0 to 23
        isAM = initTime.hour < 12;

        // Determine angle
        final h = _selectedHour;
        final displayHour = (h == 0 || h == 12) ? 12 : (h > 12 ? h - 12 : h);
        hourAngle = (displayHour * 30 - 90) * pi / 180;
      } else {
        _selectedHour = initTime.hourOfPeriod;
        isAM = initTime.period == DayPeriod.am;
        hourAngle = ((_selectedHour == 12 ? 0 : _selectedHour) * 30 - 90) * pi / 180;
      }

      // Update other angles
      minuteAngle = (_selectedMinute * 6 - 90) * pi / 180;
      secondAngle = (_selectedSecond * 6 - 90) * pi / 180;
    } else {
      _selectedHour = 12;
      _selectedMinute = 0;
      _selectedSecond = 0;
      isAM = true;
      hourAngle = -pi / 2;
      minuteAngle = -pi / 2;
      secondAngle = -pi / 2;
    }

    // Set initial mode
    _currentMode = PickerMode.hour;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? theme.dialogBackgroundColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(28),
      ),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Title
            if (widget.showTitle) ...[
              Align(
                alignment: widget.titlePosition ?? Alignment.center,
                child: Padding(
                  padding: widget.titlePadding ?? const EdgeInsets.only(bottom: 16),
                  child: Text(
                    widget.titleText ?? "SELECT TIME",
                    textAlign: widget.titleAlignment ?? TextAlign.center,
                    style: widget.titleStyle ?? TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: widget.textColor?.withOpacity(0.6) ?? theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],

            // Header: Selected Time text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeSegment(PickerMode.hour),
                _buildSeparator(),
                _buildTimeSegment(PickerMode.minute),
                if (widget.showSeconds) ...[
                  _buildSeparator(),
                  _buildTimeSegment(PickerMode.second),
                ],
                if (!widget.use24HourFormat) ...[
                  SizedBox(width: widget.showSeconds ? 6 : 12),
                  Container(
                    width: widget.showSeconds ? 40 : 54,
                    decoration: BoxDecoration(
                      color: widget.dialBackgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: widget.segmentBorderRadius ?? BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAmPmButton(true),
                        _buildAmPmButton(false),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Center: The Clock Dial
            LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth;

                return Center(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: GestureDetector(
                      onPanDown: (details) =>
                          _handleDrag(details.localPosition, Size(size, size)),
                      onPanStart: (details) =>
                          _handleDrag(details.localPosition, Size(size, size)),
                      onPanUpdate: (details) =>
                          _handleDrag(details.localPosition, Size(size, size)),
                      onPanEnd: (details) => _handleDragEnd(),
                      onPanCancel: () => _handleDragEnd(),
                      child: CustomPaint(
                        size: Size(size, size),
                        painter: ClockPainter(
                          angle: _getCurrentAngle(),
                          dialColor: widget.dialBackgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          dialTextColor: widget.dialTextColor ?? theme.colorScheme.onSurface,
                          dialSelectedTextColor: widget.dialSelectedTextColor ?? theme.colorScheme.onPrimary,
                          primaryColor: primaryColor,
                          handColor: widget.handColor,
                          selectionBubbleColor: widget.selectionBubbleColor,
                          strokeWidth: widget.strokeWidth,
                          centerDotRadius: widget.centerDotRadius,
                          currentMode: _currentMode,
                          selectedHour: _selectedHour,
                          selectedMinute: _selectedMinute,
                          selectedSecond: _selectedSecond,
                          use24HourFormat: widget.use24HourFormat,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Footer: Cancel/OK actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: widget.textColor ?? theme.colorScheme.secondary,
                  ),
                  child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onOkPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: widget.dialSelectedTextColor ?? theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAmPmButton(bool isAm) {
    final bool isSelected = isAm ? isAM : !isAM;
    final theme = Theme.of(context);
    final activeColor = widget.primaryColor ?? theme.colorScheme.primary;

    final defaultBorderRadius = widget.segmentBorderRadius ?? BorderRadius.circular(12);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => isAM = isAm);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: widget.showSeconds ? 6 : 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isAm ? defaultBorderRadius.topLeft : Radius.zero,
            topRight: isAm ? defaultBorderRadius.topRight : Radius.zero,
            bottomLeft: !isAm ? defaultBorderRadius.bottomLeft : Radius.zero,
            bottomRight: !isAm ? defaultBorderRadius.bottomRight : Radius.zero,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          isAm ? "AM" : "PM",
          style: isSelected
              ? (widget.activeAmPmTextStyle ?? TextStyle(
                  color: widget.dialSelectedTextColor ?? theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.showSeconds ? 10 : 13,
                ))
              : (widget.amPmTextStyle ?? TextStyle(
                  color: widget.textColor ?? theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.showSeconds ? 10 : 13,
                )),
        ),
      ),
    );
  }

  Widget _buildTimeSegment(PickerMode mode) {
    String text;
    switch (mode) {
      case PickerMode.hour:
        text = _selectedHour.toString().padLeft(2, '0');
        break;
      case PickerMode.minute:
        text = _selectedMinute.toString().padLeft(2, '0');
        break;
      case PickerMode.second:
        text = _selectedSecond.toString().padLeft(2, '0');
        break;
    }

    final theme = Theme.of(context);
    final activeColor = widget.primaryColor ?? theme.colorScheme.primary;
    final bool isActive = _currentMode == mode;
    final double fontSize = widget.showSeconds ? 22 : 32;
    final double horizontalPadding = widget.showSeconds ? 4 : 10;
    final double verticalPadding = widget.showSeconds ? 4 : 6;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: widget.segmentBorderRadius ?? BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: isActive
              ? (widget.activeTimeSegmentStyle ?? TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ))
              : (widget.timeSegmentStyle ?? TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor ?? theme.colorScheme.onSurface,
                )),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    final theme = Theme.of(context);
    final double fontSize = widget.showSeconds ? 22 : 32;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ":",
        style: widget.separatorStyle ?? TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: widget.textColor ?? theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  double _getCurrentAngle() {
    switch (_currentMode) {
      case PickerMode.hour:
        return hourAngle;
      case PickerMode.minute:
        return minuteAngle;
      case PickerMode.second:
        return secondAngle;
    }
  }

  void _handleDrag(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    final newAngle = atan2(dy, dx);

    setState(() {
      switch (_currentMode) {
        case PickerMode.hour:
          hourAngle = newAngle;
          final degrees = (newAngle * 180 / pi + 360) % 360;
          // snap to nearest hour by adding 15 (half of 30 degree step) before division
          int hour12 = (((degrees + 90 + 15) % 360) ~/ 30);
          hour12 = hour12 == 0 ? 12 : hour12;

          if (widget.use24HourFormat) {
            final distance = sqrt(dx * dx + dy * dy);
            final radius = size.width / 2;
            final isInner = distance < radius * 0.67;

            int newHour;
            if (isInner) {
              newHour = hour12; // 1 to 12
            } else {
              newHour = hour12 == 12 ? 0 : hour12 + 12; // 13 to 23, and 00
            }

            if (newHour != _selectedHour) {
              _triggerHaptic();
              _selectedHour = newHour;
            }
          } else {
            if (hour12 != _selectedHour) {
              _triggerHaptic();
              _selectedHour = hour12;
            }
          }
          break;

        case PickerMode.minute:
          minuteAngle = newAngle;
          final degrees = (newAngle * 180 / pi + 360) % 360;
          // snap to nearest minute by adding 3 (half of 6 degree step) before division
          int newMinute = (((degrees + 90 + 3) % 360) ~/ 6);
          newMinute = newMinute == 60 ? 0 : newMinute;
          if (newMinute != _selectedMinute) {
            _triggerHaptic();
            _selectedMinute = newMinute;
          }
          break;

        case PickerMode.second:
          secondAngle = newAngle;
          final degrees = (newAngle * 180 / pi + 360) % 360;
          // snap to nearest second by adding 3 (half of 6 degree step) before division
          int newSecond = (((degrees + 90 + 3) % 360) ~/ 6);
          newSecond = newSecond == 60 ? 0 : newSecond;
          if (newSecond != _selectedSecond) {
            _triggerHaptic();
            _selectedSecond = newSecond;
          }
          break;
      }
    });
  }

  void _handleDragEnd() {
    setState(() {
      switch (_currentMode) {
        case PickerMode.hour:
          if (widget.use24HourFormat) {
            final displayHour = (_selectedHour == 0 || _selectedHour == 12)
                ? 12
                : (_selectedHour > 12 ? _selectedHour - 12 : _selectedHour);
            hourAngle = (displayHour * 30 - 90) * pi / 180;
          } else {
            hourAngle = ((_selectedHour == 12 ? 0 : _selectedHour) * 30 - 90) * pi / 180;
          }
          break;
        case PickerMode.minute:
          minuteAngle = (_selectedMinute * 6 - 90) * pi / 180;
          break;
        case PickerMode.second:
          secondAngle = (_selectedSecond * 6 - 90) * pi / 180;
          break;
      }
    });
  }

  void _triggerHaptic() {
    final now = DateTime.now();
    if (now.difference(_lastHapticTime).inMilliseconds > 150) {
      HapticFeedback.selectionClick();
      _lastHapticTime = now;
    }
  }

  void _onOkPressed() {
    int hour24;
    if (widget.use24HourFormat) {
      hour24 = _selectedHour;
    } else {
      if (isAM) {
        hour24 = _selectedHour == 12 ? 0 : _selectedHour;
      } else {
        hour24 = _selectedHour == 12 ? 12 : _selectedHour + 12;
      }
    }

    widget.onTimeSelected(
      TimeOfDayWithSeconds(
        hour: hour24,
        minute: _selectedMinute,
        second: widget.showSeconds ? _selectedSecond : 0,
      ),
    );
    Navigator.pop(context);
  }
}

class ClockPainter extends CustomPainter {
  final double angle;
  final Color dialColor;
  final Color dialTextColor;
  final Color dialSelectedTextColor;
  final Color primaryColor;
  final Color? handColor;
  final Color? selectionBubbleColor;
  final double? strokeWidth;
  final double? centerDotRadius;
  final PickerMode currentMode;
  final int selectedHour;
  final int selectedMinute;
  final int selectedSecond;
  final bool use24HourFormat;

  const ClockPainter({
    required this.angle,
    required this.dialColor,
    required this.dialTextColor,
    required this.dialSelectedTextColor,
    required this.primaryColor,
    this.handColor,
    this.selectionBubbleColor,
    this.strokeWidth,
    this.centerDotRadius,
    required this.currentMode,
    required this.selectedHour,
    required this.selectedMinute,
    required this.selectedSecond,
    required this.use24HourFormat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw dial background
    final backgroundPaint = Paint()
      ..color = dialColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 2. Draw outer boundary border
    final borderPaint = Paint()
      ..color = dialTextColor.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // 3. Draw tick marks
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 60; i++) {
      final isHourTick = i % 5 == 0;
      final tickLength = isHourTick ? 8.0 : 4.0;
      final tickAngle = (i * 6 - 90) * pi / 180;

      final start = Offset(
        center.dx + (radius - 4) * cos(tickAngle),
        center.dy + (radius - 4) * sin(tickAngle),
      );
      final end = Offset(
        center.dx + (radius - 4 - tickLength) * cos(tickAngle),
        center.dy + (radius - 4 - tickLength) * sin(tickAngle),
      );

      tickPaint.color = dialTextColor.withOpacity(isHourTick ? 0.12 : 0.05);
      tickPaint.strokeWidth = isHourTick ? 1.5 : 1.0;
      canvas.drawLine(start, end, tickPaint);
    }

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // 4. Draw background numbers
    switch (currentMode) {
      case PickerMode.hour:
        _drawHourNumbers(canvas, center, radius, textPainter, isWhite: false);
        break;
      case PickerMode.minute:
        _drawMinuteNumbers(canvas, center, radius, textPainter, isWhite: false);
        break;
      case PickerMode.second:
        _drawSecondNumbers(canvas, center, radius, textPainter, isWhite: false);
        break;
    }

    // 5. Draw selector hand
    double handLength = radius * 0.76;
    if (currentMode == PickerMode.hour && use24HourFormat) {
      if (selectedHour == 0 || selectedHour >= 13) {
        handLength = radius * 0.82;
      } else {
        handLength = radius * 0.52;
      }
    }
    final handEnd = Offset(
      center.dx + handLength * cos(angle),
      center.dy + handLength * sin(angle),
    );

    final handPaint = Paint()
      ..color = handColor ?? primaryColor
      ..strokeWidth = strokeWidth ?? 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, handEnd, handPaint);
    canvas.drawCircle(center, centerDotRadius ?? 5, handPaint);

    // 6. Draw hand's outer selection bubble
    final selectionPaint = Paint()
      ..color = selectionBubbleColor ?? primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handEnd, 22, selectionPaint);

    // 7. Clip to selection bubble and draw highlighted white numbers
    canvas.save();
    canvas.clipPath(
      Path()
        ..addOval(
          Rect.fromCircle(
            center: handEnd,
            radius: 22,
          ),
        ),
    );

    switch (currentMode) {
      case PickerMode.hour:
        _drawHourNumbers(canvas, center, radius, textPainter, isWhite: true);
        break;
      case PickerMode.minute:
        _drawMinuteNumbers(canvas, center, radius, textPainter, isWhite: true);
        break;
      case PickerMode.second:
        _drawSecondNumbers(canvas, center, radius, textPainter, isWhite: true);
        break;
    }

    canvas.restore();

    // 8. Draw center inner point inside selection bubble only if hand isn't snapped directly over a label
    final currentDegrees = (angle * 180 / pi + 360) % 360;
    bool isOnNumber = false;

    switch (currentMode) {
      case PickerMode.hour:
        for (int i = 1; i <= 12; i++) {
          final numberDegrees = (i * 30) % 360;
          if ((currentDegrees - numberDegrees).abs() < 5) {
            isOnNumber = true;
            break;
          }
        }
        break;
      case PickerMode.minute:
      case PickerMode.second:
        for (int i = 0; i < 60; i += 5) {
          final numberDegrees = (i * 6) % 360;
          if ((currentDegrees - numberDegrees).abs() < 2.5) {
            isOnNumber = true;
            break;
          }
        }
        break;
    }

    if (!isOnNumber) {
      final dotPaint = Paint()
        ..color = dialSelectedTextColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(handEnd, 4, dotPaint);
    }
  }

  void _drawHourNumbers(Canvas canvas, Offset center, double radius,
      TextPainter textPainter, {required bool isWhite}) {
    if (use24HourFormat) {
      // 1. Draw inner ring (1 to 12)
      for (int i = 1; i <= 12; i++) {
        final numberAngle = (i * 30 - 90) * pi / 180;
        final x = center.dx + radius * 0.52 * cos(numberAngle);
        final y = center.dy + radius * 0.52 * sin(numberAngle);

        textPainter.text = TextSpan(
          text: "$i",
          style: TextStyle(
            fontSize: 12,
            fontWeight: isWhite ? FontWeight.bold : FontWeight.w500,
            color: isWhite ? dialSelectedTextColor : dialTextColor.withOpacity(0.6),
          ),
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }

      // 2. Draw outer ring (13 to 23, and 00)
      for (int i = 13; i <= 24; i++) {
        final numberAngle = ((i - 12) * 30 - 90) * pi / 180;
        final x = center.dx + radius * 0.82 * cos(numberAngle);
        final y = center.dy + radius * 0.82 * sin(numberAngle);

        final label = i == 24 ? "00" : "$i";

        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isWhite ? FontWeight.bold : FontWeight.w500,
            color: isWhite ? dialSelectedTextColor : dialTextColor,
          ),
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    } else {
      for (int i = 1; i <= 12; i++) {
        final numberAngle = (i * 30 - 90) * pi / 180;
        final x = center.dx + radius * 0.76 * cos(numberAngle);
        final y = center.dy + radius * 0.76 * sin(numberAngle);

        textPainter.text = TextSpan(
          text: "$i",
          style: TextStyle(
            fontSize: 16,
            fontWeight: isWhite ? FontWeight.bold : FontWeight.w500,
            color: isWhite ? dialSelectedTextColor : dialTextColor,
          ),
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  void _drawMinuteNumbers(Canvas canvas, Offset center, double radius,
      TextPainter textPainter, {required bool isWhite}) {
    for (int i = 0; i < 60; i += 5) {
      final minuteAngle = (i * 6 - 90) * pi / 180;
      final x = center.dx + radius * 0.76 * cos(minuteAngle);
      final y = center.dy + radius * 0.76 * sin(minuteAngle);

      final String minuteText = i == 0 ? "00" : i.toString().padLeft(2, '0');

      textPainter.text = TextSpan(
        text: minuteText,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isWhite ? FontWeight.bold : FontWeight.w400,
          color: isWhite ? dialSelectedTextColor : dialTextColor.withOpacity(0.8),
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawSecondNumbers(Canvas canvas, Offset center, double radius,
      TextPainter textPainter, {required bool isWhite}) {
    for (int i = 0; i < 60; i += 5) {
      final secondAngle = (i * 6 - 90) * pi / 180;
      final x = center.dx + radius * 0.76 * cos(secondAngle);
      final y = center.dy + radius * 0.76 * sin(secondAngle);

      final String secondText = i == 0 ? "00" : i.toString().padLeft(2, '0');

      textPainter.text = TextSpan(
        text: secondText,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isWhite ? FontWeight.bold : FontWeight.w400,
          color: isWhite ? dialSelectedTextColor : dialTextColor.withOpacity(0.8),
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.currentMode != currentMode ||
        oldDelegate.selectedHour != selectedHour ||
        oldDelegate.selectedMinute != selectedMinute ||
        oldDelegate.selectedSecond != selectedSecond ||
        oldDelegate.dialColor != dialColor ||
        oldDelegate.dialTextColor != dialTextColor ||
        oldDelegate.dialSelectedTextColor != dialSelectedTextColor ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.use24HourFormat != use24HourFormat ||
        oldDelegate.handColor != handColor ||
        oldDelegate.selectionBubbleColor != selectionBubbleColor;
  }
}
