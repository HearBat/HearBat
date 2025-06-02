// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hearbat/stats/stats_db.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:hearbat/pages/missed_answers_page.dart';
import 'package:hearbat/stats/exercise_score_model.dart';
import 'package:hearbat/utils/translations.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/streaks/streaks_provider.dart';
import 'package:hearbat/pages/daily_streak_page.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  InsightsPageState createState() => InsightsPageState();
}

class InsightsPageState extends State<InsightsPage> {
  DateTime _focusedDay = DateTime.now(); // Current day
  double _progressBarValue = 0.0;
  int _timePracticed = 0;
  int _speechAccuracy = 0;
  //int _noiseAccuracy = 0;
  static const int _dailyGoalSeconds = 600;
  Map<DateTime, int> _activityMap = {};

  List<FlSpot> _speechAccuracyData = [];
  List<String> _dateLabels = [];
  bool _isLoadingChartData = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyStats(DateTime.now());
    _loadActivityData();
    _loadChartData();
  }

  void _loadChartData() async {
    final spots = await _getSpeechAccuracyOverTime();
    final labels = await _getDateLabels();
    
    setState(() {
      _speechAccuracyData = spots;
      _dateLabels = labels;
      _isLoadingChartData = false;
    });
  }

  void _loadActivityData() async {
    final provider = Provider.of<StreakProvider>(context, listen: false);
    final activities = await provider.getAllActivities();

    Map<DateTime, int> tempMap = {};
    for (var activity in activities) {
      final date = DateTime.parse(activity.date);
      tempMap[DateTime(date.year, date.month, date.day)] = activity.totalTime;
    }

    setState(() {
      _activityMap = tempMap;
    });
  }

  void _fetchDailyStats(DateTime date) async {
    final provider = Provider.of<StreakProvider>(context, listen: false);
    final timePracticed = await provider.getPracticeTimeForDate(date);
    final speechAccuracy = await ExerciseScore.getExerciseAccuracyByDay("speech", date);
    // This currently tracks the average bg noise level of speech exercises--can reevaluate later
    //final noiseAccuracy = await ExerciseScore.getExerciseBGNoiseByDay("speech", date);

    setState(() {
      _timePracticed = timePracticed;
      _speechAccuracy = (speechAccuracy*100).ceil();
      //_noiseAccuracy = (noiseAccuracy*100).ceil();
      _progressBarValue = _timePracticed / _dailyGoalSeconds;
      if (_progressBarValue > 1.0) {
        _progressBarValue = 1.0;
      }
    });
  }

  // Navigate to previous month
  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  // Navigate to next month
  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  // Get month name and year as string
  String _formattedMonthYear(DateTime date) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  // Progress bar header
  String _formattedToday(DateTime date) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String suffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1: return 'st';
        case 2: return 'nd';
        case 3: return 'rd';
        default: return 'th';
      }
    }

    return '${AppLocale.insightsPageToday.getString(context)}, ${monthNames[date.month - 1]} ${date.day}${suffix(date.day)}';
  }

  String _formatPracticeTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${seconds.toString().padLeft(2, '0')}';
    }
  }

// REAL DATA METHODS
Future<List<FlSpot>> _getSpeechAccuracyOverTime() async {
  try {
    final db = await StatsDatabase().database;
    
    final result = await db.rawQuery('''
      SELECT d.date, AVG(CAST(es.score AS REAL) / es.max_score) as avg_accuracy
      FROM exercise_score es
      JOIN module m ON es.module_id = m.id
      JOIN exercise e ON m.exercise_id = e.id
      JOIN daily d ON es.daily_id = d.id
      WHERE e.type = 'speech'
      GROUP BY d.date
      ORDER BY d.date ASC
    ''');
    if (result.isEmpty) {
      return []; 
    }
    List<FlSpot> spots = [];
    for (int i = 0; i < result.length; i++) {
      final accuracy = (result[i]['avg_accuracy'] as double) * 100;
      spots.add(FlSpot(i.toDouble(), accuracy));
    }
    return spots;
  } catch (e) {
    print('Error fetching speech accuracy data: $e');
    return [];
  }
}

