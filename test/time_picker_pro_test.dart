import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_picker_pro/time_picker_pro.dart';

void main() {
  group('TimeOfDayWithSeconds Tests', () {
    test('Initialization and standard properties', () {
      const time = TimeOfDayWithSeconds(hour: 14, minute: 30, second: 15);
      expect(time.hour, 14);
      expect(time.minute, 30);
      expect(time.second, 15);
      expect(time.period, DayPeriod.pm);
      expect(time.hourOfPeriod, 2);
    });

    test('AM PM matching', () {
      const timeAm = TimeOfDayWithSeconds(hour: 9, minute: 0, second: 0);
      expect(timeAm.period, DayPeriod.am);
      expect(timeAm.hourOfPeriod, 9);

      const timeMidnight = TimeOfDayWithSeconds(hour: 0, minute: 5, second: 10);
      expect(timeMidnight.period, DayPeriod.am);
      expect(timeMidnight.hourOfPeriod, 12);
    });

    test('toTimeOfDay conversions', () {
      const time = TimeOfDayWithSeconds(hour: 23, minute: 59, second: 45);
      final standardTime = time.toTimeOfDay();
      expect(standardTime.hour, 23);
      expect(standardTime.minute, 59);
    });

    test('format methods', () {
      const time = TimeOfDayWithSeconds(hour: 15, minute: 8, second: 4);
      expect(time.format12Hour(), '03:08:04 PM');
    });

    test('factory constructors', () {
      final now = TimeOfDayWithSeconds.now();
      expect(now.hour, isNotNull);

      final dateTime = DateTime(2026, 6, 5, 12, 34, 56);
      final fromDateTime = TimeOfDayWithSeconds.fromDateTime(dateTime);
      expect(fromDateTime.hour, 12);
      expect(fromDateTime.minute, 34);
      expect(fromDateTime.second, 56);

      const timeOfDay = TimeOfDay(hour: 18, minute: 45);
      final fromTimeOfDay = TimeOfDayWithSeconds.fromTimeOfDay(timeOfDay, 12);
      expect(fromTimeOfDay.hour, 18);
      expect(fromTimeOfDay.minute, 45);
      expect(fromTimeOfDay.second, 12);
    });
  });

  group('CustomTimePicker Widget Tests', () {
    testWidgets('Renders properly and handles buttons', (WidgetTester tester) async {
      TimeOfDayWithSeconds? selectedTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CustomTimePicker(
                        initialTime: const TimeOfDayWithSeconds(hour: 10, minute: 15, second: 30),
                        showSeconds: true,
                        onTimeSelected: (time) {
                          selectedTime = time;
                        },
                      ),
                    );
                  },
                  child: const Text('Open Picker'),
                );
              },
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Verify widget elements render
      expect(find.text('10'), findsOneWidget); // selected hour
      expect(find.text('15'), findsOneWidget); // selected minute
      expect(find.text('30'), findsOneWidget); // selected second
      expect(find.text('AM'), findsOneWidget);
      expect(find.text('PM'), findsOneWidget);

      // Change to PM
      await tester.tap(find.text('PM'));
      await tester.pumpAndSettle();

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify the selected time is PM (10 PM is 22:00)
      expect(selectedTime, isNotNull);
      expect(selectedTime!.hour, 22);
      expect(selectedTime!.minute, 15);
      expect(selectedTime!.second, 30);
    });
  });
}
