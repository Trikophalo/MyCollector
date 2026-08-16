import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/money.dart';
import '../../../domain/services/chart_series.dart';
import '../../../ui/theme/app_theme.dart';

/// Der Wertverlaufs-Chart im Stil einer Aktien-App (§5.4).
///
/// Bewusst als eigener [CustomPainter] statt über eine Diagrammbibliothek:
/// Scrubbing mit Fadenkreuz, die Referenzlinie am Zeitraumbeginn, das Morphing
/// beim Zeitraumwechsel und die Einstandslinie sind genau die Details, die den
/// Eindruck einer Börsen-App ausmachen — und genau die, bei denen fertige
/// Bibliotheken Kompromisse erzwingen.
class PortfolioChart extends StatefulWidget {
  const PortfolioChart({
    required this.series,
    this.onScrub,
    this.showInvested = false,
    this.height = 220,
    super.key,
  });

  final ChartSeries series;

  /// Meldet den angetippten Punkt; `null` beim Loslassen.
  final ValueChanged<SeriesPoint?>? onScrub;

  /// Blendet die Linie des eingesetzten Kapitals ein.
  final bool showInvested;

  final double height;

  @override
  State<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  int? _activeIndex;

  @override
  void didUpdateWidget(covariant PortfolioChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Zeitraumwechsel: Die Kurve wächst neu ein, statt hart umzuspringen.
    if (oldWidget.series.range != widget.series.range ||
        oldWidget.series.points.length != widget.series.points.length) {
      _activeIndex = null;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateScrub(Offset localPosition, double width) {
    final points = widget.series.points;
    if (points.length < 2) return;

    final ratio = (localPosition.dx / width).clamp(0.0, 1.0);
    final index = (ratio * (points.length - 1)).round();

    if (index != _activeIndex) {
      setState(() => _activeIndex = index);
      // Feiner Impuls je Datenpunkt — dieselbe Rückmeldung wie in Aktien-Apps.
      HapticFeedback.selectionClick();
      widget.onScrub?.call(points[index]);
    }
  }

  void _endScrub() {
    if (_activeIndex == null) return;
    setState(() => _activeIndex = null);
    widget.onScrub?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final series = widget.series;

    if (!series.hasLine) {
      return _ChartPlaceholder(height: widget.height, series: series);
    }

    final lineColor = series.isUp
        ? colors.positive
        : series.isDown
        ? colors.negative
        : colors.accent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return MouseRegion(
          // Auf dem Desktop ersetzt Zeigen das Gedrückthalten (§5.5).
          onHover: (event) => _updateScrub(event.localPosition, width),
          onExit: (_) => _endScrub(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPressStart: (d) => _updateScrub(d.localPosition, width),
            onLongPressMoveUpdate: (d) => _updateScrub(d.localPosition, width),
            onLongPressEnd: (_) => _endScrub(),
            onLongPressCancel: _endScrub,
            onHorizontalDragStart: (d) => _updateScrub(d.localPosition, width),
            onHorizontalDragUpdate: (d) => _updateScrub(d.localPosition, width),
            onHorizontalDragEnd: (_) => _endScrub(),
            onHorizontalDragCancel: _endScrub,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                size: Size(width, widget.height),
                painter: _ChartPainter(
                  series: series,
                  lineColor: lineColor,
                  fillTop: series.isDown
                      ? colors.negative.withValues(alpha: 0.22)
                      : colors.chartFillTop,
                  fillBottom: colors.chartFillBottom,
                  baselineColor: colors.labelTertiary,
                  crosshairColor: colors.label,
                  investedColor: colors.labelSecondary,
                  showInvested: widget.showInvested,
                  activeIndex: _activeIndex,
                  progress: Curves.easeOutCubic.transform(_controller.value),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.series,
    required this.lineColor,
    required this.fillTop,
    required this.fillBottom,
    required this.baselineColor,
    required this.crosshairColor,
    required this.investedColor,
    required this.showInvested,
    required this.activeIndex,
    required this.progress,
  });

  final ChartSeries series;
  final Color lineColor;
  final Color fillTop;
  final Color fillBottom;
  final Color baselineColor;
  final Color crosshairColor;
  final Color investedColor;
  final bool showInvested;
  final int? activeIndex;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final points = series.points;
    if (points.length < 2) return;

    // Wertebereich mit etwas Luft, damit die Kurve die Ränder nicht berührt.
    var minCents = series.minValue.cents.toDouble();
    var maxCents = series.maxValue.cents.toDouble();

    if (showInvested) {
      for (final point in points) {
        minCents = math.min(minCents, point.invested.cents.toDouble());
        maxCents = math.max(maxCents, point.invested.cents.toDouble());
      }
    }

    final span = math.max(maxCents - minCents, 1);
    final padding = span * 0.12;
    minCents -= padding;
    maxCents += padding;

    double xFor(int index) => size.width * index / (points.length - 1);

    double yFor(double cents) {
      final ratio = (cents - minCents) / (maxCents - minCents);
      return size.height * (1 - ratio.clamp(0.0, 1.0));
    }

    // Beim Einwachsen bewegen sich die Punkte aus der Mittellinie heraus.
    final neutral = (minCents + maxCents) / 2;
    double animatedY(double cents) =>
        yFor(ui.lerpDouble(neutral, cents, progress)!);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = xFor(i);
      final y = animatedY(points[i].value.cents.toDouble());
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillTop, fillBottom],
        ).createShader(Offset.zero & size),
    );

    _drawDashedLine(
      canvas,
      Offset(0, animatedY(points.first.value.cents.toDouble())),
      Offset(size.width, animatedY(points.first.value.cents.toDouble())),
      baselineColor,
    );

    if (showInvested) {
      final investedPath = Path();
      for (var i = 0; i < points.length; i++) {
        final x = xFor(i);
        final y = animatedY(points[i].invested.cents.toDouble());
        i == 0 ? investedPath.moveTo(x, y) : investedPath.lineTo(x, y);
      }
      canvas.drawPath(
        investedPath,
        Paint()
          ..color = investedColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final index = activeIndex;
    if (index != null && index < points.length) {
      final x = xFor(index);
      final y = animatedY(points[index].value.cents.toDouble());

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = crosshairColor.withValues(alpha: 0.25)
          ..strokeWidth = 1,
      );
      canvas
        ..drawCircle(
          Offset(x, y),
          7,
          Paint()..color = lineColor.withValues(alpha: 0.22),
        )
        ..drawCircle(Offset(x, y), 4.5, Paint()..color = lineColor)
        ..drawCircle(Offset(x, y), 2, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;

    var x = from.dx;
    while (x < to.dx) {
      canvas.drawLine(
        Offset(x, from.dy),
        Offset(math.min(x + dash, to.dx), to.dy),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.series != series ||
      old.activeIndex != activeIndex ||
      old.progress != progress ||
      old.showInvested != showInvested ||
      old.lineColor != lineColor;
}

/// Leerzustand: Solange zu wenige Tagesabschlüsse vorliegen, erklärt der Chart
/// ehrlich, dass die Kurve erst entsteht (§4.5, Backfill-Problem).
class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.height, required this.series});

  final double height;
  final ChartSeries series;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(double.infinity, height),
            painter: _PlaceholderPainter(color: colors.labelTertiary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            margin: Spacing.page,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(Spacing.radiusMedium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.show_chart_rounded, color: colors.labelSecondary),
                const SizedBox(height: Spacing.sm),
                Text(
                  series.isEmpty
                      ? 'Deine Wertkurve entsteht ab jetzt'
                      : 'Noch zu wenige Datenpunkte',
                  style: context.texts.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Jeden Tag kommt ein Punkt hinzu.',
                  style: context.texts.bodySmall?.copyWith(
                    color: colors.labelSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPainter extends CustomPainter {
  const _PlaceholderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const steps = 40;
    for (var i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y =
          size.height * (0.55 + math.sin(i / steps * math.pi * 2.2) * 0.16);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PlaceholderPainter old) => old.color != color;
}

/// Zeitraumauswahl unter dem Chart.
class ChartRangeSelector extends StatelessWidget {
  const ChartRangeSelector({
    required this.selected,
    required this.onChanged,
    this.enabledRanges,
    super.key,
  });

  final ChartRange selected;
  final ValueChanged<ChartRange> onChanged;

  /// Zeiträume ohne ausreichende Historie werden ausgegraut statt versteckt —
  /// so bleibt sichtbar, dass sie später verfügbar sind (§5.4).
  final Set<ChartRange>? enabledRanges;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(Spacing.radiusSmall),
      ),
      child: Row(
        children: [
          for (final range in ChartRange.values)
            Expanded(
              child: _RangeChip(
                range: range,
                isSelected: range == selected,
                isEnabled: enabledRanges?.contains(range) ?? true,
                onTap: () => onChanged(range),
              ),
            ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.range,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final ChartRange range;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Zeitraum ${range.label}',
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(Spacing.radiusSmall - 3),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            range.label,
            textAlign: TextAlign.center,
            style: context.texts.bodySmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isEnabled
                  ? (isSelected ? colors.label : colors.labelSecondary)
                  : colors.labelTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kleine Hilfsklasse für die Kopfzeile über dem Chart.
class ChartHeadline {
  const ChartHeadline({
    required this.value,
    required this.change,
    required this.ratio,
    required this.caption,
  });

  final Money value;
  final Money change;
  final double? ratio;
  final String caption;
}
