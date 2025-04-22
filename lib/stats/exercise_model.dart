import 'package:hearbat/stats/stats_db.dart';

class Exercise {
  final int? id;
  final String name;

  Exercise({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name
    };
  }

  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name']
    );
  }

  static Future<int> insert(Exercise exercise) async {
    final db = await StatsDatabase().database;
    return await db.insert('exercise', exercise.toMap());
  }
}