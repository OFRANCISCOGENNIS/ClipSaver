/// Design tokens (section 6.1).
///
/// Responsibility: be the single source of colors, spacing, radii and type
/// scale. Widgets never hardcode a hex value or a magic number — that is
/// what keeps dark and light mode consistent and the 4px grid honest.
library;

import 'package:flutter/widgets.dart';

/// Brand and semantic colors.
abstract final class VidoraColors {
  /// Start of the primary gradient (violet).
  static const Color primaryStart = Color(0xFF7C3AED);

  /// End of the primary gradient (blue).
  static const Color primaryEnd = Color(0xFF2563EB);

  /// Primary gradient, used sparingly on CTAs and progress (section 6.1).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark theme background.
  static const Color darkBackground = Color(0xFF0B0D12);

  /// Dark theme elevated surface.
  static const Color darkSurface = Color(0xFF151823);

  /// Dark theme primary text.
  static const Color darkText = Color(0xFFE7E9EE);

  /// Light theme background.
  static const Color lightBackground = Color(0xFFF8F9FC);

  /// Light theme elevated surface.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light theme primary text.
  static const Color lightText = Color(0xFF14161C);

  /// Success (completed downloads, verified integrity).
  static const Color success = Color(0xFF22C55E);

  /// Error (failed downloads, ineligible content).
  static const Color error = Color(0xFFEF4444);

  /// Warning (license restrictions, quota limits).
  static const Color warning = Color(0xFFF59E0B);
}

/// The 4px spacing grid (section 6.1).
abstract final class VidoraSpacing {
  /// 4px.
  static const double xs = 4;

  /// 8px.
  static const double sm = 8;

  /// 12px.
  static const double md = 12;

  /// 16px.
  static const double lg = 16;

  /// 24px.
  static const double xl = 24;

  /// 32px.
  static const double xxl = 32;
}

/// Corner radii (section 6.1): 12 for cards, 24 for sheets.
abstract final class VidoraRadius {
  /// Cards and inputs.
  static const Radius card = Radius.circular(12);

  /// Bottom sheets and dialogs.
  static const Radius sheet = Radius.circular(24);

  /// Pills and chips.
  static const Radius pill = Radius.circular(999);
}

/// Motion durations and curves (section 6.2).
abstract final class VidoraMotion {
  /// Fast micro-interactions.
  static const Duration fast = Duration(milliseconds: 200);

  /// Standard transitions.
  static const Duration standard = Duration(milliseconds: 300);

  /// Slower, larger surface changes.
  static const Duration slow = Duration(milliseconds: 350);

  /// Entrances.
  static const Curve enter = Curves.easeOutCubic;

  /// Transitions between states.
  static const Curve transition = Curves.easeInOutCubic;
}

/// Minimum interactive size (section 6.3): 48×48dp.
const double kMinTouchTarget = 48;
