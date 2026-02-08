import '../../core/constants/enums.dart';
import '../../core/models/models.dart';
import '../../core/models/scam_keywords.dart';

/// Service that handles threat detection using keyword-based detection:
/// - Hindi/English/Hinglish scam phrases
/// - Pattern matching for suspicious speech
/// - 3-tier keyword system (Critical/High Risk/Moderate Risk)
class ThreatDetectionService {
  /// Analyze transcribed text for scam keywords.
  ThreatEvent? analyzeText(String text) {
    final normalizedText = text.toLowerCase().trim();

    // Check Tier 1 (Critical) keywords first
    for (final keyword in ScamKeywords.tier1Keywords) {
      if (normalizedText.contains(keyword.toLowerCase())) {
        return _createThreatEvent(
          detectedPhrase: keyword,
          threatLevel: ThreatLevel.high,
          confidence: 0.95,
          context: text,
        );
      }
    }

    // Check Tier 2 (High Risk) keywords
    for (final keyword in ScamKeywords.tier2Keywords) {
      if (normalizedText.contains(keyword.toLowerCase())) {
        return _createThreatEvent(
          detectedPhrase: keyword,
          threatLevel: ThreatLevel.medium,
          confidence: 0.80,
          context: text,
        );
      }
    }

    // Check Tier 3 (Moderate Risk) keywords
    for (final keyword in ScamKeywords.tier3Keywords) {
      if (normalizedText.contains(keyword.toLowerCase())) {
        return _createThreatEvent(
          detectedPhrase: keyword,
          threatLevel: ThreatLevel.low,
          confidence: 0.60,
          context: text,
        );
      }
    }

    // Check for scam phrase patterns
    return _checkScamPatterns(normalizedText);
  }

  /// Check for common scam phrase patterns.
  ThreatEvent? _checkScamPatterns(String text) {
    final scamPatterns = [
      // Urgency patterns
      RegExp(r'(abhi|turant|jaldi).*(karo|kariye|kar do)',
          caseSensitive: false),
      RegExp(r'(immediately|urgent|now).*(send|transfer|give)',
          caseSensitive: false),

      // Authority impersonation
      RegExp(r'(bank|police|court|rbi).*(officer|manager|inspector)',
          caseSensitive: false),
      RegExp(r'(main|mai|hum).*(bank|police|cbi|rbi|income tax)',
          caseSensitive: false),

      // Threat patterns
      RegExp(r'(arrest|jail|legal|case).*(against|pe|par)',
          caseSensitive: false),
      RegExp(r'(account|card|service).*(block|suspend|freeze)',
          caseSensitive: false),

      // OTP/PIN request
      RegExp(r'(otp|pin|password|cvv).*(batao|bata do|tell|share|send)',
          caseSensitive: false),
      RegExp(r'(share|send|bata).*(otp|pin|password|cvv)',
          caseSensitive: false),

      // Money transfer patterns
      RegExp(r'(paisa|rupee|money|amount).*(transfer|bhejo|send)',
          caseSensitive: false),
      RegExp(r'(google pay|phonepe|paytm|upi).*(karo|kariye|kar do)',
          caseSensitive: false),

      // Lottery/prize scams
      RegExp(r'(lottery|prize|winner|jackpot).*(won|jeet|mila)',
          caseSensitive: false),
      RegExp(r'(lakh|crore|million).*(won|jeet|prize)',
          caseSensitive: false),

      // Job scams
      RegExp(r'(job|work|earning).*(guarantee|pakka|sure)',
          caseSensitive: false),
      RegExp(r'(registration|joining).*(fee|fees|charge)',
          caseSensitive: false),
    ];

    for (final pattern in scamPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return _createThreatEvent(
          detectedPhrase: match.group(0) ?? '',
          threatLevel: ThreatLevel.medium,
          confidence: 0.75,
          context: text,
        );
      }
    }
    return null;
  }

  ThreatEvent _createThreatEvent({
    required String detectedPhrase,
    required ThreatLevel threatLevel,
    required double confidence,
    required String context,
  }) {
    final suggestedAction = switch (threatLevel) {
      ThreatLevel.high || ThreatLevel.critical => ThreatAction.autoDisconnect,
      ThreatLevel.medium => ThreatAction.alertAndMute,
      _ => ThreatAction.muteOnly,
    };

    return ThreatEvent(
      type: ThreatType.keyword,
      level: threatLevel,
      detectedContent: detectedPhrase,
      confidence: confidence,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sessionId: '', // Will be set by the caller
      actionTaken: suggestedAction,
    );
  }
}
