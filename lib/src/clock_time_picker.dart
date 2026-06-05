import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../time_picker_pro.dart';

/// A beautiful, highly customizable analog-style clock time picker for Flutter.
class ClockTimePicker extends StatefulWidget {
  /// The initial time selected in the picker.
  final TimeOfDayWithSeconds initialTime;

  /// Callback triggered whenever the selected time changes.
  final ValueChanged<TimeOfDayWithSeconds>? onTimeChanged;

  /// Callback triggered when the "CONFIRM" button is tapped.
  final ValueChanged<TimeOfDayWithSeconds>? onConfirm;

  /// Theme configuration for customizing colors, fonts, shadows, and glows.
  final ClockPickerThemeData? theme;

  /// The title displayed at the top of the picker card.
  final String? title;

  /// The subtitle displayed below the title.
  final String? subtitle;

  /// Optional description displayed below the clock dial.
  final String? description;

  /// Custom confirm button label.
  final String confirmLabel;

  /// Whether the clock is in 24-hour format. Defaults to false.
  final bool use24HourFormat;

  /// Whether to show the seconds hand and select seconds. Defaults to false.
  final bool showSeconds;

  const ClockTimePicker({
    super.key,
    this.initialTime = const TimeOfDayWithSeconds(hour: 10, minute: 9, second: 0),
    this.onTimeChanged,
    this.onConfirm,
    this.theme,
    this.title = "White Theme Time Picker",
    this.subtitle = "Dark Grey",
    this.description = "White Theme Time Picker\nDark Grey",
    this.confirmLabel = "CONFIRM",
    this.use24HourFormat = false,
    this.showSeconds = false,
  });

  @override
  State<ClockTimePicker> createState() => _ClockTimePickerState();
}

