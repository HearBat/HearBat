import 'package:hearbat/stats/daily_model.dart';
import 'package:hearbat/stats/exercise_model.dart';
import 'package:hearbat/stats/module_model.dart';
import 'package:hearbat/stats/stats_db.dart';

class ExerciseScore {
  static const _table = "exercise_score";

  final int? id;
  final int moduleId;
  final int dailyId;
  final int score;
  final int maxScore;
  final double? bgNoise;

  ExerciseScore(
      {this.id,
      required this.moduleId,
      required this.dailyId,
      required this.score,
      required this.maxScore,
      this.bgNoise});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'daily_id': dailyId,
      'score': score,
      'max_score': maxScore,
      if (bgNoise != null) 'bg_noise': bgNoise
    };
  }

  static ExerciseScore fromMap(Map<String, dynamic> map) {
    return ExerciseScore(
        id: map['id'],
        moduleId: map['module_id'],
        dailyId: map['daily_id'],
        score: map['score'],
        maxScore: map['max_score'],
        bgNoise: map['bg_noise']);
  }

  static Future<int?> insert(String exerciseType, String moduleName,
      DateTime date, int score, int maxScore,
      {double? bgNoise}) async {
    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return null;
    }

    final dailyId = await Daily.getIDByDate(date) ?? await Daily.insert(date);

    final module = await Module.getModuleByName(moduleName);
    if (module == null) {
      return null;
    }

    final db = await StatsDatabase().database;
    final ExerciseScore exerciseScore = ExerciseScore(
        moduleId: module.id!,
        dailyId: dailyId,
        score: score,
        maxScore: maxScore,
        bgNoise: bgNoise);
    return await db.insert(_table, exerciseScore.toMap());
  }

  static Future<double> getExerciseAccuracyByDay(
      String exerciseType, DateTime date) async {
    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return 0.0;
    }
    final dailyId = await Daily.getIDByDate(date);
    if (dailyId == null) {
      return 0.0;
    }
    final db = await StatsDatabase().database;
    final result = await db.rawQuery('''
      SELECT SUM(es.score)*1.0/SUM(es.max_score) AS accuracy
      FROM exercise_score es
      INNER JOIN module m ON m.id = es.module_id
      WHERE m.exercise_id = ? AND es.daily_id = ?''', [exerciseId, dailyId]);
    if (result.isEmpty) {
      return 0.0;
    }
    final accuracy = result.first['accuracy'];
    if (accuracy is double) {
      return accuracy;
    } else if (accuracy is int) {
      return accuracy.toDouble();
    }
    return 0.0;
  }

  static Future<double> getExerciseBGNoiseByDay(
      String exerciseType, DateTime date) async {
    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return 0.0;
    }
    final dailyId = await Daily.getIDByDate(date);
    if (dailyId == null) {
      return 0.0;
    }
    final db = await StatsDatabase().database;
    final result = await db.rawQuery('''
      SELECT AVG(es.bg_noise) as avg_noise
      FROM exercise_score es
      INNER JOIN module m ON m.id = es.module_id
      WHERE m.exercise_id = ? AND es.daily_id = ?''', [exerciseId, dailyId]);
    if (result.isEmpty) {
      return 0.0;
    }
    final avgNoise = result.first['avg_noise'];
    if (avgNoise is double) {
      return avgNoise;
    } else if (avgNoise is int) {
      return avgNoise.toDouble();
    }
    return 0.0;
  }

  static Future<int> getHighScoreCompletions(String moduleName) async {
    final module = await Module.getModuleByName(moduleName);
    if (module == null) {
      return 0;
    }
    
    final db = await StatsDatabase().database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM exercise_score es
      INNER JOIN module m ON m.id = es.module_id
      WHERE es.score >= 8 AND m.id = ?
    ''', [module.id]);
    
    int count = result.first['count'] as int? ?? 0;
    return count;
  }
}
