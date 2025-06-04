import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class StreaksDatabase {
  static final StreaksDatabase instance = StreaksDatabase._init();
  static Database? _database;
  bool _isInitialized = false;
  bool _fcmInitialized = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  CollectionReference? _dailyActivityRef;
  DocumentReference? _streakDataRef;
  String? _deviceId;
  String? _fcmToken;

  StreaksDatabase._init() {
    _initializePaths();
  }

  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      } else {
        _deviceId = 'unsupported_device';
      }
      return _deviceId!;
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      _deviceId = 'fallback_device_id';
      return _deviceId!;
    }
  }

  Future<void> _initializeFCM() async {
    if (_fcmInitialized) return;

    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _fcmToken = await _firebaseMessaging.getToken();
        debugPrint('Obtained FCM Token: $_fcmToken');

        if (_fcmToken != null && _deviceId != null) {
          await _storeFcmToken();
        }

        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _storeFcmToken();
        });
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    } finally {
      _fcmInitialized = true;
    }
  }

  Future<void> _storeFcmToken() async {
    if (_deviceId == null || _fcmToken == null) return;

    try {
      await _firestore.collection('device_tokens').doc(_deviceId).set({
        'token': _fcmToken,
        'lastUpdated': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      }, SetOptions(merge: true));
      debugPrint('FCM token stored successfully');
    } catch (e) {
      debugPrint('Error storing FCM token: $e');
    }
  }

  Future<void> _initializePaths() async {
    final deviceId = await _getDeviceId();
    _dailyActivityRef = _firestore
        .collection('device_data')
        .doc(deviceId)
        .collection('daily_activity');

    _streakDataRef = _firestore
        .collection('device_data')
        .doc(deviceId)
        .collection('streak_data')
        .doc('current');
  }

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
        longest_streak INTEGER DEFAULT 0,
        last_updated TEXT NOT NULL
      )
    ''');

    await db.insert('streak_data', {
      'current_streak': 0,
      'longest_streak': 0,
      'last_updated': DateTime.now().toUtc().toIso8601String()
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

  Future<bool> _shouldSyncBeforeLocalUpdate(String date) async {
    final remoteDoc = await _dailyActivityRef!.doc(date).get();
    if (!remoteDoc.exists) return false;

    final localData = await database.then((db) => db.query(
      'daily_activity',
      where: 'date = ?',
      whereArgs: [date],
    ));

    return localData.isEmpty ||
        (remoteDoc['total_time'] as int) > (localData.first['total_time'] as int);
  }

  Future<void> syncWithFirestore() async {
    if (_dailyActivityRef == null || _streakDataRef == null) return;

    try {
      final db = await database;
      await _syncDailyActivities(db);
      await _syncStreakData(db);
    } catch (e) {
      debugPrint('Error syncing with Firestore: $e');
    }
  }

  Future<void> _syncDailyActivities(Database db) async {
    final localActivities = await db.query('daily_activity');
    final remoteSnapshot = await _dailyActivityRef!.get();

    final localMap = {for (var a in localActivities) a['date'] as String: a};
    final remoteMap = {for (var d in remoteSnapshot.docs) d.id: d.data() as Map<String, dynamic>};

    for (final remoteEntry in remoteMap.entries) {
      final localEntry = localMap[remoteEntry.key];
      final remoteData = remoteEntry.value;
      final remoteTime = remoteData['total_time'] as int;

      if (localEntry == null) {
        await db.insert('daily_activity', {
          'date': remoteEntry.key,
          'total_time': remoteTime,
          'last_updated': remoteData['last_updated'],
        });
      } else {
        final localTime = localEntry['total_time'] as int;
        if (remoteTime > localTime) {
          await db.update(
            'daily_activity',
            {
              'total_time': remoteTime,
              'last_updated': remoteData['last_updated'],
            },
            where: 'date = ?',
            whereArgs: [remoteEntry.key],
          );
        }
      }
    }

    for (final localEntry in localMap.entries) {
      final remoteData = remoteMap[localEntry.key];
      final localTime = localEntry.value['total_time'] as int;

      if (remoteData == null) {
        await _dailyActivityRef!.doc(localEntry.key).set({
          'total_time': localTime,
          'last_updated': localEntry.value['last_updated'],
        });
      } else {
        final remoteTime = remoteData['total_time'] as int;
        if (localTime > remoteTime) {
          await _dailyActivityRef!.doc(localEntry.key).update({
            'total_time': localTime,
            'last_updated': localEntry.value['last_updated'],
          });
        }
      }
    }
  }

  Future<void> _syncStreakData(Database db) async {
    final localData = (await db.query('streak_data')).first;
    final remoteDoc = await _streakDataRef!.get();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    if (!remoteDoc.exists) {
      await _streakDataRef!.set({
        'current_streak': localData['current_streak'],
        'longest_streak': localData['longest_streak'],
        'last_updated': nowIso,
      });
      return;
    }

    final remoteData = remoteDoc.data() as Map<String, dynamic>;
    final bestCurrentStreak = max(localData['current_streak'] as int, remoteData['current_streak'] as int);
    final bestLongestStreak = max(localData['longest_streak'] as int, remoteData['longest_streak'] as int);

    await db.update(
      'streak_data',
      {
        'current_streak': bestCurrentStreak,
        'longest_streak': bestLongestStreak,
        'last_updated': nowIso,
      },
    );

    await _streakDataRef!.update({
      'current_streak': bestCurrentStreak,
      'longest_streak': bestLongestStreak,
      'last_updated': nowIso,
    });
  }

  Future<void> recordDailyActivity(int seconds) async {
    // Initialize FCM on first recording
    await _initializeFCM();

    final now = DateTime.now().toUtc();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final nowIso = now.toIso8601String();

    final db = await database;
    await db.transaction((txn) async {
      await txn.rawInsert('''
      INSERT INTO daily_activity (date, total_time, last_updated)
      VALUES (?, ?, ?)
      ON CONFLICT(date) DO UPDATE SET
        total_time = total_time + excluded.total_time,
        last_updated = excluded.last_updated
      ''', [today, seconds, nowIso]);

      await _updateStreak(txn, now);
    });

    unawaited(syncWithFirestore());
  }

  Future<void> recordDailyActivityForDate(int seconds, DateTime date) async {
    // Initialize FCM on first recording
    await _initializeFCM();

    final dateStr = DateFormat('yyyy-MM-dd').format(date.toUtc());
    final nowIso = DateTime.now().toUtc().toIso8601String();

    if (await _shouldSyncBeforeLocalUpdate(dateStr)) await syncWithFirestore();

    final db = await database;
    await db.transaction((txn) async {
      await txn.rawInsert('''
      INSERT INTO daily_activity (date, total_time, last_updated)
      VALUES (?, ?, ?)
      ON CONFLICT(date) DO UPDATE SET
        total_time = total_time + excluded.total_time,
        last_updated = excluded.last_updated
    ''', [dateStr, seconds, nowIso]);

      await _updateStreak(txn, date);
    });

    if (!await _shouldSyncBeforeLocalUpdate(dateStr)) unawaited(syncWithFirestore());
  }

  Future<void> updateStreakForDate(DateTime date) async {
    final db = await database;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    await db.transaction((txn) async {
      await _updateStreak(txn, date);
      await txn.update('streak_data', {'last_updated': nowIso});
    });

    try {
      final streak = await getCurrentStreak();
      await _streakDataRef!.set({
        'current_streak': streak['current'],
        'longest_streak': streak['longest'],
        'last_updated': nowIso,
      });
    } catch (e) {
      debugPrint('Error updating Firestore streak: $e');
    }
  }

  Future<void> _updateStreak(Transaction txn, DateTime currentDate) async {
    final activities = await txn.query(
      'daily_activity',
      columns: ['date'],
      orderBy: 'date DESC',
    );

    int streak = 0;
    final currentDateStr = DateFormat('yyyy-MM-dd').format(currentDate.toUtc());
    final activityDates = activities.map((a) => DateTime.parse(a['date'] as String)).toList();
    activityDates.sort((a, b) => b.compareTo(a));

    final hasCurrentDateActivity = activityDates.any((date) =>
    DateFormat('yyyy-MM-dd').format(date) == currentDateStr);

    final yesterday = currentDate.subtract(const Duration(days: 1));
    final hasYesterdayActivity = activityDates.any((date) =>
    DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(yesterday));

    if (!hasCurrentDateActivity && !hasYesterdayActivity) {
      await txn.update('streak_data', {
        'current_streak': 0,
        'longest_streak': (await txn.query('streak_data')).first['longest_streak'] as int
      });
      return;
    }

    DateTime checkDate = hasCurrentDateActivity ? currentDate : yesterday;
    bool streakActive = true;

    while (streakActive) {
      final checkDateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      if (activityDates.any((date) => DateFormat('yyyy-MM-dd').format(date) == checkDateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        streakActive = false;
      }
    }

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

  Future<void> resetRemoteData() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    try {
      final batch = _firestore.batch();
      final activities = await _dailyActivityRef!.get();
      for (final doc in activities.docs) {
        batch.delete(doc.reference);
      }

      batch.set(_streakDataRef!, {
        'current_streak': 0,
        'longest_streak': 0,
        'last_updated': nowIso,
      });

      await batch.commit();

      debugPrint('Successfully reset all remote data');
    } catch (e) {
      debugPrint('Error resetting remote data: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    final db = await database;
    return await db.query(
      'daily_activity',
      orderBy: 'date DESC',
    );
  }

  Future<void> resetLocalData() async {
    final db = await database;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete('daily_activity');
      await txn.update('streak_data', {
        'current_streak': 0,
        'longest_streak': 0,
        'last_updated': nowIso,
      });
    });
  }
}