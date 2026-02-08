/// SQLite session history database.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SessionRecord {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final int targetDurationSeconds;
  final int intensity;
  final bool completed;
  final String notes;

  const SessionRecord({
    this.id,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.targetDurationSeconds,
    required this.intensity,
    required this.completed,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'duration_seconds': durationSeconds,
        'target_duration_seconds': targetDurationSeconds,
        'intensity': intensity,
        'completed': completed ? 1 : 0,
        'notes': notes,
      };

  factory SessionRecord.fromMap(Map<String, dynamic> map) => SessionRecord(
        id: map['id'] as int,
        startTime: DateTime.parse(map['start_time'] as String),
        endTime: map['end_time'] != null
            ? DateTime.parse(map['end_time'] as String)
            : null,
        durationSeconds: map['duration_seconds'] as int,
        targetDurationSeconds: map['target_duration_seconds'] as int,
        intensity: map['intensity'] as int,
        completed: (map['completed'] as int) == 1,
        notes: map['notes'] as String? ?? '',
      );
}

class SessionDatabase {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'pulse_libre_sessions.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time TEXT NOT NULL,
            end_time TEXT,
            duration_seconds INTEGER NOT NULL DEFAULT 0,
            target_duration_seconds INTEGER NOT NULL,
            intensity INTEGER NOT NULL CHECK(intensity BETWEEN 1 AND 9),
            completed INTEGER NOT NULL DEFAULT 0,
            notes TEXT DEFAULT ''
          )
        ''');
      },
    );
  }

  Future<int> insert(SessionRecord record) async {
    final db = await database;
    return db.insert('sessions', record.toMap());
  }

  Future<List<SessionRecord>> recent({int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      orderBy: 'start_time DESC',
      limit: limit,
    );
    return maps.map((m) => SessionRecord.fromMap(m)).toList();
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
