import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:hearbat/stats/exercise_model.dart';

class StatsDatabase {
  static final StatsDatabase _instance = StatsDatabase._internal();
  factory StatsDatabase() => _instance;
  StatsDatabase._internal();

  static Database? _db;

  Future<void> init() async {
    _db ??= await _initDatabase();
  }

  Future<Database> get database async {
    await init();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), "stats.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create tables
        await db.execute('''
          CREATE TABLE IF NOT EXISTS exercise (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL
          );
          CREATE TABLE IF NOT EXISTS answer (
            exercise_id INTEGER PRIMARY KEY,
            name TEXT PRIMARY KEY,
            correct INTEGER NOT NULL DEFAULT 0,
            incorrect INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (exercise_id) REFERENCES exercise (id)
          );
          CREATE TABLE IF NOT EXISTS module (
            exercise_id INTEGER PRIMARY KEY,
            name TEXT PRIMARY KEY,
            high_score INTEGER NOT NULL DEFAULT 0,
            times_completed INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (exercise_id) REFERENCES exercise (id)
          );
          CREATE TABLE IF NOT EXISTS daily (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE,
            practice_time INTEGER NOT NULL DEFAULT 0
          );
          CREATE TABLE IF NOT EXISTS exercise_score (
            exercise_id INTEGER PRIMARY KEY,
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            daily_id INTEGER NOT NULL,
            score INTEGER NOT NULL,
            max_score INTEGER NOT NULL,
            bg_noise REAL NOT NULL DEFAULT 0,
            FOREIGN KEY (exercise_id) REFERENCES exercise (id),
            FOREIGN KEY (daily_id) REFERENCES daily (id)
          );
        ''');

        // Fill exercise table
        const exerciseNames = [
          "words",
          "sounds",
          "speech",
          "music"
        ];
        for (final name in exerciseNames) {
          Exercise.insert(Exercise(name: name));
        }
      }
    );
  }
}