class _ClockTimePickerState extends State<ClockTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late bool _isAm;
  late ClockPickerThemeData _theme;

  // Active interactive mode: Hour, Minute, or Second editing
  PickerMode _currentMode = PickerMode.hour;

  // Track which hand is currently being dragged
  String? _activeDragHand; // 'hour', 'minute', 'second', or null

  // Keep track of the last rounded value to trigger haptic feedback only on change
  int? _lastHapticValue;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? ClockPickerThemeData.light();
    
    // Parse initial time
    final initialHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _selectedSecond = widget.initialTime.second;
    
    if (widget.use24HourFormat) {
      _selectedHour = initialHour;
      _isAm = initialHour < 12;
    } else {
      _isAm = initialHour < 12;
      final tempHour = initialHour % 12;
      _selectedHour = tempHour == 0 ? 12 : tempHour;
    }
  }

  @override
  void didUpdateWidget(covariant ClockTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      setState(() {
        _theme = widget.theme ?? ClockPickerThemeData.light();
      });
    }
  }

  /// Helper to convert the state values back to [TimeOfDayWithSeconds]
  TimeOfDayWithSeconds get _currentTimeOfDay {
    int hour24;
    if (widget.use24HourFormat) {
      hour24 = _selectedHour;
    } else {
      int hour12 = _selectedHour == 12 ? 0 : _selectedHour;
      if (_isAm) {
        hour24 = hour12;
      } else {
        hour24 = hour12 + 12;
      }
    }
    
    return TimeOfDayWithSeconds(
      hour: hour24,
      minute: _selectedMinute,
      second: widget.showSeconds ? _selectedSecond : 0,
    );
  }

  /// Classifies the current time into a period string (Morning, Afternoon, Evening, Night)
  String get _timePeriodLabel {
    final hour = _currentTimeOfDay.hour;
    if (hour >= 5 && hour < 12) {
      return "Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Evening";
    } else {
      return "Night";
    }
  }

  /// Formatted string representations
  String get _formattedHour {
    if (widget.use24HourFormat) {
      return _selectedHour.toString().padLeft(2, '0');
    }
    return _selectedHour.toString().padLeft(2, '0');
  }
  String get _formattedMinute => _selectedMinute.toString().padLeft(2, '0');
  String get _formattedSecond => _selectedSecond.toString().padLeft(2, '0');

  /// Toggles AM/PM period
  void _toggleAmPm() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isAm = !_isAm;
      _notifyTimeChanged();
    });
  }

  void _notifyTimeChanged() {
    widget.onTimeChanged?.call(_currentTimeOfDay);
  }

  /// Handles touch/gesture calculation
  void _handleGesture(Offset localPosition, Size size, {bool isStart = false}) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distanceFromCenter = sqrt(dx * dx + dy * dy);

    // Ignore taps/drags outside the clock dial circle
    if (distanceFromCenter > radius * 1.15) return;

    // Calculate angle in radians
    double angle = atan2(dy, dx) + pi / 2;
    if (angle < 0) {
      angle += 2 * pi;
    }

    final fraction = angle / (2 * pi);

    if (isStart) {
      // Determine which hand is closer to the touch start position
      double hourHandLength = radius * 0.52;
      if (widget.use24HourFormat) {
        hourHandLength = (_selectedHour == 0 || _selectedHour >= 13) ? radius * 0.80 : radius * 0.52;
      }
      final minuteHandLength = radius * 0.76;
      final secondHandLength = radius * 0.83;

      final hourAngleRad = (_selectedHour * 30 + _selectedMinute * 0.5) * pi / 180 - pi / 2;
      final minuteAngleRad = _selectedMinute * 6 * pi / 180 - pi / 2;
      final secondAngleRad = _selectedSecond * 6 * pi / 180 - pi / 2;

      final hourTip = Offset(
        center.dx + hourHandLength * cos(hourAngleRad),
        center.dy + hourHandLength * sin(hourAngleRad),
      );
      final minuteTip = Offset(
        center.dx + minuteHandLength * cos(minuteAngleRad),
        center.dy + minuteHandLength * sin(minuteAngleRad),
      );
      final secondTip = Offset(
        center.dx + secondHandLength * cos(secondAngleRad),
        center.dy + secondHandLength * sin(secondAngleRad),
      );

      final distToHourTip = (localPosition - hourTip).distance;
      final distToMinuteTip = (localPosition - minuteTip).distance;
      final distToSecondTip = widget.showSeconds ? (localPosition - secondTip).distance : double.infinity;

      // Classify the drag hand based on proximity
      if (widget.showSeconds && distToSecondTip < distToHourTip && distToSecondTip < distToMinuteTip) {
        _activeDragHand = 'second';
        _currentMode = PickerMode.second;
      } else if (distToHourTip < distToMinuteTip || distanceFromCenter < radius * 0.6) {
        _activeDragHand = 'hour';
        _currentMode = PickerMode.hour;
      } else {
        _activeDragHand = 'minute';
        _currentMode = PickerMode.minute;
      }
      _lastHapticValue = null;
    }

    setState(() {
      if (_activeDragHand == 'hour') {
        if (widget.use24HourFormat) {
          final double hourDouble = fraction * 12;
          int hourVal = hourDouble.round() % 12;
          if (hourVal == 0) hourVal = 12;

          // Determine if inner or outer concentric ring based on radius
          final isInner = distanceFromCenter < radius * 0.66;
          int newHour;
          if (isInner) {
            newHour = hourVal; // 1 to 12
          } else {
            newHour = hourVal == 12 ? 0 : hourVal + 12; // 13 to 23, 00
          }

          if (newHour != _selectedHour) {
            _selectedHour = newHour;
            _notifyTimeChanged();
            
            if (_lastHapticValue != newHour) {
              HapticFeedback.selectionClick();
              _lastHapticValue = newHour;
            }
          }
        } else {
          final double hourDouble = fraction * 12;
          int newHour = hourDouble.round();
          if (newHour == 0) newHour = 12;

          if (newHour != _selectedHour) {
            _selectedHour = newHour;
            _notifyTimeChanged();
            
            if (_lastHapticValue != newHour) {
              HapticFeedback.selectionClick();
              _lastHapticValue = newHour;
            }
          }
        }
      } else if (_activeDragHand == 'minute') {
        final double minuteDouble = fraction * 60;
        int newMinute = minuteDouble.round() % 60;

        if (newMinute != _selectedMinute) {
          _selectedMinute = newMinute;
          _notifyTimeChanged();

          if (_lastHapticValue != newMinute) {
            HapticFeedback.selectionClick();
            _lastHapticValue = newMinute;
          }
        }
      } else if (_activeDragHand == 'second') {
        final double secondDouble = fraction * 60;
        int newSecond = secondDouble.round() % 60;

        if (newSecond != _selectedSecond) {
          _selectedSecond = newSecond;
          _notifyTimeChanged();

          if (_lastHapticValue != newSecond) {
            HapticFeedback.selectionClick();
            _lastHapticValue = newSecond;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Size dialSize = Size(260, 260);

    final hStyle = _theme.headerTimeStyle ??
        TextStyle(
          color: _theme.headerTimeColor,
          fontSize: widget.showSeconds ? 44 : 56,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          fontFamily: 'Outfit',
        );

    final activeStyle = hStyle.copyWith(
      fontWeight: FontWeight.w500,
      color: _theme.hourHandColor,
    );
    final inactiveStyle = hStyle.copyWith(
      color: _theme.headerTimeColor.withOpacity(0.35),
    );

    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: _theme.backgroundColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: _theme.showGlow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ]
            : null,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            if (widget.title != null)
              Text(
                widget.title!,
                style: _theme.titleStyle ??
                    TextStyle(
                      color: _theme.titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Outfit',
                    ),
                textAlign: TextAlign.center,
              ),
            
            // Subtitle
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: _theme.subtitleStyle ??
                    TextStyle(
                      color: _theme.subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Outfit',
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 12),

            // Huge digital display at top (Interactive Segments)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentMode = PickerMode.hour);
                    },
                    child: Text(
                      _formattedHour,
                      style: _currentMode == PickerMode.hour ? activeStyle : inactiveStyle,
                    ),
                  ),
                  Text(
                    ":",
                    style: inactiveStyle,
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentMode = PickerMode.minute);
                    },
                    child: Text(
                      _formattedMinute,
                      style: _currentMode == PickerMode.minute ? activeStyle : inactiveStyle,
                    ),
                  ),
                  if (widget.showSeconds) ...[
                    Text(
                      ":",
                      style: inactiveStyle,
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _currentMode = PickerMode.second);
                      },
                      child: Text(
                        _formattedSecond,
                        style: _currentMode == PickerMode.second ? activeStyle : inactiveStyle,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Interactive Clock Face container
            SizedBox(
              width: dialSize.width,
              height: dialSize.height,
              child: GestureDetector(
                onPanStart: (details) => _handleGesture(details.localPosition, dialSize, isStart: true),
                onPanUpdate: (details) => _handleGesture(details.localPosition, dialSize),
                onPanEnd: (_) {
                  setState(() {
                    _activeDragHand = null;
                  });
                },
                onTapDown: (details) => _handleGesture(details.localPosition, dialSize, isStart: true),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Dial Background and numbers
                    RepaintBoundary(
                      child: CustomPaint(
                        size: dialSize,
                        painter: ClockDialPainter(
                          selectedHour: _selectedHour,
                          selectedMinute: _selectedMinute,
                          selectedSecond: _selectedSecond,
                          theme: _theme,
                          currentMode: _currentMode,
                          use24HourFormat: widget.use24HourFormat,
                        ),
                      ),
                    ),

                    // 2. Interactive Hands (needs to repaint frequently on drag)
                    CustomPaint(
                      size: dialSize,
                      painter: ClockHandPainter(
                        hour: _selectedHour.toDouble(),
                        minute: _selectedMinute.toDouble(),
                        second: _selectedSecond.toDouble(),
                        theme: _theme,
                        currentMode: _currentMode,
                        use24HourFormat: widget.use24HourFormat,
                        showSeconds: widget.showSeconds,
                      ),
                    ),

                    // 3. Center Digital Display (Stack of standard widgets for perfect layouts)
                    Positioned(
                      top: dialSize.height * 0.35,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Set Time:",
                            style: _theme.centerLabelStyle ??
                                TextStyle(
                                  color: _theme.centerLabelColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                          ),
                          const SizedBox(height: 2),
                          
                          // Interactive digital text inside center
                          GestureDetector(
                            onTap: widget.use24HourFormat ? null : _toggleAmPm,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                // Time
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      if (_currentMode == PickerMode.hour) {
                                        _currentMode = PickerMode.minute;
                                      } else if (_currentMode == PickerMode.minute) {
                                        _currentMode = widget.showSeconds ? PickerMode.second : PickerMode.hour;
                                      } else {
                                        _currentMode = PickerMode.hour;
                                      }
                                    });
                                  },
                                  child: Text(
                                    widget.showSeconds
                                        ? "$_formattedHour:$_formattedMinute:$_formattedSecond"
                                        : "$_formattedHour:$_formattedMinute",
                                    style: _theme.centerTimeStyle ??
                                        TextStyle(
                                          color: _theme.centerTimeColor,
                                          fontSize: widget.showSeconds ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Outfit',
                                        ),
                                  ),
                                ),
                                // AM/PM suffix
                                if (!widget.use24HourFormat) ...[
                                  const SizedBox(width: 2),
                                  Text(
                                    _isAm ? "AM" : "PM",
                                    style: _theme.centerLabelStyle?.copyWith(
                                          color: _theme.centerLabelColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ) ??
                                        TextStyle(
                                          color: _theme.centerLabelColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Outfit',
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Period Label (Morning, Afternoon, Evening, Night)
                          Text(
                            _timePeriodLabel,
                            style: _theme.centerPeriodStyle ??
                                TextStyle(
                                  color: _theme.centerPeriodColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Outfit',
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bottom description
            if (widget.description != null) ...[
              Text(
                widget.description!,
                style: _theme.subtitleStyle?.copyWith(
                      color: _theme.subtitleColor,
                      height: 1.4,
                    ) ??
                    TextStyle(
                      color: _theme.subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      fontFamily: 'Outfit',
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // CONFIRM button
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                widget.onConfirm?.call(_currentTimeOfDay);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: _theme.confirmButtonBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _theme.confirmButtonBorderColor,
                    width: 1.5,
                  ),
                  boxShadow: _theme.showGlow
                      ? [
                          BoxShadow(
                            color: _theme.confirmButtonGlowColor,
                            blurRadius: 10 * _theme.glowStrength,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  widget.confirmLabel,
                  style: _theme.confirmButtonStyle ??
                      TextStyle(
                        color: _theme.confirmButtonTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontFamily: 'Outfit',
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A convenience function to show the ClockTimePicker in a modern, themed dialog.
Future<TimeOfDayWithSeconds?> showClockTimePicker({
  required BuildContext context,
  TimeOfDayWithSeconds initialTime = const TimeOfDayWithSeconds(hour: 10, minute: 9, second: 0),
  ClockPickerThemeData? theme,
  String? title,
  String? subtitle,
  String? description,
  String confirmLabel = "CONFIRM",
  bool use24HourFormat = false,
  bool showSeconds = false,
}) {
  return showDialog<TimeOfDayWithSeconds>(
    context: context,
    barrierColor: (theme ?? ClockPickerThemeData.light()).backgroundColor.withOpacity(0.4),
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: ClockTimePicker(
            initialTime: initialTime,
            theme: theme,
            title: title,
            subtitle: subtitle,
            description: description,
            confirmLabel: confirmLabel,
            use24HourFormat: use24HourFormat,
            showSeconds: showSeconds,
            onConfirm: (TimeOfDayWithSeconds time) {
              Navigator.of(context).pop(time);
            },
          ),
        ),
      );
    },
  );
}
