import 'package:flutter/foundation.dart';
import 'package:hearbat/streaks/streaks_db.dart';
import 'package:hearbat/streaks/streaks_model.dart';
import 'package:sqflite/sqflite.dart';

class StreakProvider with ChangeNotifier {
  int _currentStreak = 0;
  int _longestStreak = 0;
  List<DailyActivity> _weeklyActivities = [];
  bool _isLoading = true;
  int _todayPracticeTime = 0;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<DailyActivity> get weeklyActivities => _weeklyActivities;
  int get todayPracticeTime => _todayPracticeTime;
  bool get isLoading => _isLoading;

  StreakProvider() {
    loadStreakData();
  }

  Future<void> loadStreakData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final streakData = await StreaksDatabase.instance.getCurrentStreak();
      _currentStreak = streakData['current'];
      _longestStreak = streakData['longest'];

      final activities = await StreaksDatabase.instance.getWeeklyActivities();
      _weeklyActivities = activities.map(DailyActivity.fromMap).toList();

      _todayPracticeTime = await StreaksDatabase.instance.getTodayPracticeTime();
    } catch (e) {
      debugPrint('Error loading streak data: $e');
      _currentStreak = 0;
      _longestStreak = 0;
      _weeklyActivities = [];
      _todayPracticeTime = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Database> getDatabaseInstance() async {
    return await StreaksDatabase.instance.database;
  }

  Future<int> getPracticeTimeForDate(DateTime date) async {
    return await StreaksDatabase.instance.getPracticeTimeForDate(date);
  }

  Future<void> recordPracticeTime(int seconds) async {
    try {
      _isLoading = true;
      notifyListeners();

      await StreaksDatabase.instance.recordDailyActivity(seconds);
      await loadStreakData();
    } catch (e) {
      debugPrint('Error recording practice time: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordPracticeTimeForDate(int seconds, DateTime date) async {
    try {
      _isLoading = true;
      notifyListeners();

      final utcDate = DateTime.utc(date.year, date.month, date.day);
      await StreaksDatabase.instance.recordDailyActivityForDate(seconds, utcDate);
      await loadStreakData();
    } catch (e) {
      debugPrint('Error recording practice time: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recalculateStreaksForDate(DateTime date) async {
    try {
      _isLoading = true;
      notifyListeners();

      await StreaksDatabase.instance.updateStreakForDate(date);
      await loadStreakData();
    } catch (e) {
      debugPrint('Error recalculating streaks: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forceFirestoreSync() async {
    await StreaksDatabase.instance.syncWithFirestore();
  }

  Future<void> resetRemoteData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await StreaksDatabase.instance.resetRemoteData();
      await loadStreakData(); // Refresh the local data after remote reset
    } catch (e) {
      debugPrint('Error resetting remote data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetLocalData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await StreaksDatabase.instance.resetLocalData();
      await loadStreakData();
    } catch (e) {
      debugPrint('Error resetting data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}