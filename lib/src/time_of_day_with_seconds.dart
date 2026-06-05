import 'package:flutter/material.dart';

/// A class representing a time of day with hour, minute, and second.
class TimeOfDayWithSeconds {
  /// The hour (0 to 23).
  final int hour;

  /// The minute (0 to 59).
  final int minute;

  /// The second (0 to 59).
  final int second;

  /// Creates a time of day from the given hour, minute, and second.
  const TimeOfDayWithSeconds({
    required this.hour,
    required this.minute,
    this.second = 0,
  })  : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60),
        assert(second >= 0 && second < 60);

  /// Creates a time of day with the current system time.
  factory TimeOfDayWithSeconds.now() {
    final DateTime now = DateTime.now();
    return TimeOfDayWithSeconds(
      hour: now.hour,
      minute: now.minute,
      second: now.second,
    );
  }

  /// Creates a time of day from a [DateTime].
  factory TimeOfDayWithSeconds.fromDateTime(DateTime dateTime) {
    return TimeOfDayWithSeconds(
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
    );
  }

  /// Creates a time of day from a [TimeOfDay].
  factory TimeOfDayWithSeconds.fromTimeOfDay(TimeOfDay timeOfDay, [int second = 0]) {
    return TimeOfDayWithSeconds(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
      second: second,
    );
  }

  /// Gets whether this time is AM or PM.
  DayPeriod get period => hour < 12 ? DayPeriod.am : DayPeriod.pm;

  /// Gets the hour of the period (1 to 12).
  int get hourOfPeriod {
    final int hour12 = hour % 12;
    return hour12 == 0 ? 12 : hour12;
  }

  /// Converts this time of day to a standard [TimeOfDay] (discarding seconds).
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Formats the time in standard `HH:mm:ss` format.
  String format(BuildContext context) {
    final String hourStr = hour.toString().padLeft(2, '0');
    final String minuteStr = minute.toString().padLeft(2, '0');
    final String secondStr = second.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr:$secondStr';
  }

  /// Formats the time in 12-hour format with AM/PM: `hh:mm:ss AM/PM`.
  String format12Hour() {
    final String h = hourOfPeriod.toString().padLeft(2, '0');
    final String m = minute.toString().padLeft(2, '0');
    final String s = second.toString().padLeft(2, '0');
    final String p = period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m:$s $p';
  }

  @override
  bool operator ==(Object other) {
    return other is TimeOfDayWithSeconds &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() {
    return 'TimeOfDayWithSeconds(${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')})';
  }
}
