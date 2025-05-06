import 'package:hearbat/stats/stats_db.dart';

class Exercise {
  static const _table = "exercise";

  final int? id;
  final String type;

  Exercise({this.id, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type
    };
  }

  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      type: map['type']
    );
  }

  static Future<int> insert(Exercise exercise) async {
    final db = await StatsDatabase().database;
    return await db.insert(_table, exercise.toMap());
  }

  static Future<int?> getIDByType(String type) async {
    final db = await StatsDatabase().database;
    final result = await db.rawQuery('''
      SELECT *
      FROM $_table
      WHERE type=?''', [type]);
    if (result.isEmpty) {
      return null;
    }
    return result.first['id'] as int;
  }
}