import 'dart:convert';
import 'dart:io';
import 'package:hearbat/streaks/streaks_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StreaksDatabase {
  static final StreaksDatabase instance = StreaksDatabase._init();
  static Database? _database;

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
      version: 3, // Incremented version for new streak logic
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE streak_activity (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          activity_date TEXT UNIQUE NOT NULL,
          last_activity_time TEXT NOT NULL,
          total_practice_time INTEGER DEFAULT 0
        )
      ''');

      await txn.execute('''
        CREATE TABLE streak_metadata (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          current_streak INTEGER DEFAULT 0,
          longest_streak INTEGER DEFAULT 0,
          last_updated TEXT NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE INDEX idx_activity_date 
        ON streak_activity(activity_date)
      ''');

      // Initialize metadata
      await txn.insert('streak_metadata', {
        'current_streak': 0,
        'longest_streak': 0,
        'last_updated': DateTime.now().toUtc().toIso8601String()
      });
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE INDEX idx_activity_date 
        ON streak_activity(activity_date)
      ''');
    }
    // Add any additional upgrade logic here if needed
  }

  Future<void> close() async {
    final db = await instance.database;
    _database = null;
    await db.close();
  }

  /// Records activity if no activity exists for the current UTC day
  Future<void> recordActivity(int practiceTime) async {
    final db = await database;
    await db.transaction((txn) async {
      final nowUtc = DateTime.now().toUtc();
      final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

      // Check if activity already exists for today
      final existing = await txn.query(
        'streak_activity',
        where: 'date(activity_date) = date(?)',
        whereArgs: [todayUtc.toIso8601String()],
      );

      if (existing.isEmpty) {
        // Only record if no activity for today
        await txn.insert(
          'streak_activity',
          {
            'activity_date': todayUtc.toIso8601String(),
            'last_activity_time': nowUtc.toIso8601String(),
            'total_practice_time': practiceTime,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await _updateStreak(txn);
      } else {
        // Update existing activity with new practice time
        await txn.update(
          'streak_activity',
          {
            'last_activity_time': nowUtc.toIso8601String(),
            'total_practice_time': practiceTime,
          },
          where: 'date(activity_date) = date(?)',
          whereArgs: [todayUtc.toIso8601String()],
        );
      }
    });
  }

  Future<void> recordActivityForDate(int practiceTime, DateTime date) async {
    final db = await database;
    await db.transaction((txn) async {
      final dateUtc = date.toUtc();
      final dayUtc = DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);

      // Check if activity already exists for this day
      final existing = await txn.query(
        'streak_activity',
        where: 'date(activity_date) = date(?)',
        whereArgs: [dayUtc.toIso8601String()],
      );

      if (existing.isEmpty) {
        await txn.insert(
          'streak_activity',
          {
            'activity_date': dayUtc.toIso8601String(),
            'last_activity_time': dateUtc.toIso8601String(),
            'total_practice_time': practiceTime,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await txn.update(
          'streak_activity',
          {
            'last_activity_time': dateUtc.toIso8601String(),
            'total_practice_time': practiceTime,
          },
          where: 'date(activity_date) = date(?)',
          whereArgs: [dayUtc.toIso8601String()],
        );
      }

      await _updateStreak(txn);
    });
  }

  /// Checks if we should record a new activity (no activity for current UTC day)
  Future<bool> shouldRecordActivity() async {
    final db = await database;
    final nowUtc = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

    final activities = await db.query(
      'streak_activity',
      where: 'date(activity_date) = date(?)',
      whereArgs: [todayUtc.toIso8601String()],
    );

    return activities.isEmpty;
  }

  /// Updates streak counts based on UTC calendar days
  Future<void> _updateStreak(Transaction txn) async {
    final activities = await txn.query(
      'streak_activity',
      orderBy: 'activity_date DESC',
    );

    if (activities.isEmpty) {
      await txn.update('streak_metadata', {'current_streak': 0});
      return;
    }

    int streak = 0;
    DateTime? previousLocalDate;

    for (final activity in activities) {
      final utcDate = DateTime.parse(activity['activity_date'] as String);
      final localDate = utcDate.toLocal();
      final currentDate = DateTime(localDate.year, localDate.month, localDate.day);

      if (previousLocalDate == null) {
        streak = 1;
        previousLocalDate = currentDate;
        continue;
      }

      final difference = previousLocalDate.difference(currentDate).inDays;

      if (difference == 1) {
        streak++;
        previousLocalDate = currentDate;
      } else if (difference > 1) {
        break;
      }
    }

    await txn.update('streak_metadata', {'current_streak': streak});
  }

  /// Gets the last activity date in local time
  Future<DateTime?> getLastActivityLocalDate() async {
    try {
      final db = await database;
      final activities = await db.query(
        'streak_activity',
        orderBy: 'activity_date DESC',
        limit: 1,
      );

      if (activities.isEmpty) return null;

      final utcDate = DateTime.parse(activities.first['activity_date'] as String);
      return utcDate.toLocal();
    } catch (e) {
      return null;
    }
  }

  Future<StreakMetadata> getStreakMetadata() async {
    try {
      final db = await database;
      final maps = await db.query('streak_metadata');
      if (maps.isEmpty) throw Exception('No streak metadata found');
      return StreakMetadata.fromMap(maps.first);
    } catch (e) {
      return StreakMetadata(
        currentStreak: 0,
        longestStreak: 0,
        lastUpdated: DateTime.now().toUtc(),
      );
    }
  }

  Future<int> getCurrentStreak() async {
    final meta = await getStreakMetadata();
    return meta.currentStreak;
  }

  Future<List<StreakActivity>> getWeeklyActivities() async {
    final db = await database;
    final maps = await db.query('streak_activity'); // No date filtering
    return maps.map(StreakActivity.fromMap).toList();
  }

  Future<void> resetStreak() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('streak_activity');
      await txn.update(
        'streak_metadata',
        {
          'current_streak': 0,
          'longest_streak': 0,
          'last_updated': DateTime.now().toUtc().toIso8601String(),
        },
      );
    });
  }

  Future<void> backupToFile(String filePath) async {
    final db = await database;
    final file = File(filePath);

    final activities = await db.query('streak_activity');
    final metadata = await db.query('streak_metadata');

    await file.writeAsString(jsonEncode({
      'activities': activities,
      'metadata': metadata,
    }));
  }

  Future<void> restoreFromFile(String filePath) async {
    final db = await database;
    final file = File(filePath);
    final data = jsonDecode(await file.readAsString());

    await db.transaction((txn) async {
      await txn.delete('streak_activity');
      await txn.delete('streak_metadata');

      for (final activity in data['activities']) {
        await txn.insert('streak_activity', activity);
      }

      await txn.insert('streak_metadata', data['metadata']);
    });
  }
}