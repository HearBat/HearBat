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
            type TEXT UNIQUE NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS answer (
            exercise_id INTEGER,
            name TEXT,
            correct INTEGER NOT NULL DEFAULT 0,
            incorrect INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (exercise_id) REFERENCES exercise (id),
            PRIMARY KEY (exercise_id, name)
          )''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS module (
            exercise_id INTEGER,
            name TEXT,
            high_score INTEGER NOT NULL DEFAULT 0,
            times_completed INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (exercise_id) REFERENCES exercise (id),
            PRIMARY KEY (exercise_id, name)
          )''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE,
            practice_time INTEGER NOT NULL DEFAULT 0
          )''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS exercise_score (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_id INTEGER NOT NULL,
            daily_id INTEGER NOT NULL,
            score INTEGER NOT NULL,
            max_score INTEGER NOT NULL,
            bg_noise REAL NOT NULL DEFAULT 0,
            FOREIGN KEY (exercise_id) REFERENCES exercise (id),
            FOREIGN KEY (daily_id) REFERENCES daily (id)
          )''');

        // Fill exercise table
        const exerciseTypes = [
          "words", "sounds", "speech", "music"];
        for (final type in exerciseTypes) {
          Exercise.insert(Exercise(type: type));
        }
      }
    );
  }
}