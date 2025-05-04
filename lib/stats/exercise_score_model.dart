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
}