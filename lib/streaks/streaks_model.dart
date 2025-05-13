import 'package:flutter/foundation.dart';

@immutable
class StreakActivity {
  final int? id;
  final DateTime activityDate;
  final DateTime lastActivityTime;
  final int totalPracticeTime;

  const StreakActivity({
    this.id,
    required this.activityDate,
    required this.lastActivityTime,
    this.totalPracticeTime = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'activity_date': activityDate.toUtc().toIso8601String(),
      'last_activity_time': lastActivityTime.toUtc().toIso8601String(),
      'total_practice_time': totalPracticeTime,
    };
  }

  factory StreakActivity.fromMap(Map<String, dynamic> map) {
    return StreakActivity(
      id: map['id'] as int?,
      activityDate: DateTime.parse(map['activity_date']).toUtc(),
      lastActivityTime: DateTime.parse(map['last_activity_time']).toUtc(),
      totalPracticeTime: map['total_practice_time'] as int,
    );
  }
}

@immutable
class StreakMetadata {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastUpdated;

  const StreakMetadata({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_updated': lastUpdated.toUtc().toIso8601String(),
    };
  }

  factory StreakMetadata.fromMap(Map<String, dynamic> map) {
    return StreakMetadata(
      currentStreak: map['current_streak'] as int,
      longestStreak: map['longest_streak'] as int,
      lastUpdated: DateTime.parse(map['last_updated']).toUtc(),
    );
  }
}