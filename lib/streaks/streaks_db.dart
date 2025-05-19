import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class StreaksDatabase {
  static final StreaksDatabase instance = StreaksDatabase._init();
  static Database? _database;
  bool _isInitialized = false;

  StreaksDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('streaks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await _verifyTables(db);
      },
    );
  }

  Future<void> _verifyTables(Database db) async {
    try {
      await db.rawQuery('SELECT 1 FROM daily_activity LIMIT 1');
      await db.rawQuery('SELECT 1 FROM streak_data LIMIT 1');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Tables not found, creating them...');
      await _createDB(db, 1);
      _isInitialized = true;
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_activity (
        date TEXT PRIMARY KEY,
        total_time INTEGER DEFAULT 0,
        last_updated TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE streak_data (
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0
      )
    ''');

    // Initialize streak data
    await db.insert('streak_data', {
      'current_streak': 0,
      'longest_streak': 0
    });
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      final db = await database;
      await _verifyTables(db);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    _database = null;
    await db.close();
  }

  Future<void> recordDailyActivity(int seconds) async {
    final db = await database;
    final now = DateTime.now().toUtc();
    final today = DateFormat('yyyy-MM-dd').format(now);

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT INTO daily_activity (date, total_time, last_updated)
        VALUES (?, ?, ?)
        ON CONFLICT(date) DO UPDATE SET
          total_time = total_time + excluded.total_time,
          last_updated = excluded.last_updated
      ''', [today, seconds, now.toIso8601String()]);

      await _updateStreak(txn, now);
    });
  }

  Future<void> recordDailyActivityForDate(int seconds, DateTime date) async {
    final db = await database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date.toUtc());

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT INTO daily_activity (date, total_time, last_updated)
        VALUES (?, ?, ?)
        ON CONFLICT(date) DO UPDATE SET
          total_time = total_time + excluded.total_time,
          last_updated = excluded.last_updated
      ''', [dateStr, seconds, DateTime.now().toUtc().toIso8601String()]);

      await _updateStreak(txn, date);
    });
  }

  Future<void> updateStreakForDate(DateTime date) async {
    final db = await database;
    await db.transaction((txn) async {
      await _updateStreak(txn, date);
    });
  }

  Future<void> _updateStreak(Transaction txn, DateTime currentDate) async {
    final activities = await txn.query(
      'daily_activity',
      columns: ['date'],
      orderBy: 'date DESC',
    );

    int streak = 0;
    final currentDateStr = DateFormat('yyyy-MM-dd').format(currentDate.toUtc());

    // Convert all activity dates to DateTime objects and sort them newest to oldest
    final activityDates = activities.map((a) => DateTime.parse(a['date'] as String)).toList();
    activityDates.sort((a, b) => b.compareTo(a));

    // Check if current date or previous day has activity
    final hasCurrentDateActivity = activityDates.any((date) =>
    DateFormat('yyyy-MM-dd').format(date) == currentDateStr);

    final yesterday = currentDate.subtract(const Duration(days: 1));
    final hasYesterdayActivity = activityDates.any((date) =>
    DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(yesterday));

    // If no activity today and no activity yesterday, streak is 0
    if (!hasCurrentDateActivity && !hasYesterdayActivity) {
      await txn.update('streak_data', {
        'current_streak': 0,
        'longest_streak': (await txn.query('streak_data')).first['longest_streak'] as int
      });
      return;
    }

    // Start counting from most recent activity date backward
    DateTime checkDate = hasCurrentDateActivity ? currentDate : yesterday;
    bool streakActive = true;

    while (streakActive) {
      final checkDateStr = DateFormat('yyyy-MM-dd').format(checkDate);

      if (activityDates.any((date) =>
      DateFormat('yyyy-MM-dd').format(date) == checkDateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        streakActive = false;
      }
    }

    // Update streak data
    final currentLongest = (await txn.query('streak_data')).first['longest_streak'] as int;
    await txn.update('streak_data', {
      'current_streak': streak,
      'longest_streak': max(streak, currentLongest)
    });
  }

  Future<Map<String, dynamic>> getCurrentStreak() async {
    final db = await database;
    final data = (await db.query('streak_data')).first;
    return {
      'current': data['current_streak'] as int,
      'longest': data['longest_streak'] as int
    };
  }

  Future<int> getPracticeTimeForDate(DateTime date) async {
    final db = await database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final result = await db.query(
      'daily_activity',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    return result.isEmpty ? 0 : result.first['total_time'] as int;
  }

  Future<int> getTodayPracticeTime() async {
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());

    final result = await db.query(
      'daily_activity',
      where: 'date = ?',
      whereArgs: [today],
    );

    return result.isEmpty ? 0 : result.first['total_time'] as int;
  }

  Future<List<Map<String, dynamic>>> getWeeklyActivities() async {
    final db = await database;
    return await db.query(
      'daily_activity',
      orderBy: 'date DESC',
      limit: 7,
    );
  }

  Future<void> resetAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('daily_activity');
      await txn.update('streak_data', {
        'current_streak': 0,
        'longest_streak': 0
      });
    });
  }
}