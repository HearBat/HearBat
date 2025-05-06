import 'package:hearbat/stats/stats_db.dart';

class Daily {
  static const _table = "daily";

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
      if (practiceTime != null) 'practice_time': practiceTime
    };
  }

  static Daily fromMap(Map<String, dynamic> map) {
    return Daily(
      id: map['id'],
      date: map['date'],
      practiceTime: map['practice_time']
    );
  }

  static String _formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final year = date.year.toString();
    final month = twoDigits(date.month);
    final day = twoDigits(date.day);

    return "$year-$month-$day";
  }
  
  static Future<int> insert(DateTime date, {int? practiceTime}) async {
    final db = await StatsDatabase().database;
    final daily = Daily(date: _formatDate(date), practiceTime: practiceTime);
    return await db.insert(_table, daily.toMap());
  }

  static Future<int?> getIDByDate(DateTime date) async {
    final db = await StatsDatabase().database;
    final result = await db.rawQuery('''
      SELECT *
      FROM $_table
      WHERE date=?''', [_formatDate(date)]);
    if (result.isEmpty) {
      return null;
    }
    return result.first['id'] as int;
  }
}