import 'package:hearbat/stats/exercise_model.dart';
import 'package:hearbat/stats/stats_db.dart';

class Module {
  static const _table = "module";

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
      if (highScore != null) 'high_score': highScore,
      if (timesCompleted != null) 'times_completed': timesCompleted
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

  static Future<Module?> getModuleByName(String name) async {
    final db = await StatsDatabase().database;
    final result = await db.rawQuery('''
      SELECT *
      FROM $_table
      WHERE name=?''', [name]);
    if (result.isEmpty) {
      return null;
    }
    return Module.fromMap(result.first);
  }

  static Future<int?> updateStats(String exerciseType, String name, int score) async {
    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return null;
    }

    // Create row for module if it doesn't exist
    if (await getModuleByName(name) == null) {
      return await insert(Module(
          exerciseId: exerciseId,
          name: name,
          highScore: score,
          timesCompleted: 1));
    }

    // Update high_score and increment times_completed
    final db = await StatsDatabase().database;
    return await db.rawUpdate('''
      UPDATE $_table
      SET
        high_score = MAX(high_score, ?),
        times_completed = times_completed + 1
      WHERE exercise_id=? AND name=?''',
      [score, exerciseId, name]);
  }
}