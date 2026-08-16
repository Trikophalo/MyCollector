import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/money.dart';
import '../../domain/services/chart_series.dart';
import '../../domain/services/portfolio_service.dart';
import '../../ui/format/formats.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/catalog_image.dart';
import '../../ui/widgets/common.dart';
import '../collection/holding_detail_screen.dart';
import 'widgets/portfolio_chart.dart';

/// Startseite: Gesamtwert, Wertverlauf, Kennzahlen und Aufschlüsselung (§5.3).
class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  /// Beim Scrubbing zeigt die Kopfzeile den angetippten Punkt statt des
  /// heutigen Werts.
  SeriesPoint? _scrubbed;
  bool _showInvested = false;

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final series = ref.watch(chartSeriesProvider);
    final range = ref.watch(chartRangeProvider);
    final now = DateTime.now();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final ok = await ref
              .read(collectionControllerProvider)
              .refreshPrices();
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Preise konnten nicht aktualisiert werden — '
                  'zuletzt bekannte Werte bleiben erhalten.',
                ),
              ),
            );
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: const Text('Portfolio'),
              actions: [
                IconButton(
                  tooltip: 'Position hinzufügen',
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _openAddFlow(context),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                0,
                Spacing.lg,
                Spacing.xxl,
              ),
              sliver: portfolio.when(
                loading: () =>
                    const SliverToBoxAdapter(child: _PortfolioSkeleton()),
                error: (error, _) => SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Daten konnten nicht geladen werden',
                    message: '$error',
                  ),
                ),
                data: (summary) => summary.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.style_rounded,
                          title: 'Deine Sammlung ist noch leer',
                          message:
                              'Füge deine erste Karte oder ein versiegeltes '
                              'Produkt hinzu — der Wertverlauf beginnt dann '
                              'ab heute.',
                          action: FilledButton(
                            onPressed: () => _openAddFlow(context),
                            child: const Text('Erste Position hinzufügen'),
                          ),
                        ),
                      )
                    : SliverList.list(
                        children: [
                          _Headline(
                            summary: summary,
                            scrubbed: _scrubbed,
                            series: series.valueOrNull,
                          ),
                          const SizedBox(height: Spacing.lg),
                          PortfolioChart(
                            series:
                                series.valueOrNull ?? ChartSeries.empty(range),
                            showInvested: _showInvested,
                            onScrub: (point) =>
                                setState(() => _scrubbed = point),
                          ),
                          const SizedBox(height: Spacing.md),
                          ChartRangeSelector(
                            selected: range,
                            onChanged: (value) =>
                                ref.read(chartRangeProvider.notifier).state =
                                    value,
                          ),
                          const SizedBox(height: Spacing.sm),
                          _InvestedToggle(
                            value: _showInvested,
                            onChanged: (value) =>
                                setState(() => _showInvested = value),
                          ),
                          const SizedBox(height: Spacing.xl),
                          _KeyFigures(summary: summary),
                          const SizedBox(height: Spacing.xl),
                          _Movers(summary: summary, now: now),
                          const SizedBox(height: Spacing.xl),
                          _Breakdown(summary: summary),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddFlow(BuildContext context) {
    Navigator.of(context).pushNamed('/add');
  }
}

class _Headline extends StatelessWidget {
  const _Headline({
    required this.summary,
    required this.scrubbed,
    required this.series,
  });

  final PortfolioSummary summary;
  final SeriesPoint? scrubbed;
  final ChartSeries? series;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scrubbed = this.scrubbed;

    // Während des Scrubbings zeigt der Kopf den Wert am angetippten Tag und
    // dessen Abstand zum Zeitraumbeginn — wie in Aktien-Apps.
    final value = scrubbed?.value ?? summary.totalValue;
    final Money? change;
    final double? ratio;
    final String caption;

    if (scrubbed != null && series != null && series!.hasLine) {
      change = scrubbed.value - series!.first;
      ratio = Money.changeRatio(series!.first, scrubbed.value);
      caption = Formats.dateWithWeekday(scrubbed.date);
    } else {
      change = summary.dayChange;
      ratio = summary.dayChangeRatio;
      caption = 'heute';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Formats.money(value), style: context.texts.displayLarge),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            ChangePill(change: change, ratio: ratio),
            const SizedBox(width: Spacing.sm),
            Flexible(
              child: Text(
                caption,
                style: context.texts.bodySmall?.copyWith(
                  color: colors.labelSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InvestedToggle extends StatelessWidget {
  const _InvestedToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => onChanged(!value),
        icon: Icon(
          value ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: value ? colors.accent : colors.labelSecondary,
        ),
        label: Text(
          'Einstand einblenden',
          style: context.texts.bodySmall?.copyWith(
            color: value ? colors.accent : colors.labelSecondary,
          ),
        ),
      ),
    );
  }
}

class _KeyFigures extends StatelessWidget {
  const _KeyFigures({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SectionCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Column(
        children: [
          _figure(
            context,
            'Eingesetztes Kapital',
            Formats.money(summary.invested),
            null,
          ),
          Divider(color: colors.separator, height: Spacing.xl),
          _figure(
            context,
            'Gesamtrendite',
            Formats.moneySigned(summary.totalReturn),
            summary.totalReturn.cents,
            trailing: Formats.percentSigned(summary.totalReturnRatio),
          ),
          Divider(color: colors.separator, height: Spacing.xl),
          _figure(
            context,
            'Positionen',
            '${summary.positions.length}',
            null,
            trailing:
                '${summary.positions.fold<int>(0, (sum, p) => sum + p.holding.quantity)} Stück',
          ),
        ],
      ),
    );
  }

  Widget _figure(
    BuildContext context,
    String label,
    String value,
    int? changeSign, {
    String? trailing,
  }) {
    final colors = context.colors;
    final color = changeSign == null
        ? colors.label
        : colors.forChange(changeSign);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.texts.bodyMedium?.copyWith(
              color: colors.labelSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: context.texts.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: Spacing.sm),
          Text(
            trailing,
            style: context.texts.bodySmall?.copyWith(color: color),
          ),
        ],
      ],
    );
  }
}

