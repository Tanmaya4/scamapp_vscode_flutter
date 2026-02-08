/// Scam keywords in different tiers for threat detection.
class ScamKeywords {
  ScamKeywords._();

  /// Tier 1 – High priority keywords (immediate action)
  static const List<String> tier1Keywords = [
    // English
    'otp', 'one time password', 'verification code', 'verify code',
    'pin', 'cvv', 'password', 'passcode',
    'last four', 'last 4', 'color code', 'colour code',
    'security code', 'auth code', 'authentication',
    // Hindi
    'otp batao', 'otp do', 'code batao', 'code bolo',
    'aakhri chaar', 'last chaar', 'char ank', 'char number',
    'rang code', 'color batao', 'verify karo', 'verification batao',
  ];

  /// Tier 2 – Medium priority keywords (context-dependent)
  static const List<String> tier2Keywords = [
    // English
    'tell me', 'say it', 'read it', 'what is the',
    'bank', 'account', 'upi', 'paytm', 'gpay', 'phonepe',
    'transfer', 'send money', 'payment', 'transaction',
    'confirm', 'verify', 'authenticate',
    // Hindi
    'batao', 'bolo', 'padhao', 'kya hai',
    'bank account', 'paisa bhejo', 'payment karo',
    'confirm karo', 'verify karo',
  ];

  /// Tier 3 – Low priority keywords (accumulation-based)
  static const List<String> tier3Keywords = [
    // English
    'quick', 'urgent', 'hurry', 'fast', 'immediately',
    'trust me', 'believe me', "don't tell",
    'secret', 'private', 'confidential',
    // Hindi
    'jaldi', 'urgent hai', 'abhi karo',
    'vishwas karo', 'believe karo', 'kisi ko mat batana',
    'secret hai', 'private hai',
  ];

  /// All keywords combined
  static List<String> get allKeywords =>
      [...tier1Keywords, ...tier2Keywords, ...tier3Keywords];

  /// Get keyword priority tier (3 = critical, 2 = high, 1 = moderate, 0 = none)
  static int getKeywordPriority(String keyword) {
    final lower = keyword.toLowerCase();
    if (tier1Keywords.any((k) => lower.contains(k))) return 3;
    if (tier2Keywords.any((k) => lower.contains(k))) return 2;
    if (tier3Keywords.any((k) => lower.contains(k))) return 1;
    return 0;
  }
}

/// OTP patterns for detecting OTP-like content in notifications/text.
class OtpPatterns {
  OtpPatterns._();

  static final List<RegExp> patterns = [
    RegExp(r'\b\d{4,8}\b'), // 4–8 digit numbers
    RegExp(r'(otp|one.?time|verification|security|auth).{0,20}code',
        caseSensitive: false),
    RegExp(r'(code|password|pin).{0,20}(is|:)\s*\d+', caseSensitive: false),
    RegExp(r'do\s*not\s*share', caseSensitive: false),
    RegExp(
        r'(valid|expire|validity).{0,10}(for|in).{0,10}\d+\s*(min|minute|sec|second|hr|hour)',
        caseSensitive: false),
  ];

  static bool containsOtp(String text) {
    return patterns.any((p) => p.hasMatch(text));
  }
}

/// Package names that may contain OTP notifications (Android).
class OtpPackages {
  OtpPackages._();

  static const Set<String> blockedPackages = {
    'com.android.messaging',
    'com.google.android.apps.messaging',
    'com.samsung.android.messaging',
    'com.whatsapp',
    'com.whatsapp.w4b',
    'com.google.android.gm',
    'org.telegram.messenger',
    'com.phonepe.app',
    'com.google.android.apps.nbu.paisa.user',
    'net.one97.paytm',
    'in.org.npci.upiapp',
    'com.csam.icici.bank.imobile',
    'com.sbi.SBIFreedomPlus',
    'com.axis.mobile',
    'com.hdfc.hdfc_bank',
  };
}
