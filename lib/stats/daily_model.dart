import 'package:hearbat/stats/stats_db.dart';

class Daily {
  final int? id;
  final String date;
  final int? practiceTime;

  Daily({
    this.id,
    required this.date,
    this.practiceTime
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'practice_time': practiceTime
    };
  }

  static Daily fromMap(Map<String, dynamic> map) {
    return Daily(
      id: map['id'],
      date: map['date'],
      practiceTime: map['practice_time']
    );
  }

  static Future<int> insert(Daily daily) async {
    final db = await StatsDatabase().database;
    return await db.insert('daily', daily.toMap());
  }
}