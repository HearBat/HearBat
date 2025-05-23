import 'package:hearbat/stats/daily_model.dart';
import 'package:hearbat/stats/exercise_model.dart';
import 'package:hearbat/stats/stats_db.dart';

class ExerciseScore {
  static const _table = "exercise_score";

  final int exerciseId;
  final int? id;
  final int dailyId;
  final int score;
  final int maxScore;
  final double? bgNoise;

  ExerciseScore({
    required this.exerciseId,
    this.id,
    required this.dailyId,
    required this.score,
    required this.maxScore,
    this.bgNoise
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'id': id,
      'daily_id': dailyId,
      'score': score,
      'max_score': maxScore,
      if (bgNoise != null) 'bg_noise': bgNoise
    };
  }

  static ExerciseScore fromMap(Map<String, dynamic> map) {
    return ExerciseScore(
      exerciseId: map['exercise_id'],
      id: map['id'],
      dailyId: map['daily_id'],
      score: map['score'],
      maxScore: map['max_score'],
      bgNoise: map['bg_noise']
    );
  }

  static Future<int?> insert(String exerciseType, DateTime date, int score, int maxScore, {double? bgNoise}) async {
    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return null;
    }

    final dailyId = await Daily.getIDByDate(date) ?? await Daily.insert(date);

    final db = await StatsDatabase().database;
    final ExerciseScore exerciseScore = ExerciseScore(
        exerciseId: exerciseId,
        dailyId: dailyId,
        score: score,
        maxScore: maxScore,
        bgNoise: bgNoise);
    return await db.insert(_table, exerciseScore.toMap());
  }

  static Future<double> getExerciseAccuracyByDay(String exerciseType, DateTime date) async {
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
      SELECT SUM(score)*1.0/SUM(max_score) AS accuracy
      FROM exercise_score
      WHERE exercise_id=? AND daily_id=?''', [exerciseId, dailyId]);
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

  static Future<double> getExerciseBGNoiseByDay(String exerciseType, DateTime date) async {
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
      SELECT AVG(bg_noise) as avg_noise
      FROM exercise_score
      WHERE exercise_id=? AND daily_id=?''', [exerciseId, dailyId]);
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
}