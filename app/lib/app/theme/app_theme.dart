/// Material themes built from the design tokens (section 6).
///
/// Responsibility: translate the token set into a [ThemeData] for each
/// brightness, so every screen inherits the palette, type scale, radii and
/// the 48dp minimum touch target without repeating itself.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Font families. Assets ship with the release builds (phase 6); until
/// then Flutter falls back to the platform font, which keeps the type
/// scale and weights intact.
const String _uiFont = 'Inter';

/// Monospaced face for technical data — speeds, sizes, hashes
/// (section 6.1).
const String kMonoFont = 'JetBrainsMono';

/// Builds the app theme for [brightness].
ThemeData buildVidoraTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final background =
      isDark ? VidoraColors.darkBackground : VidoraColors.lightBackground;
  final surface = isDark ? VidoraColors.darkSurface : VidoraColors.lightSurface;
  final onSurface = isDark ? VidoraColors.darkText : VidoraColors.lightText;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: VidoraColors.primaryStart,
    onPrimary: Colors.white,
    secondary: VidoraColors.primaryEnd,
    onSecondary: Colors.white,
    error: VidoraColors.error,
    onError: Colors.white,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerLowest: background,
    // Secondary text at ~70% keeps contrast above the 4.5:1 floor on both
    // backgrounds (section 6.3).
    onSurfaceVariant: onSurface.withValues(alpha: 0.70),
    outline: onSurface.withValues(alpha: 0.16),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    fontFamily: _uiFont,
    textTheme: _textTheme(onSurface),
    // Section 6.3: every interactive target is at least 48×48dp.
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _textTheme(onSurface).titleLarge,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(VidoraRadius.card),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: VidoraSpacing.lg,
        vertical: VidoraSpacing.lg,
      ),
      border: _inputBorder(scheme.outline),
      enabledBorder: _inputBorder(scheme.outline),
      focusedBorder: _inputBorder(scheme.primary, width: 2),
      errorBorder: _inputBorder(scheme.error),
      focusedErrorBorder: _inputBorder(scheme.error, width: 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, kMinTouchTarget),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(VidoraRadius.card),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      side: BorderSide(color: scheme.outline),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(VidoraRadius.pill),
      ),
      labelStyle: TextStyle(fontSize: 12, color: onSurface),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: VidoraRadius.sheet),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outline, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearMinHeight: 6,
    ),
  );
}

OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: const BorderRadius.all(VidoraRadius.card),
      borderSide: BorderSide(color: color, width: width),
    );

/// Type scale from section 6.1: 12/14/16/20/24/32.
TextTheme _textTheme(Color onSurface) => TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: onSurface),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: onSurface),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: onSurface.withValues(alpha: 0.70),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    );

/// Style for technical readouts (speed, size, ETA) — section 6.1.
TextStyle monoStyle(BuildContext context, {double fontSize = 12}) => TextStyle(
      fontFamily: kMonoFont,
      fontSize: fontSize,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
