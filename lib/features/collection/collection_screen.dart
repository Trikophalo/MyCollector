import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/services/portfolio_service.dart';
import '../../ui/format/formats.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';
import 'holding_detail_screen.dart';

enum _CollectionFilter {
  all('Alle'),
  cards('Karten'),
  sealed('Versiegelt'),
  graded('Gegradet');

  const _CollectionFilter(this.label);

  final String label;
}

enum _CollectionSort {
  valueDesc('Wert'),
  returnDesc('Rendite'),
  name('Name'),
  purchaseDate('Kaufdatum');

  const _CollectionSort(this.label);

  final String label;
}

/// Tab 2: die vollständige Sammlung mit Suche, Filtern und Sortierung (§5.3).
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  _CollectionFilter _filter = _CollectionFilter.all;
  _CollectionSort _sort = _CollectionSort.valueDesc;
  String _query = '';
  bool _isGrid = false;

  List<PositionValuation> _apply(List<PositionValuation> positions) {
    final query = _query.trim().toLowerCase();

    final filtered = positions.where((position) {
      final matchesFilter = switch (_filter) {
        _CollectionFilter.all => true,
        _CollectionFilter.cards => !position.holding.isSealed,
        _CollectionFilter.sealed => position.holding.isSealed,
        _CollectionFilter.graded => position.holding.isGraded,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return position.displayName.toLowerCase().contains(query) ||
          position.subtitle.toLowerCase().contains(query);
    }).toList();

    filtered.sort(
      (a, b) => switch (_sort) {
        _CollectionSort.valueDesc => b.totalValue.compareTo(a.totalValue),
        _CollectionSort.returnDesc => (b.returnRatio ?? -1).compareTo(
          a.returnRatio ?? -1,
        ),
        _CollectionSort.name => a.displayName.compareTo(b.displayName),
        _CollectionSort.purchaseDate => b.holding.purchaseDate.compareTo(
          a.holding.purchaseDate,
        ),
      },
    );

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final now = DateTime.now();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add'),
        tooltip: 'Position hinzufügen',
        child: const Icon(Icons.add_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Sammlung'),
            actions: [
              IconButton(
                tooltip: _isGrid ? 'Als Liste' : 'Als Raster',
                icon: Icon(
                  _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                ),
                onPressed: () => setState(() => _isGrid = !_isGrid),
              ),
              PopupMenuButton<_CollectionSort>(
                tooltip: 'Sortierung',
                icon: const Icon(Icons.swap_vert_rounded),
                initialValue: _sort,
                onSelected: (value) => setState(() => _sort = value),
                itemBuilder: (context) => [
                  for (final sort in _CollectionSort.values)
                    PopupMenuItem(value: sort, child: Text(sort.label)),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                0,
                Spacing.lg,
                Spacing.md,
              ),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'In der Sammlung suchen',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final filter in _CollectionFilter.values)
                          Padding(
                            padding: const EdgeInsets.only(right: Spacing.sm),
                            child: FilterChip(
                              label: Text(filter.label),
                              selected: _filter == filter,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          portfolio.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Sammlung nicht lesbar',
                message: '$error',
              ),
            ),
            data: (summary) {
              final positions = _apply(summary.positions);

              if (positions.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: summary.isEmpty
                        ? Icons.style_rounded
                        : Icons.search_off_rounded,
                    title: summary.isEmpty
                        ? 'Noch keine Positionen'
                        : 'Keine Treffer',
                    message: summary.isEmpty
                        ? 'Tippe auf das Plus, um deine erste Karte '
                              'hinzuzufügen.'
                        : 'Andere Filter oder Suchbegriffe probieren.',
                  ),
                );
              }

              if (_isGrid) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    0,
                    Spacing.lg,
                    96,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: Spacing.md,
                          mainAxisSpacing: Spacing.md,
                        ),
                    itemCount: positions.length,
                    itemBuilder: (context, index) =>
                        _PositionGridCard(position: positions[index]),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  0,
                  Spacing.lg,
                  96,
                ),
                sliver: SliverList.separated(
                  itemCount: positions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: Spacing.sm),
                  itemBuilder: (context, index) => _PositionTile(
                    position: positions[index],
                    now: now,
                    onDelete: () => _confirmDelete(positions[index]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(PositionValuation position) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Position löschen?'),
        content: Text(
          '„${position.displayName}" wird aus deiner Sammlung entfernt. '
          'Die Wertkurve vergangener Tage bleibt unverändert.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref
          .read(collectionControllerProvider)
          .deleteHolding(position.holding.id);
    }
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({
    required this.position,
    required this.now,
    required this.onDelete,
  });

  final PositionValuation position;
  final DateTime now;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final holding = position.holding;

    return Dismissible(
      key: ValueKey(holding.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Spacing.xl),
        decoration: BoxDecoration(
          color: colors.negative.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Spacing.radiusMedium),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.negative),
      ),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.radiusMedium),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => HoldingDetailScreen(holdingId: holding.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                CatalogThumbnail(item: position.item, width: 44),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              position.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (holding.quantity > 1) ...[
                            const SizedBox(width: Spacing.sm),
                            Text(
                              '×${holding.quantity}',
                              style: context.texts.bodySmall?.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        position.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Row(
                        children: [
                          if (holding.grading != null)
                            GradingBadge(
                              grading: holding.grading!,
                              compact: true,
                            )
                          else
                            Text(
                              holding.variantLabel,
                              style: context.texts.labelSmall?.copyWith(
                                color: colors.labelTertiary,
                              ),
                            ),
                          if (holding.hasManualPrice) ...[
                            const SizedBox(width: Spacing.sm),
                            Icon(
                              Icons.edit_rounded,
                              size: 11,
                              color: colors.labelTertiary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      position.hasValue
                          ? Formats.money(position.totalValue)
                          : '—',
                      style: context.texts.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formats.percentSigned(position.returnRatio),
                      style: context.texts.labelSmall?.copyWith(
                        color: colors.forChange(position.absoluteReturn.cents),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionGridCard extends StatelessWidget {
  const _PositionGridCard({required this.position});

  final PositionValuation position;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(Spacing.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(Spacing.radiusMedium),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HoldingDetailScreen(holdingId: position.holding.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: CatalogThumbnail(
                    item: position.item,
                    width: 92,
                    quality: ImageQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                position.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                position.hasValue ? Formats.money(position.totalValue) : '—',
                style: context.texts.labelSmall?.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
