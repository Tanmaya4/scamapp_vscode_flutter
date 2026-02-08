import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';

/// SQLite database helper for SafeCall.
class SafeCallDatabase {
  SafeCallDatabase._();
  static final SafeCallDatabase instance = SafeCallDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE threat_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        level TEXT NOT NULL,
        detectedContent TEXT NOT NULL,
        confidence REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        sessionId TEXT NOT NULL,
        actionTaken TEXT NOT NULL,
        phoneNumber TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE stranger_mode_sessions (
        sessionId TEXT PRIMARY KEY,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        plannedDurationMs INTEGER NOT NULL,
        actualDurationMs INTEGER,
        threatsDetected INTEGER DEFAULT 0,
        wasCallEnded INTEGER DEFAULT 0,
        endReason TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE blocked_notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        packageName TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        sessionId TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations in future versions
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
