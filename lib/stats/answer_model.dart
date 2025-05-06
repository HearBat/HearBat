import 'package:hearbat/stats/exercise_model.dart';
import 'package:hearbat/stats/stats_db.dart';

class Answer {
  static const _table = "answer";

  final int exerciseId;
  final String name;
  final int? correct;
  final int? incorrect;

  Answer({
    required this.exerciseId,
    required this.name,
    this.correct,
    this.incorrect
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'correct': correct,
      'incorrect': incorrect
    };
  }

  static Answer fromMap(Map<String, dynamic> map) {
    return Answer(
      exerciseId: map['exercise_id'],
      name: map['name'],
      correct: map['correct'],
      incorrect: map['incorrect']
    );
  }

  static Future<int?> insert(String exerciseType, String name) async {
    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return null;
    }

    final db = await StatsDatabase().database;
    return await db.rawInsert('''
      INSERT INTO $_table (exercise_id, name)
      VALUES (?, ?)''',
      [exerciseId, name]);
  }

  static Future<Answer?> getAnswer(String exerciseType, String name) async {
    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return null;
    }

    final db = await StatsDatabase().database;
    final result = await db.rawQuery('''
      SELECT *
      FROM $_table
      WHERE exercise_id=? AND name=?''',
      [exerciseId, name]);
    if (result.isEmpty) {
      return null;
    }
    return Answer.fromMap(result.first);
  }

  static Future<int?> updateStats(String exerciseType, String name, bool correct) async {
    // Create answer row if it doesn't exist
    final answer = await getAnswer(exerciseType, name);
    if (answer == null) {
      await insert(exerciseType, name);
    }

    final exerciseId = await Exercise.getIDByType(exerciseType);
    if (exerciseId == null) {
      return null;
    }

    final db = await StatsDatabase().database;
    final col = correct ? "correct" : "incorrect";
    return await db.rawUpdate('''
      UPDATE $_table
      SET $col = $col + 1
      WHERE exercise_id=? AND name=?''',
      [exerciseId, name]);
  }
}