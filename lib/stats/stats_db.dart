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

  Future<void> _onCreate(Database db, int version) async {
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER,
        name TEXT,
        high_score INTEGER NOT NULL DEFAULT 0,
        times_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (exercise_id) REFERENCES exercise (id)
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
        module_id INTEGER NOT NULL,
        daily_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        max_score INTEGER NOT NULL,
        bg_noise REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (module_id) REFERENCES module (id),
        FOREIGN KEY (daily_id) REFERENCES daily (id)
      )''');

    // Fill exercise table
    const exerciseTypes = ["words", "sounds", "speech", "music"];
    for (final type in exerciseTypes) {
      Exercise.insert(Exercise(type: type));
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4 && newVersion >= 4) {
      await db.execute("DROP TABLE IF EXISTS exercise_score");
      await db.execute("DROP TABLE IF EXISTS answer");        
      await db.execute("DROP TABLE IF EXISTS module");       
      await db.execute("DROP TABLE IF EXISTS daily");         
      await db.execute("DROP TABLE IF EXISTS exercise");    
      await _onCreate(db, newVersion);
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), "stats.db");
    return await openDatabase(
        path,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade
    );
  }
}