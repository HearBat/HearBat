import 'package:hearbat/stats/stats_db.dart';

class Answer {
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

  static Future<int> insert(Answer answer) async {
    final db = await StatsDatabase().database;
    return await db.insert('answer', answer.toMap());
  }
}