import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/streaks/streaks_provider.dart';
import 'package:hearbat/streaks/streaks_db.dart';
import 'package:hearbat/streaks/streaks_model.dart';
import 'package:intl/intl.dart';

class DailyStreakPage extends StatefulWidget {
  const DailyStreakPage({super.key});

  @override
  State<DailyStreakPage> createState() => _DailyStreakPageState();
}

class _DailyStreakPageState extends State<DailyStreakPage> {
  String _debugInfo = 'Loading debug info...';
  bool _showDebug = false;
  DateTime _simulatedNow = DateTime.now();
  final TextEditingController _timeController = TextEditingController(
    text: DateFormat('HH:mm').format(DateTime.now()),
  );
  final ScrollController _debugScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  @override
  void dispose() {
    _timeController.dispose();
    _debugScrollController.dispose();
    super.dispose();
  }

  String get _displayTime {
    return DateFormat('yyyy-MM-dd HH:mm').format(_simulatedNow);
  }

  Future<void> _loadDebugInfo() async {
    try {
      final db = await StreaksDatabase.instance.database;
      final activities = await db.query('streak_activity');

      String formatActivity(Map<String, dynamic> activity) {
        final utcDate = activity['activity_date'] is String
            ? DateTime.parse(activity['activity_date'] as String)
            : activity['activity_date'] as DateTime;
        final lastActivityTime = activity['last_activity_time'] is String
            ? DateTime.parse(activity['last_activity_time'] as String)
            : activity['last_activity_time'] as DateTime;
        return '${utcDate.toIso8601String()} (UTC) | '
            'Last activity: ${lastActivityTime.toIso8601String()} (UTC) | '
            '${activity['total_practice_time']} secs';
      }

      setState(() {
        _debugInfo = '''
=== STREAK DATABASE DEBUG INFO ===
(All times shown in UTC exactly as stored in database)

ACTIVITIES:
${activities.map(formatActivity).join('\n')}

TOTAL ACTIVITIES: ${activities.length}
''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error loading debug info: $e';
      });
    }
  }

  Future<void> _advanceSimulatedDay() async {
    final provider = context.read<StreakProvider>();
    setState(() => _simulatedNow = _simulatedNow.add(const Duration(days: 1)));
    await _loadDebugInfo();
    provider.loadStreakData();
  }

  Future<void> _rewindSimulatedDay() async {
    final provider = context.read<StreakProvider>();
    setState(() => _simulatedNow = _simulatedNow.subtract(const Duration(days: 1)));
    await _loadDebugInfo();
    provider.loadStreakData();
  }

  Future<void> _recordTestActivity() async {
    final timeParts = _timeController.text.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 12;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    setState(() {
      _simulatedNow = DateTime(
        _simulatedNow.year,
        _simulatedNow.month,
        _simulatedNow.day,
        hour,
        minute,
      );
    });

    // Create local date without time (for proper UTC conversion)
    final localDate = DateTime(
      _simulatedNow.year,
      _simulatedNow.month,
      _simulatedNow.day,
    );

    await Provider.of<StreakProvider>(context, listen: false)
        .recordActivityForDate(60, localDate.toUtc());
    await _loadDebugInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Streak'),
        actions: [
          IconButton(
            icon: Icon(
                _showDebug ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () {
              setState(() {
                _showDebug = !_showDebug;
              });
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Consumer<StreakProvider>(
                builder: (context, provider, _) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (_showDebug) ...[
                          Text(
                            'Simulated Date: $_displayTime, (Local)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                        ],
                        _buildStreakHeader(provider.currentStreak),
                        const SizedBox(height: 24),
                        _buildWeeklyCalendar(provider.weeklyActivities),

                        if (_showDebug) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const Text('DEBUG INFO',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Scrollbar(
                              controller: _debugScrollController,
                              child: SingleChildScrollView(
                                controller: _debugScrollController,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _debugInfo,
                                    style: const TextStyle(
                                        fontFamily: 'monospace', fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0),
                            child: TextField(
                              controller: _timeController,
                              decoration: const InputDecoration(
                                labelText: 'Activity Time (HH:mm) - Local Time',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              ),
                              keyboardType: TextInputType.datetime,
                              onChanged: (value) {
                                final timeParts = value.split(':');
                                if (timeParts.length == 2) {
                                  final hour = int.tryParse(timeParts[0]) ??
                                      _simulatedNow.hour;
                                  final minute = int.tryParse(timeParts[1]) ??
                                      _simulatedNow.minute;
                                  setState(() {
                                    _simulatedNow = DateTime(
                                      _simulatedNow.year,
                                      _simulatedNow.month,
                                      _simulatedNow.day,
                                      hour,
                                      minute,
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              SizedBox(
                                width: 110,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: _advanceSimulatedDay,
                                  child: const Text(
                                      '+1 Day', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: _rewindSimulatedDay,
                                  child: const Text(
                                      '-1 Day', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final provider = context.read<StreakProvider>(); // Get before async
                                    await StreaksDatabase.instance.resetStreak();
                                    await _loadDebugInfo();
                                    provider.loadStreakData();
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Reset', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: _recordTestActivity,
                                  child: const Text(
                                      'Add', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakHeader(int currentStreak) {
    return Column(
      children: [
        const Icon(Icons.local_fire_department, size: 60, color: Colors.orange),
        const SizedBox(height: 8),
        Text(
          '$currentStreak day${currentStreak != 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          currentStreak > 0 ? 'Keep it going!' : 'Start practicing!',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar(List<StreakActivity> activities) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Generate dates for each displayed day (3 before, current, 3 after)
    final dates = List.generate(7, (index) {
      final offset = index - 3; // -3 to +3 range for 7 days
      return _simulatedNow.add(Duration(days: offset));
    });

    return Column(
      children: [
        const Text('This week', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final date = dates[index];
            final isToday = date.day == _simulatedNow.day &&
                date.month == _simulatedNow.month &&
                date.year == _simulatedNow.year;

            final hasActivity = activities.any((activity) {
              final activityUtcDate = activity.activityDate is String
                  ? DateTime.parse(activity.activityDate as String)
                  : activity.activityDate;
              return activityUtcDate.year == date.year &&
                  activityUtcDate.month == date.month &&
                  activityUtcDate.day == date.day;
            });

            return Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isToday ? Colors.orange.withAlpha(51) : null,
                    shape: BoxShape.circle,
                    border: isToday ? Border.all(color: Colors.orange) : null,
                  ),
                  child: Icon(
                    hasActivity ? Icons.check : Icons.circle_outlined,
                    color: hasActivity ? Colors.orange : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(weekdays[date.weekday - 1]),
              ],
            );
          }),
        ),
      ],
    );
  }
}