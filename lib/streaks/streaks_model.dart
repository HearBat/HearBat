
class DailyActivity {
  final String date;
  final int totalTime;
  final DateTime lastUpdated;

  DailyActivity({
    required this.date,
    required this.totalTime,
    required this.lastUpdated,
  });

  factory DailyActivity.fromMap(Map<String, dynamic> map) {
    return DailyActivity(
      date: map['date'] as String,
      totalTime: map['total_time'] as int,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
    );
  }
}