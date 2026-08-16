import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../ui/format/formats.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';

/// Tab 3: Darstellung, Daten, Quellen (§5.3, Screen 5).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final portfolio = ref.watch(portfolioProvider);
    final source = ref.watch(catalogSourceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Einstellungen')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.xxl,
            ),
            sliver: SliverList.list(
              children: [
                SectionCard(
                  title: 'Darstellung',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Erscheinungsbild', style: context.texts.bodyMedium),
                      const SizedBox(height: Spacing.md),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto_rounded, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Hell'),
                            icon: Icon(Icons.light_mode_rounded, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dunkel'),
                            icon: Icon(Icons.dark_mode_rounded, size: 18),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .setThemeMode(value.first);
                          HapticFeedback.selectionClick();
                        },
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        'Voreinstellung folgt dem Gerät.',
                        style: context.texts.bodySmall?.copyWith(
                          color: context.colors.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                SectionCard(
                  title: 'Preise & Aktualisierung',
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.sm,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Zuletzt aktualisiert'),
                        subtitle: Text(
                          settings.lastRefresh == null
                              ? 'Noch nie'
                              : Formats.asOf(
                                  settings.lastRefresh!,
                                  DateTime.now(),
                                ),
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () async {
                            final ok = await ref
                                .read(collectionControllerProvider)
                                .refreshPrices();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Preise aktualisiert.'
                                        : 'Quelle nicht erreichbar — '
                                              'bekannte Preise bleiben.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Jetzt'),
                        ),
                      ),
                      Divider(color: context.colors.separator, height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Datenquelle'),
                        subtitle: Text(source.attribution),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                SectionCard(
                  title: 'Daten',
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.sm,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: const Text('Umfang'),
                        subtitle: Text(
                          portfolio.maybeWhen(
                            data: (s) =>
                                '${s.positions.length} Positionen · '
                                '${Formats.money(s.totalValue)}',
                            orElse: () => '—',
                          ),
                        ),
                      ),
                      Divider(color: context.colors.separator, height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.ios_share_rounded),
                        title: const Text('Sammlung exportieren'),
                        subtitle: const Text('Vollständige Sicherung als JSON'),
                        onTap: () => _export(context, ref),
                      ),
                      Divider(color: context.colors.separator, height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.science_outlined),
                        title: const Text('Beispieldaten laden'),
                        subtitle: const Text(
                          'Füllt die Sammlung mit einem Beispielbestand',
                        ),
                        onTap: () => _loadDemo(context, ref),
                      ),
                      Divider(color: context.colors.separator, height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          color: context.colors.negative,
                        ),
                        title: Text(
                          'Sammlung leeren',
                          style: TextStyle(color: context.colors.negative),
                        ),
                        onTap: () => _clear(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                const _AboutCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final data = await ref.read(collectionControllerProvider).export();
    final json = const JsonEncoder.withIndent('  ').convert(data);

    await Clipboard.setData(ClipboardData(text: json));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sicherung in die Zwischenablage kopiert.'),
        ),
      );
    }
  }

  Future<void> _loadDemo(BuildContext context, WidgetRef ref) async {
    await ref.read(collectionControllerProvider).loadDemoData();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Beispieldaten geladen.')));
    }
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sammlung leeren?'),
        content: const Text(
          'Alle Positionen werden gelöscht. Exportiere vorher, wenn du sie '
          'behalten möchtest.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leeren'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(collectionControllerProvider).clearCollection();
    }
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SectionCard(
      title: 'Über',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MyCollector', style: context.texts.titleMedium),
          const SizedBox(height: Spacing.xs),
          Text(
            'Version 0.1.0 · MVP',
            style: context.texts.bodySmall?.copyWith(
              color: colors.labelSecondary,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Angezeigte Preise sind Referenzwerte aus öffentlichen Quellen, '
            'keine Kaufangebote und keine Anlageberatung. Für gegradete '
            'Karten und versiegelte Produkte ist die Datenlage dünn — '
            'eigene Preise sind dort oft die bessere Referenz.',
            style: context.texts.bodySmall?.copyWith(
              color: colors.labelSecondary,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Inoffizielles Fanprojekt. Pokémon und alle zugehörigen Namen und '
            'Abbildungen sind Marken von Nintendo, Creatures Inc. und '
            'GAME FREAK inc. Keine Verbindung zu The Pokémon Company.',
            style: context.texts.labelSmall?.copyWith(
              color: colors.labelTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
