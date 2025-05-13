import 'package:flutter/foundation.dart';
import 'package:hearbat/streaks/streaks_db.dart';
import 'package:hearbat/streaks/streaks_model.dart';

class StreakProvider with ChangeNotifier {
  int _currentStreak = 0;
  List<StreakActivity> _weeklyActivities = [];
  bool _isLoading = true; // Add loading state

  int get currentStreak => _currentStreak;
  List<StreakActivity> get weeklyActivities => _weeklyActivities;
  bool get isLoading => _isLoading; // Expose loading state

  StreakProvider() {
    _initialize(); // Load data when provider is created
  }

  Future<void> _initialize() async {
    await loadStreakData();
  }

  Future<void> loadStreakData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final meta = await StreaksDatabase.instance.getStreakMetadata();
      _currentStreak = meta.currentStreak;
      _weeklyActivities = await StreaksDatabase.instance.getWeeklyActivities();

      debugPrint('Loaded streak: $_currentStreak'); // Debug print
    } catch (e) {
      debugPrint('Error loading streak data: $e');
      _currentStreak = 0;
      _weeklyActivities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordActivityForDate(int practiceTime, DateTime date) async {
    try {
      _isLoading = true;
      notifyListeners();

      await StreaksDatabase.instance.recordActivityForDate(practiceTime, date);
      await loadStreakData();
    } catch (e) {
      debugPrint('Error recording activity for date: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordActivity(int practiceTime) async {
    try {
      _isLoading = true;
      notifyListeners();

      await StreaksDatabase.instance.recordActivity(practiceTime);
      await loadStreakData();
    } catch (e) {
      debugPrint('Error recording activity: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}