Future<List<String>> _getDateLabels() async {
  try {
    final db = await StatsDatabase().database;
    
    final result = await db.rawQuery('''
      SELECT DISTINCT d.date
      FROM exercise_score es
      JOIN module m ON es.module_id = m.id
      JOIN exercise e ON m.exercise_id = e.id
      JOIN daily d ON es.daily_id = d.id
      WHERE e.type = 'speech'
      ORDER BY d.date ASC
    ''');
    return result.map((row) => row['date'] as String).toList();
  } catch (e) {
    print('Error fetching date labels: $e');
    return [];
  }
}

// FILLER DATA METHODS
// List<FlSpot> _getSpeechAccuracyOverTime() {
//   return [
//     FlSpot(0, 65),  // Day 1
//     FlSpot(1, 68),  // Day 1 (second exercise)
//     FlSpot(2, 72),  // Day 3
//     FlSpot(3, 75),  // Day 3 (second exercise)
//     FlSpot(4, 78),  // Day 5
//     FlSpot(5, 82),  // Day 8
//     FlSpot(6, 85),  // Day 8 (second exercise)
//     FlSpot(7, 88),  // Day 8 (third exercise)
//     FlSpot(8, 84),  // Day 10
//     FlSpot(9, 90),  // Day 12
//     FlSpot(10, 100),  // Day 12
//   ];
// }

// List<String> _getDateLabels() {
//   final now = DateTime.now();
//   return [
//     DateTime(now.year, now.month, now.day - 12).toIso8601String(), // Day 1
//     DateTime(now.year, now.month, now.day - 12).toIso8601String(), // Day 1 (same day)
//     DateTime(now.year, now.month, now.day - 10).toIso8601String(), // Day 3
//     DateTime(now.year, now.month, now.day - 10).toIso8601String(), // Day 3 (same day)
//     DateTime(now.year, now.month, now.day - 8).toIso8601String(),  // Day 5
//     DateTime(now.year, now.month, now.day - 5).toIso8601String(),  // Day 8
//     DateTime(now.year, now.month, now.day - 5).toIso8601String(),  // Day 8 (same day)
//     DateTime(now.year, now.month, now.day - 5).toIso8601String(),  // Day 8 (same day)
//     DateTime(now.year, now.month, now.day - 3).toIso8601String(),  // Day 10
//     DateTime(now.year, now.month, now.day - 1).toIso8601String(),  // Day 12
//     DateTime(now.year, now.month, now.day).toIso8601String(),  // Day 12
//   ];
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: AppLocale.insightsPageTitle.getString(context)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCalendar(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    DateTime today = DateTime.now();

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 7, 45, 78),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _goToPreviousMonth,
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Text(
                            _formattedMonthYear(_focusedDay),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: _goToNextMonth,
                            child: Icon(Icons.arrow_forward, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      onPageChanged: (newFocusedDay) {
                        setState(() {
                          _focusedDay = newFocusedDay;
                        });
                        _fetchDailyStats(_focusedDay);
                      },
                      onDaySelected: (selectedDay, newFocusedDay) {
                        setState(() {
                          _focusedDay = newFocusedDay;
                        });
                        _fetchDailyStats(selectedDay);
                      },
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      headerVisible: false,
                      daysOfWeekHeight: 16,
                      daysOfWeekStyle: DaysOfWeekStyle(
                        dowTextFormatter: (date, locale) {
                          final weekday = date.weekday;
                          return ['S', 'M', 'T', 'W', 'T', 'F', 'S'][weekday % 7];
                        },
                        weekdayStyle: TextStyle(
                          color: Color.fromARGB(179, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                        weekendStyle: TextStyle(
                          color: Color.fromARGB(179, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        cellMargin: EdgeInsets.zero,
                        cellPadding: EdgeInsets.symmetric(vertical: 4),
                        todayDecoration: BoxDecoration(
                          color: Color.fromARGB(255, 7, 45, 78),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.green[700],
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        weekendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final normalizedDate = DateTime(date.year, date.month, date.day);
                          if (_activityMap.containsKey(normalizedDate) && _activityMap[normalizedDate]! > 0) {
                            return Positioned(
                              right: 1,
                              bottom: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  shape: BoxShape.circle,
                                ),
                                width: 8,
                                height: 8,
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),


        // Daily tracker page
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            // Dark blue tracker header
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 7, 45, 78),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: 
                Center(
                  child: Text(
                  _formattedToday(today),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18, 
                    ),
                  ),
                ),
              ),

              // Tracker content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocale.insightsPageTimePracticed.getString(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _formatPracticeTime(_timePracticed),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                    value: _progressBarValue,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 110, 211, 97),
                    ),
                    minHeight: 12,
                  ),
                  ),
                  const SizedBox(height: 8),
                    Text(
                      '${_formatPracticeTime(_timePracticed)} / ${_formatPracticeTime(_dailyGoalSeconds)}',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),

                      // Accuracy Box
                  const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // ensure same height across both boxes
                  children: [
                    Expanded(
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 7, 45, 78),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Left-aligned
                          children: [
                            Text(
                              '$_speechAccuracy%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppLocale.insightsPageSpeechAccuracy.getString(context),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 12), // space between the two boxes

                    // Streak widget
                    Expanded(
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 7, 45, 78),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Consumer<StreakProvider>(
                          builder: (context, provider, _) => GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DailyStreakPage()),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.local_fire_department,
                                        color: Colors.orange, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      '${provider.currentStreak}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  AppLocale.dailyStreakPageDays.getString(context)
                                      .replaceFirst('{days}', ''),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  ],
                ),
              ),
            ],
          ),
        ),

    const SizedBox(height: 16), 

    // View Most Missed Words
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MissedAnswersPage(type: "words")),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 7, 45, 78),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            AppLocale.insightsPageMissedWords.getString(context),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),

    SizedBox(height: 16),

    // View Most Missed Sounds
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MissedAnswersPage(type: "sounds")),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 7, 45, 78),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            AppLocale.insightsPageMissedSounds.getString(context),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),

        
    const SizedBox(height: 16),

