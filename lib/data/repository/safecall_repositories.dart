import '../../core/models/models.dart';
import '../local/database.dart';

/// Repository for threat events in the local database.
class ThreatEventRepository {
  final SafeCallDatabase _db;

  ThreatEventRepository(this._db);

  Future<void> insertThreatEvent(ThreatEvent event) async {
    final db = await _db.database;
    await db.insert('threat_events', event.toMap()..remove('id'));
  }

  Future<List<ThreatEvent>> getThreatEventsForSession(String sessionId) async {
    final db = await _db.database;
    final maps = await db.query(
      'threat_events',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp DESC',
    );
    return maps.map(ThreatEvent.fromMap).toList();
  }

  Future<List<ThreatEvent>> getAllThreatEvents() async {
    final db = await _db.database;
    final maps = await db.query('threat_events', orderBy: 'timestamp DESC');
    return maps.map(ThreatEvent.fromMap).toList();
  }

  Future<void> deleteOlderThan(int timestampMs) async {
    final db = await _db.database;
    await db.delete(
      'threat_events',
      where: 'timestamp < ?',
      whereArgs: [timestampMs],
    );
  }
}

/// Repository for Stranger Mode sessions.
class SessionRepository {
  final SafeCallDatabase _db;

  SessionRepository(this._db);

  Future<void> startSession(StrangerModeSession session) async {
    final db = await _db.database;
    await db.insert('stranger_mode_sessions', session.toMap());
  }

  Future<void> endSession(String sessionId, String reason) async {
    final db = await _db.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'stranger_mode_sessions',
      {'endTime': now, 'endReason': reason},
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  Future<StrangerModeSession?> getActiveSession() async {
    final db = await _db.database;
    final maps = await db.query(
      'stranger_mode_sessions',
      where: 'endTime IS NULL',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return StrangerModeSession.fromMap(maps.first);
  }

  Future<List<StrangerModeSession>> getAllSessions() async {
    final db = await _db.database;
    final maps =
        await db.query('stranger_mode_sessions', orderBy: 'startTime DESC');
    return maps.map(StrangerModeSession.fromMap).toList();
  }

  Future<void> incrementThreats(String sessionId) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE stranger_mode_sessions SET threatsDetected = threatsDetected + 1 WHERE sessionId = ?',
      [sessionId],
    );
  }

  Future<void> clearHistory() async {
    final db = await _db.database;
    await db.delete('stranger_mode_sessions');
  }
}

/// Repository for blocked notification records.
class BlockedNotificationRepository {
  final SafeCallDatabase _db;

  BlockedNotificationRepository(this._db);

  Future<void> saveBlockedNotification(BlockedNotification notification) async {
    final db = await _db.database;
    await db.insert('blocked_notifications', notification.toMap()..remove('id'));
  }

  Future<int> getBlockedCountForSession(String sessionId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM blocked_notifications WHERE sessionId = ?',
      [sessionId],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<void> deleteOlderThan(int timestampMs) async {
    final db = await _db.database;
    await db.delete(
      'blocked_notifications',
      where: 'timestamp < ?',
      whereArgs: [timestampMs],
    );
  }
}
