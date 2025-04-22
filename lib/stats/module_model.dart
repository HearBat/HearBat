import 'package:hearbat/stats/stats_db.dart';

class Module{
  final int exerciseId;
  final String name;
  final int? highScore;
  final int? timesCompleted;

  Module({
    required this.exerciseId,
    required this.name,
    this.highScore,
    this.timesCompleted
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'high_score': highScore,
      'times_completed': timesCompleted
    };
  }

  static Module fromMap(Map<String, dynamic> map) {
    return Module(
      exerciseId: map['exercise_id'],
      name: map['name'],
      highScore: map['high_score'],
      timesCompleted: map['times_completed']
    );
  }

  static Future<int> insert(Module module) async {
    final db = await StatsDatabase().database;
    return await db.insert('module', module.toMap());
  }
}