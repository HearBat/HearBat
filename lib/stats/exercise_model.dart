import 'package:hearbat/stats/stats_db.dart';

class Exercise {
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
    return await db.insert('exercise', exercise.toMap());
  }
}