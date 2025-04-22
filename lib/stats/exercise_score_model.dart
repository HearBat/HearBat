import 'package:hearbat/stats/stats_db.dart';

class ExerciseScore {
  final int? id;
  final String name;
  final int dailyId;
  final int score;
  final int maxScore;
  final double? bgNoise;

  ExerciseScore({
    this.id,
    required this.name,
    required this.dailyId,
    required this.score,
    required this.maxScore,
    this.bgNoise
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'daily_id': dailyId,
      'score': score,
      'max_score': maxScore,
      'bg_noise': bgNoise
    };
  }

  static ExerciseScore fromMap(Map<String, dynamic> map) {
    return ExerciseScore(
      id: map['id'],
      name: map['name'],
      dailyId: map['daily_id'],
      score: map['score'],
      maxScore: map['max_score'],
      bgNoise: map['bg_noise']
    );
  }

  static Future<int> insert(ExerciseScore exerciseScore) async {
    final db = await StatsDatabase().database;
    return await db.insert('exercise_score', exerciseScore.toMap());
  }
}