Container(            
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 7, 45, 78),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocale.insightsPageSpeechAccuracyGraphTitle.getString(context), 
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18, 
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              child: _isLoadingChartData 
                ? Center(child: CircularProgressIndicator())
                : LineChart(
                    LineChartData(
                      backgroundColor: Colors.transparent,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 20,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.6),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: _speechAccuracyData.isEmpty ? 1 : 
                              (_speechAccuracyData.length > 6 ? 
                                (_speechAccuracyData.length / 6).ceil().toDouble() : 1),
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (_speechAccuracyData.isEmpty) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(''),
                                );
                              }
                              
                              final index = value.toInt();
                              if (index >= 0 && index < _dateLabels.length) {
                                final date = DateTime.parse(_dateLabels[index]);
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    '${date.month}/${date.day}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(''),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Container(
                                margin: EdgeInsets.only(right: 8),
                                child: Text(
                                  '${value.toInt()}%',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                            reservedSize: 42,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      minX: 0,
                      maxX: _speechAccuracyData.isEmpty ? 5 : (_speechAccuracyData.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100,
                      lineBarsData: _speechAccuracyData.isEmpty ? [] : [
                        LineChartBarData(
                          spots: _speechAccuracyData,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 7, 45, 78),
                              Color.fromARGB(255, 110, 211, 97),
                            ],
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: Color.fromARGB(255, 110, 211, 97),
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 110, 211, 97).withOpacity(0.3),
                                Color.fromARGB(255, 110, 211, 97).withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: _speechAccuracyData.isNotEmpty,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final index = barSpot.x.toInt();
                              final accuracy = barSpot.y.toInt();
                              String dateStr = '';
                              if (index >= 0 && index < _dateLabels.length) {
                                final date = DateTime.parse(_dateLabels[index]);
                                dateStr = '${date.month}/${date.day}: ';
                              }
                              return LineTooltipItem(
                                '$dateStr$accuracy%',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    ),
                  ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    ],
  ),
),
        ]
      )
    );
  }
}
