// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:time_picker_pro/time_picker_pro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Default to Light theme (white theme)

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Picker Pro Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: DemoHomeScreen(
        themeMode: _themeMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const DemoHomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  TimeOfDayWithSeconds _time1 = const TimeOfDayWithSeconds(hour: 8, minute: 30, second: 0);
  TimeOfDayWithSeconds _time2 = const TimeOfDayWithSeconds(hour: 15, minute: 45, second: 30);
  TimeOfDayWithSeconds _time3 = const TimeOfDayWithSeconds(hour: 22, minute: 10, second: 15);
  TimeOfDayWithSeconds _time4 = const TimeOfDayWithSeconds(hour: 17, minute: 15, second: 45);
  TimeOfDayWithSeconds _time5 = const TimeOfDayWithSeconds(hour: 10, minute: 9, second: 0);
  TimeOfDayWithSeconds _time6 = const TimeOfDayWithSeconds(hour: 10, minute: 9, second: 0);

  void _showStandardPicker() {
    showDialog(
      context: context,
      builder: (context) => CustomTimePicker(
        initialTime: _time1,
        showSeconds: false,
        onTimeSelected: (time) {
          setState(() {
            _time1 = time;
          });
        },
      ),
    );
  }

  void _showSecondsPicker() {
    showDialog(
      context: context,
      builder: (context) => CustomTimePicker(
        initialTime: _time2,
        showSeconds: true,
        onTimeSelected: (time) {
          setState(() {
            _time2 = time;
          });
        },
      ),
    );
  }

  void _show24HourPicker() {
    showDialog(
      context: context,
      builder: (context) => CustomTimePicker(
        initialTime: _time4,
        showSeconds: true,
        use24HourFormat: true,
        onTimeSelected: (time) {
          setState(() {
            _time4 = time;
          });
        },
      ),
    );
  }

  void _showClockPickerLight() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ClockTimePicker(
          initialTime: _time5,
          theme: ClockPickerThemeData.light(),
          showSeconds: true,
          title: "White Theme Time Picker",
          subtitle: "Dark Grey",
          description: "Clean White Theme\nSeconds & Concentric 24-Hour support",
          onTimeChanged: (time) {
            setState(() {
              _time5 = time;
            });
          },
          onConfirm: (time) {
            setState(() {
              _time5 = time;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showClockPickerDark() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ClockTimePicker(
          use24HourFormat : true,
          initialTime: _time6,
          theme: ClockPickerThemeData.dark(),
          showSeconds: true,
          title: "Dark Theme Time Picker",
          subtitle: "White",
          description: "Sleek  Dark Mode Theme\nNeon glowing clock hand accents",
          onTimeChanged: (time) {
            setState(() {
              _time6 = time;
            });
          },
          onConfirm: (time) {
            setState(() {
              _time6 = time;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showThemedPicker() {
    showDialog(
      context: context,
      builder: (context) => CustomTimePicker(
        initialTime: _time3,
        showSeconds: true,
        titleText: "SECURITY DISARM TIME",
        titleStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
        titleAlignment: TextAlign.left,
        titlePosition: Alignment.centerLeft,
        titlePadding: const EdgeInsets.only(left: 4, bottom: 16),
        showTitle: true,
        borderRadius: BorderRadius.circular(16),
        segmentBorderRadius: BorderRadius.circular(6),
        timeSegmentStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white30,
        ),
        activeTimeSegmentStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
        primaryColor: Colors.amber,
        accentColor: Colors.amberAccent,
        backgroundColor: const Color(0xFF13131A),
        dialBackgroundColor: const Color(0xFF1C1B22),
        dialTextColor: Colors.white60,
        dialSelectedTextColor: Colors.black,
        handColor: Colors.redAccent,
        selectionBubbleColor: Colors.amber,
        textColor: Colors.white,
        onTimeSelected: (time) {
          setState(() {
            _time3 = time;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.3),
              theme.colorScheme.primary.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Header with Title and Theme Switch
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.av_timer_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Time Picker Pro',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'A highly customizable Flutter time picker with seconds support and fluid animations.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          widget.themeMode == ThemeMode.light
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: widget.onThemeToggle,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Selected Times showcase
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildShowcaseCard(
                        title: 'Standard Mode (HH:mm)',
                        subtitle: 'No seconds selection',
                        time: _time1,
                        hasSeconds: false,
                        color: theme.colorScheme.primary,
                        onTap: _showStandardPicker,
                      ),
                      const SizedBox(height: 16),
                      _buildShowcaseCard(
                        title: 'Precision Mode (HH:mm:ss)',
                        subtitle: 'With high-precision seconds',
                        time: _time2,
                        hasSeconds: true,
                        color: Colors.purpleAccent,
                        onTap: _showSecondsPicker,
                      ),
                      const SizedBox(height: 16),
                      _buildShowcaseCard(
                        title: '24-Hour Precision Mode',
                        subtitle: 'Concentric 24-hour dial layout',
                        time: _time4,
                        hasSeconds: true,
                        use24HourDisplay: true,
                        color: Colors.tealAccent,
                        onTap: _show24HourPicker,
                      ),
                      const SizedBox(height: 16),
                      _buildShowcaseCard(
                        title: 'ClockTimePicker (Light Theme)',
                        subtitle: 'Clean White Theme dialer style',
                        time: _time5,
                        hasSeconds: true,
                        color: Colors.blue,
                        onTap: _showClockPickerLight,
                      ),
                      const SizedBox(height: 16),
                      _buildShowcaseCard(
                        title: 'ClockTimePicker (Dark Theme)',
                        subtitle: 'Sleek Dark Mode Theme dialer style',
                        time: _time6,
                        hasSeconds: true,
                        color: const Color(0xFF14B8A6), // teal-500
                        onTap: _showClockPickerDark,
                      ),
                      const SizedBox(height: 16),
                      _buildShowcaseCard(
                        title: 'Custom Themed Mode',
                        subtitle: 'Amber & Charcoal dark palette',
                        time: _time3,
                        hasSeconds: true,
                        color: Colors.amber,
                        onTap: _showThemedPicker,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShowcaseCard({
    required String title,
    required String subtitle,
    required TimeOfDayWithSeconds time,
    required bool hasSeconds,
    bool use24HourDisplay = false,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    String formattedTime;
    if (use24HourDisplay) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      final s = time.second.toString().padLeft(2, '0');
      formattedTime = hasSeconds ? '$h:$m:$s' : '$h:$m';
    } else {
      formattedTime = hasSeconds 
          ? time.format12Hour() 
          : '${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? "AM" : "PM"}';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Display glowing clock style time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Courier',
                          color: color,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: color.withOpacity(0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
