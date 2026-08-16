import 'package:flutter/material.dart';

/// Semantische Farbrollen der App.
///
/// Views greifen ausschließlich auf diese Rollen zu, nie auf Hexwerte (§5.1).
/// Nur so bleibt der Wechsel zwischen hell und dunkel eine Sache von einer
/// Stelle im Code — und nicht von hundert.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.label,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.separator,
    required this.accent,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.chartFillTop,
    required this.chartFillBottom,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color label;
  final Color labelSecondary;
  final Color labelTertiary;
  final Color separator;
  final Color accent;
  final Color positive;
  final Color negative;
  final Color warning;
  final Color chartFillTop;
  final Color chartFillBottom;
  final Color shadow;

  /// Farbe für eine Wertveränderung. Farbe ist nie die alleinige Kodierung —
  /// die UI setzt zusätzlich immer ein Vorzeichen (§5.1, Barrierefreiheit).
  Color forChange(num? change) {
    if (change == null || change == 0) return labelSecondary;
    return change > 0 ? positive : negative;
  }

  static const AppColors light = AppColors(
    background: Color(0xFFF2F2F7),
    surface: Colors.white,
    surfaceElevated: Colors.white,
    label: Color(0xFF000000),
    labelSecondary: Color(0x993C3C43),
    labelTertiary: Color(0x4D3C3C43),
    separator: Color(0x333C3C43),
    accent: Color(0xFF5E5CE6),
    positive: Color(0xFF248A3D),
    negative: Color(0xFFD70015),
    warning: Color(0xFFB25000),
    chartFillTop: Color(0x335E5CE6),
    chartFillBottom: Color(0x005E5CE6),
    shadow: Color(0x14000000),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    surfaceElevated: Color(0xFF2C2C2E),
    label: Color(0xFFFFFFFF),
    labelSecondary: Color(0x99EBEBF5),
    labelTertiary: Color(0x4DEBEBF5),
    separator: Color(0x54545458),
    accent: Color(0xFF7D7AFF),
    positive: Color(0xFF30D158),
    negative: Color(0xFFFF453A),
    warning: Color(0xFFFF9F0A),
    chartFillTop: Color(0x407D7AFF),
    chartFillBottom: Color(0x007D7AFF),
    shadow: Color(0x40000000),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? label,
    Color? labelSecondary,
    Color? labelTertiary,
    Color? separator,
    Color? accent,
    Color? positive,
    Color? negative,
    Color? warning,
    Color? chartFillTop,
    Color? chartFillBottom,
    Color? shadow,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    label: label ?? this.label,
    labelSecondary: labelSecondary ?? this.labelSecondary,
    labelTertiary: labelTertiary ?? this.labelTertiary,
    separator: separator ?? this.separator,
    accent: accent ?? this.accent,
    positive: positive ?? this.positive,
    negative: negative ?? this.negative,
    warning: warning ?? this.warning,
    chartFillTop: chartFillTop ?? this.chartFillTop,
    chartFillBottom: chartFillBottom ?? this.chartFillBottom,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      label: Color.lerp(label, other.label, t)!,
      labelSecondary: Color.lerp(labelSecondary, other.labelSecondary, t)!,
      labelTertiary: Color.lerp(labelTertiary, other.labelTertiary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      chartFillTop: Color.lerp(chartFillTop, other.chartFillTop, t)!,
      chartFillBottom: Color.lerp(chartFillBottom, other.chartFillBottom, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Abstände und Radien. Ein einziges Maßsystem statt verstreuter Zahlen.
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSmall = 10;
  static const double radiusMedium = 16;
  static const double radiusLarge = 22;

  /// Seitenrand der Inhalte.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);
}

/// Erzeugt die Themes für hell und dunkel.
///
/// [fontFamily] bleibt im Betrieb leer, damit jede Plattform ihre Systemschrift
/// verwendet — SF Pro auf Apple-Geräten, Roboto auf Android. Nur Tests setzen
/// den Wert, um eine echte Schrift statt der Test-Platzhalterschrift zu laden.
abstract final class AppTheme {
  static ThemeData light({String? fontFamily}) =>
      _build(Brightness.light, AppColors.light, fontFamily);

  static ThemeData dark({String? fontFamily}) =>
      _build(Brightness.dark, AppColors.dark, fontFamily);

  static ThemeData _build(
    Brightness brightness,
    AppColors colors,
    String? fontFamily,
  ) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: fontFamily,
    );

    // Zahlen erhalten Tabellenziffern, damit Beträge beim Aktualisieren nicht
    // in der Breite springen (§5.1).
    const tabularFigures = [FontFeature.tabularFigures()];

    final textTheme = base.textTheme
        .copyWith(
          displayLarge: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            height: 1.05,
            fontFeatures: tabularFigures,
          ),
          headlineLarge: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
          headlineMedium: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
          titleMedium: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          bodyLarge: const TextStyle(fontSize: 17, letterSpacing: -0.2),
          bodyMedium: const TextStyle(fontSize: 15, letterSpacing: -0.1),
          bodySmall: const TextStyle(fontSize: 13),
          labelSmall: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        )
        .apply(
          bodyColor: colors.label,
          displayColor: colors.label,
          // Bleibt im Betrieb null und lässt damit die Systemschrift stehen.
          fontFamily: fontFamily,
        );

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: colors.accent,
        surface: colors.surface,
        error: colors.negative,
      ),
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: colors.separator,
        thickness: 0.5,
        space: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.label,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium?.copyWith(color: colors.label),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Spacing.radiusLarge),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
          // Nur eine Mindesthöhe vorgeben. `Size.fromHeight` würde die Breite
          // auf unendlich setzen und damit jeden Button innerhalb einer Zeile
          // sprengen — Buttons, die die volle Breite einnehmen sollen, sagen
          // das an ihrer Verwendungsstelle.
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: colors.separator)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusSmall),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMedium),
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
      ),
      extensions: [colors],
    );
  }
}

/// Bequemer Zugriff auf die Farbrollen: `context.colors.accent`.
extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  TextTheme get texts => Theme.of(this).textTheme;
}
