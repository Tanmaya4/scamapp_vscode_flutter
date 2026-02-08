import 'package:equatable/equatable.dart';
import '../constants/enums.dart';

/// Domain model for a threat event.
class ThreatEvent extends Equatable {
  final int id;
  final ThreatType type;
  final ThreatLevel level;
  final String detectedContent;
  final double confidence;
  final int timestamp;
  final String sessionId;
  final ThreatAction actionTaken;
  final String? phoneNumber;

  const ThreatEvent({
    this.id = 0,
    required this.type,
    required this.level,
    required this.detectedContent,
    required this.confidence,
    required this.timestamp,
    required this.sessionId,
    required this.actionTaken,
    this.phoneNumber,
  });

  ThreatEvent copyWith({
    int? id,
    ThreatType? type,
    ThreatLevel? level,
    String? detectedContent,
    double? confidence,
    int? timestamp,
    String? sessionId,
    ThreatAction? actionTaken,
    String? phoneNumber,
  }) {
    return ThreatEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      level: level ?? this.level,
      detectedContent: detectedContent ?? this.detectedContent,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      actionTaken: actionTaken ?? this.actionTaken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'level': level.name,
        'detectedContent': detectedContent,
        'confidence': confidence,
        'timestamp': timestamp,
        'sessionId': sessionId,
        'actionTaken': actionTaken.name,
        'phoneNumber': phoneNumber,
      };

  factory ThreatEvent.fromMap(Map<String, dynamic> map) => ThreatEvent(
        id: map['id'] as int,
        type: ThreatType.values.byName(map['type'] as String),
        level: ThreatLevel.values.byName(map['level'] as String),
        detectedContent: map['detectedContent'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        timestamp: map['timestamp'] as int,
        sessionId: map['sessionId'] as String,
        actionTaken: ThreatAction.values.byName(map['actionTaken'] as String),
        phoneNumber: map['phoneNumber'] as String?,
      );

  @override
  List<Object?> get props => [
        id,
        type,
        level,
        detectedContent,
        confidence,
        timestamp,
        sessionId,
        actionTaken,
        phoneNumber,
      ];
}

/// Domain model for a Stranger Mode session.
class StrangerModeSession extends Equatable {
  final String sessionId;
  final int startTime;
  final int? endTime;
  final int plannedDurationMs;
  final int? actualDurationMs;
  final int threatsDetected;
  final bool wasCallEnded;
  final SessionEndReason? endReason;