class _Movers extends StatelessWidget {
  const _Movers({required this.summary, required this.now});

  final PortfolioSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final gainers = summary.topGainers(limit: 3);
    final losers = summary.topLosers(limit: 3);

    if (gainers.isEmpty && losers.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Größte Bewegungen',
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Column(
        children: [
          for (final position in [...gainers, ...losers.reversed])
            _MoverTile(position: position, now: now),
        ],
      ),
    );
  }
}

class _MoverTile extends StatelessWidget {
  const _MoverTile({required this.position, required this.now});

  final PositionValuation position;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      leading: CatalogImage(item: position.item, width: 38),
      title: Text(
        position.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.texts.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        position.holding.variantLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.texts.bodySmall?.copyWith(color: colors.labelSecondary),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formats.money(position.totalValue),
            style: context.texts.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            Formats.percentSigned(position.returnRatio),
            style: context.texts.labelSmall?.copyWith(
              color: colors.forChange(position.absoluteReturn.cents),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HoldingDetailScreen(holdingId: position.holding.id),
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final categories = summary.byCategory();
    final sets = summary.bySet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          title: 'Aufteilung',
          child: Column(
            children: [
              for (final entry in categories) ...[
                _BreakdownBar(entry: entry),
                if (entry != categories.last)
                  const SizedBox(height: Spacing.md),
              ],
            ],
          ),
        ),
        if (sets.isNotEmpty) ...[
          const SizedBox(height: Spacing.xl),
          SectionCard(
            title: 'Nach Set',
            child: Column(
              children: [
                for (final entry in sets) ...[
                  _BreakdownBar(entry: entry),
                  if (entry != sets.last) const SizedBox(height: Spacing.md),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  const _BreakdownBar({required this.entry});

  final BreakdownEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodyMedium,
              ),
            ),
            Text(
              Formats.money(entry.value),
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            SizedBox(
              width: 52,
              child: Text(
                Formats.share(entry.share),
                textAlign: TextAlign.right,
                style: context.texts.bodySmall?.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: entry.share.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: colors.accent.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation(colors.accent),
          ),
        ),
      ],
    );
  }
}

/// Platzhalter beim Erststart — Skelette statt Ladekreisel (§5.6).
class _PortfolioSkeleton extends StatelessWidget {
  const _PortfolioSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bar(220, 44),
        const SizedBox(height: Spacing.md),
        bar(160, 24),
        const SizedBox(height: Spacing.xl),
        bar(double.infinity, 220),
        const SizedBox(height: Spacing.xl),
        bar(double.infinity, 120),
      ],
    );
  }
}
