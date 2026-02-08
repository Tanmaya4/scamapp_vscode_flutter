import 'package:flutter/material.dart';

/// App color palette based on the SafeCall brand.
class AppColors {
  AppColors._();

  // ── Primary Colors – Trust Blue ───────────────────────────────
  static const Color trustBlue = Color(0xFF1E88E5);
  static const Color trustBlueDark = Color(0xFF1565C0);
  static const Color trustBlueLight = Color(0xFF64B5F6);

  // ── Secondary Colors – Safety Green ───────────────────────────
  static const Color safetyGreen = Color(0xFF43A047);
  static const Color safetyGreenDark = Color(0xFF2E7D32);
  static const Color safetyGreenLight = Color(0xFF81C784);

  // ── Alert Colors ──────────────────────────────────────────────
  static const Color warningRed = Color(0xFFE53935);
  static const Color warningRedDark = Color(0xFFC62828);
  static const Color warningRedLight = Color(0xFFEF5350);

  static const Color alertOrange = Color(0xFFFF9800);
  static const Color alertOrangeDark = Color(0xFFF57C00);
  static const Color alertOrangeLight = Color(0xFFFFB74D);

  // ── Neutral Colors ────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ── Light Theme Colors ────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1C1B1F);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOutline = Color(0xFF79747E);

  // ── Dark Theme Colors ─────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkSurface = Color(0xFF2B2930);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOutline = Color(0xFF938F99);

  // ── Stranger Mode Specific Colors ─────────────────────────────
  static const Color strangerModeActive = Color(0xFF4CAF50);
  static const Color strangerModeWarning = Color(0xFFFFC107);
  static const Color strangerModeDanger = Color(0xFFF44336);
  static const Color strangerModeOverlay = Color(0xCC000000);

  // ── Status Colors ─────────────────────────────────────────────
  static const Color statusSuccess = safetyGreen;
  static const Color statusWarning = alertOrange;
  static const Color statusError = warningRed;
  static const Color statusInfo = trustBlue;
}