  const StrangerModeSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.plannedDurationMs,
    this.actualDurationMs,
    this.threatsDetected = 0,
    this.wasCallEnded = false,
    this.endReason,
  });

  bool get isActive => endTime == null;

  int get remainingTimeMs {
    if (!isActive) return 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
    final remaining = plannedDurationMs - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  StrangerModeSession copyWith({
    String? sessionId,
    int? startTime,
    int? endTime,
    int? plannedDurationMs,
    int? actualDurationMs,
    int? threatsDetected,
    bool? wasCallEnded,
    SessionEndReason? endReason,
  }) {
    return StrangerModeSession(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationMs: plannedDurationMs ?? this.plannedDurationMs,
      actualDurationMs: actualDurationMs ?? this.actualDurationMs,
      threatsDetected: threatsDetected ?? this.threatsDetected,
      wasCallEnded: wasCallEnded ?? this.wasCallEnded,
      endReason: endReason ?? this.endReason,
    );
  }

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'startTime': startTime,
        'endTime': endTime,
        'plannedDurationMs': plannedDurationMs,
        'actualDurationMs': actualDurationMs,
        'threatsDetected': threatsDetected,
        'wasCallEnded': wasCallEnded ? 1 : 0,
        'endReason': endReason?.name,
      };

  factory StrangerModeSession.fromMap(Map<String, dynamic> map) =>
      StrangerModeSession(
        sessionId: map['sessionId'] as String,
        startTime: map['startTime'] as int,
        endTime: map['endTime'] as int?,
        plannedDurationMs: map['plannedDurationMs'] as int,
        actualDurationMs: map['actualDurationMs'] as int?,
        threatsDetected: map['threatsDetected'] as int? ?? 0,
        wasCallEnded: (map['wasCallEnded'] as int? ?? 0) == 1,
        endReason: map['endReason'] != null
            ? SessionEndReason.values.byName(map['endReason'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        sessionId,
        startTime,
        endTime,
        plannedDurationMs,
        actualDurationMs,
        threatsDetected,
        wasCallEnded,
        endReason,
      ];
}

/// Blocked notification record.
class BlockedNotification extends Equatable {
  final int id;
  final String packageName;
  final int timestamp;
  final String sessionId;

  const BlockedNotification({
    this.id = 0,
    required this.packageName,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'packageName': packageName,
        'timestamp': timestamp,
        'sessionId': sessionId,
      };

  factory BlockedNotification.fromMap(Map<String, dynamic> map) =>
      BlockedNotification(
        id: map['id'] as int,
        packageName: map['packageName'] as String,
        timestamp: map['timestamp'] as int,
        sessionId: map['sessionId'] as String,
      );

  @override
  List<Object?> get props => [id, packageName, timestamp, sessionId];
}

/// State representing the current Stranger Mode status.
class StrangerModeStatus extends Equatable {
  final StrangerModeState state;
  final StrangerModeSession? currentSession;
  final ThreatEvent? activeThreat;
  final List<ThreatEvent> threatsInSession;
  final int blockedNotificationCount;

  const StrangerModeStatus({
    this.state = StrangerModeState.inactive,
    this.currentSession,
    this.activeThreat,
    this.threatsInSession = const [],
    this.blockedNotificationCount = 0,
  });

  bool get isActive =>
      state == StrangerModeState.active ||
      state == StrangerModeState.threatDetected;

  bool get hasThreat => activeThreat != null;

  StrangerModeStatus copyWith({
    StrangerModeState? state,
    StrangerModeSession? currentSession,
    ThreatEvent? activeThreat,
    List<ThreatEvent>? threatsInSession,
    int? blockedNotificationCount,
  }) {
    return StrangerModeStatus(
      state: state ?? this.state,
      currentSession: currentSession ?? this.currentSession,
      activeThreat: activeThreat ?? this.activeThreat,
      threatsInSession: threatsInSession ?? this.threatsInSession,
      blockedNotificationCount:
          blockedNotificationCount ?? this.blockedNotificationCount,
    );
  }

  @override
  List<Object?> get props => [
        state,
        currentSession,
        activeThreat,
        threatsInSession,
        blockedNotificationCount,
      ];
}

/// User settings model.
class UserSettings extends Equatable {
  final bool onboardingCompleted;
  final int defaultDurationMinutes;
  final ThreatAction threatAction;
  final bool autoModeEnabled;
  final bool hapticFeedbackEnabled;
  final bool autoReportEnabled;
  final String language;

  const UserSettings({
    this.onboardingCompleted = false,
    this.defaultDurationMinutes = 15,
    this.threatAction = ThreatAction.alertAndMute,
    this.autoModeEnabled = false,
    this.hapticFeedbackEnabled = true,
    this.autoReportEnabled = false,
    this.language = 'en',
  });

  UserSettings copyWith({
    bool? onboardingCompleted,
    int? defaultDurationMinutes,
    ThreatAction? threatAction,
    bool? autoModeEnabled,
    bool? hapticFeedbackEnabled,
    bool? autoReportEnabled,
    String? language,
  }) {
    return UserSettings(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      threatAction: threatAction ?? this.threatAction,
      autoModeEnabled: autoModeEnabled ?? this.autoModeEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      autoReportEnabled: autoReportEnabled ?? this.autoReportEnabled,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        onboardingCompleted,
        defaultDurationMinutes,
        threatAction,
        autoModeEnabled,
        hapticFeedbackEnabled,
        autoReportEnabled,
        language,
      ];
}
