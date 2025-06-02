import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/streaks/streaks_provider.dart';
import 'package:intl/intl.dart';
import '../streaks/streaks_model.dart';
import '../utils/translations.dart';

class DailyStreakPage extends StatefulWidget {
  const DailyStreakPage({super.key});

  @override
  State<DailyStreakPage> createState() => _DailyStreakPageState();
}

class _DailyStreakPageState extends State<DailyStreakPage> {
  bool _showDebug = false;
  DateTime _simulatedNow = DateTime.now();
  int _practiceTimeInput = 300;
  String _databaseContent = '';

  @override
  void initState() {
    super.initState();
    Provider.of<StreakProvider>(context, listen: false).loadStreakData();
  }

  Future<void> _moveDate(int days) async {
    setState(() {
      _simulatedNow = _simulatedNow.add(Duration(days: days));
    });
    await Provider.of<StreakProvider>(context, listen: false)
        .recalculateStreaksForDate(_simulatedNow);
  }

  String _formatPracticeTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return AppLocale.dailyStreakPageHours.getString(context)
          .replaceFirst('{hours}', '$hours')
          .replaceFirst('{minutes}', '$minutes');
    } else if (minutes > 0) {
      return AppLocale.dailyStreakPageMinutes.getString(context)
          .replaceFirst('{minutes}', '$minutes');
    } else {
      return AppLocale.dailyStreakPageLessThanMinute.getString(context);
    }
  }

  Future<void> _addSession() async {
    final provider = Provider.of<StreakProvider>(context, listen: false);
    await provider.recordPracticeTimeForDate(_practiceTimeInput, _simulatedNow);
    await _updateDatabaseContent();
    setState(() {});
  }

  Future<void> _updateDatabaseContent() async {
    final provider = Provider.of<StreakProvider>(context, listen: false);
    final db = await provider.getDatabaseInstance();

    try {
      final activities = await db.query('daily_activity');
      final streakData = await db.query('streak_data');

      setState(() {
        _databaseContent = '''
Daily Activities:
${activities.map((a) => '${a['date']}: ${a['total_time']} sec').join('\n')}

Streak Data:
${streakData.map((s) => 'Current: ${s['current_streak']} days, Longest: ${s['longest_streak']} days').join('\n')}
''';
      });
    } catch (e) {
      setState(() {
        _databaseContent = 'Error reading database: $e';
      });
    }
  }

  Widget _buildStreakHeader(int currentStreak, int longestStreak) {
    return Column(
      children: [
        const Icon(Icons.local_fire_department, size: 60, color: Colors.orange),
        const SizedBox(height: 8),
        Text(
          AppLocale.dailyStreakPageDays.getString(context).replaceFirst('{days}', '$currentStreak'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocale.dailyStreakPageLongestStreak.getString(context).replaceFirst('{days}', '$longestStreak'),
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          currentStreak > 0
              ? AppLocale.dailyStreakPageKeepGoing.getString(context)
              : AppLocale.dailyStreakPageStartPracticing.getString(context),
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.dailyStreakPageTitle.getString(context)),
        actions: [
          IconButton(
            icon: Icon(_showDebug ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () {
              setState(() {
                _showDebug = !_showDebug;
                if (_showDebug) {
                  _updateDatabaseContent();
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<StreakProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStreakHeader(provider.currentStreak, provider.longestStreak),
                const SizedBox(height: 24),
                _buildWeeklyCalendar(provider.weeklyActivities),
                const SizedBox(height: 16),
                FutureBuilder<int>(
                  future: provider.getPracticeTimeForDate(_simulatedNow),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(
                        AppLocale.dailyStreakPageErrorLoading.getString(context),
                        style: TextStyle(color: Colors.red[600], fontSize: 16),
                      );
                    }
                    final practiceTime = snapshot.data ?? 0;
                    return Text(
                      AppLocale.dailyStreakPagePracticeOn.getString(context)
                          .replaceFirst('{date}', DateFormat('MMM d').format(_simulatedNow))
                          .replaceFirst('{time}', _formatPracticeTime(practiceTime)),
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
                if (_showDebug) _buildDebugControls(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyCalendar(List<DailyActivity> activities) {
    final weekdays = [
      AppLocale.dailyStreakPageWeekdayMonday.getString(context),
      AppLocale.dailyStreakPageWeekdayTuesday.getString(context),
      AppLocale.dailyStreakPageWeekdayWednesday.getString(context),
      AppLocale.dailyStreakPageWeekdayThursday.getString(context),
      AppLocale.dailyStreakPageWeekdayFriday.getString(context),
      AppLocale.dailyStreakPageWeekdaySaturday.getString(context),
      AppLocale.dailyStreakPageWeekdaySunday.getString(context),
    ];
    final dates = List.generate(7, (index) {
      return _simulatedNow.add(Duration(days: index - 3));
    });

    return Column(
      children: [
        Text(
          AppLocale.dailyStreakPageThisWeek.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dates.map((date) {
            final isCurrent = date.day == _simulatedNow.day &&
                date.month == _simulatedNow.month &&
                date.year == _simulatedNow.year;

            final activity = activities.firstWhere(
                  (a) => a.date == DateFormat('yyyy-MM-dd').format(date),
              orElse: () => DailyActivity(
                date: DateFormat('yyyy-MM-dd').format(date),
                totalTime: 0,
                lastUpdated: date,
              ),
            );

            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.orange.withAlpha(102) : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? Colors.orange : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    activity.totalTime > 0 ? Icons.check : Icons.circle_outlined,
                    color: activity.totalTime > 0 ? Colors.orange : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(weekdays[date.weekday - 1]),
                if (activity.totalTime > 0)
                  Text(
                    _formatPracticeTime(activity.totalTime),
                    style: const TextStyle(fontSize: 10),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDebugControls(StreakProvider provider) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              const Text('DEBUG CONTROLS', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await provider.forceFirestoreSync();
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Manual sync completed'))
                    );

                    await _updateDatabaseContent();
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sync failed: $e'))
                    );
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 20),
                    SizedBox(width: 8),
                    Text('Force Sync'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Text('Practice Time (sec):'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _practiceTimeInput = int.tryParse(value) ?? 300;
                      },
                      decoration: const InputDecoration(
                        hintText: '300',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _moveDate(-1),
                    child: const Text('-1 Day'),
                  ),
                  ElevatedButton(
                    onPressed: _addSession,
                    child: const Text('Add Session'),
                  ),
                  ElevatedButton(
                    onPressed: () => _moveDate(1),
                    child: const Text('+1 Day'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Current debug date: ${DateFormat('yyyy-MM-dd').format(_simulatedNow)}',
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await provider.resetLocalData();
                  setState(() {
                    _simulatedNow = DateTime.now();
                  });
                  await _updateDatabaseContent();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Reset Local Data'),
              ),

              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await provider.resetRemoteData();
                  setState(() {
                    _simulatedNow = DateTime.now();
                  });
                  await _updateDatabaseContent();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Reset Remote Data'),
              ),

              const SizedBox(height: 16),
              Text(
                'Current streak: ${provider.currentStreak} days',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Longest streak: ${provider.longestStreak} days',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),
              const Text(
                'Database Content:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _databaseContent,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}