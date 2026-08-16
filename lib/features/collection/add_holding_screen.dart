import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/remote/catalog_source.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/grading.dart';
import '../../domain/models/holding.dart';
import '../../domain/models/money.dart';
import '../../domain/models/price_point.dart';
import '../../ui/format/formats.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/catalog_image.dart';
import '../../ui/widgets/common.dart';

/// Zweistufiger Ablauf zum Hinzufügen einer Position (§5.3, Screen 3).
///
/// Schritt 1 sucht das Objekt, Schritt 2 beschreibt den eigenen Bestand.
/// Die Trennung hält den ersten Schritt schnell — der häufigste Fall ist
/// „Karte gekauft, schnell eintragen".
class AddHoldingScreen extends ConsumerStatefulWidget {
  const AddHoldingScreen({super.key});

  @override
  ConsumerState<AddHoldingScreen> createState() => _AddHoldingScreenState();
}

class _AddHoldingScreenState extends ConsumerState<AddHoldingScreen> {
  CatalogItem? _selected;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(
        title: Text(selected == null ? 'Was hast du?' : 'Details'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (selected != null) {
              setState(() => _selected = null);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: selected == null
          ? _SearchStep(onSelected: (item) => setState(() => _selected = item))
          : _ConfigureStep(
              item: selected,
              onSaved: () => Navigator.of(context).pop(),
            ),
    );
  }
}

// ------------------------------------------------------------------ Schritt 1

class _SearchStep extends ConsumerStatefulWidget {
  const _SearchStep({required this.onSelected});

  final ValueChanged<CatalogItem> onSelected;

  @override
  ConsumerState<_SearchStep> createState() => _SearchStepState();
}

class _SearchStepState extends ConsumerState<_SearchStep> {
  bool _searchingSealed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Karten'),
                    icon: Icon(Icons.style_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Versiegelt'),
                    icon: Icon(Icons.inventory_2_rounded, size: 18),
                  ),
                ],
                selected: {_searchingSealed},
                onSelectionChanged: (value) =>
                    setState(() => _searchingSealed = value.first),
              ),
              const SizedBox(height: Spacing.lg),
              TextField(
                autofocus: true,
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: _searchingSealed
                      ? 'Produktname, z. B. „151 Display"'
                      : 'Kartenname, z. B. „Glurak"',
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _searchingSealed
              ? _SealedOptions(query: query, onSelected: widget.onSelected)
              : results.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => EmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'Suche nicht möglich',
                    message: error is CatalogSourceException
                        ? error.message
                        : 'Der Katalog ist gerade nicht erreichbar.',
                  ),
                  data: (cards) {
                    if (query.trim().length < 2) {
                      return EmptyState(
                        icon: Icons.search_rounded,
                        title: 'Karte suchen',
                        message:
                            'Mindestens zwei Buchstaben eingeben. '
                            'Deutsche und englische Namen funktionieren beide.',
                      );
                    }
                    if (cards.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Nichts gefunden',
                        message:
                            'Andere Schreibweise probieren — oder die '
                            'Karte über den englischen Namen suchen.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        0,
                        Spacing.lg,
                        Spacing.xxl,
                      ),
                      itemCount: cards.length,
                      separatorBuilder: (_, _) =>
                          Divider(color: colors.separator, height: 1),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CatalogImage(item: card, width: 42),
                          title: Text(card.fullLabel),
                          subtitle: Text(card.subtitle),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.labelTertiary,
                          ),
                          onTap: () => widget.onSelected(card),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Versiegelte Produkte werden im MVP frei angelegt.
///
/// Das ist keine Notlösung, sondern folgt aus der Datenlage: Es gibt derzeit
/// keine verlässliche EUR-Preisquelle für Sealed (§3.5). Lieber ehrlich
/// manuell als eine Automatik, die falsche Werte liefert.
class _SealedOptions extends StatelessWidget {
  const _SealedOptions({required this.query, required this.onSelected});

  final String query;
  final ValueChanged<CatalogItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = query.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.xxl,
      ),
      children: [
        Text(
          'Produkttyp wählen',
          style: context.texts.titleMedium?.copyWith(
            color: colors.labelSecondary,
          ),
        ),
        const SizedBox(height: Spacing.md),
        for (final type in SealedProductType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusMedium),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusMedium),
                ),
                leading: Icon(Icons.inventory_2_outlined, color: colors.accent),
                title: Text(name.isEmpty ? type.label : name),
                subtitle: Text(type.label),
                onTap: name.isEmpty
                    ? null
                    : () => onSelected(
                        SealedProduct(
                          id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
                          name: name,
                          type: type,
                          isCustom: true,
                        ),
                      ),
              ),
            ),
          ),
        if (name.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.md),
            child: Text(
              'Gib oben den Produktnamen ein, dann wähle den Typ.',
              style: context.texts.bodySmall?.copyWith(
                color: colors.labelSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------ Schritt 2

class _ConfigureStep extends ConsumerStatefulWidget {
  const _ConfigureStep({required this.item, required this.onSaved});

  final CatalogItem item;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ConfigureStep> createState() => _ConfigureStepState();
}

class _ConfigureStepState extends ConsumerState<_ConfigureStep> {
  final _purchaseController = TextEditingController();
  final _manualPriceController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isGraded = false;
  Grader _grader = Grader.psa;
  double _grade = 10;
  CardVariant _variant = CardVariant.normal;
  CardCondition _condition = CardCondition.nearMint;
  int _quantity = 1;
  DateTime _purchaseDate = DateTime.now();
  bool _useManualPrice = false;
  bool _isSaving = false;

  List<PricePoint> _fetchedPrices = const [];
  bool _loadingPrice = false;

  bool get _isSealed => widget.item is SealedProduct;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item is CatalogCard && item.availableVariants.isNotEmpty) {
      _variant = item.availableVariants.first;
    }
    // Versiegelte Produkte haben im MVP keine automatische Preisquelle.
    _useManualPrice = _isSealed;
    if (!_isSealed) _loadPrice();
  }

  @override
  void dispose() {
    _purchaseController.dispose();
    _manualPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadPrice() async {
    setState(() => _loadingPrice = true);
    try {
      final result = await ref
          .read(catalogSourceProvider)
          .cardDetails(widget.item.id);
      if (mounted) {
        setState(() {
          _fetchedPrices = result?.prices ?? const [];
          _loadingPrice = false;
        });
      }
    } on CatalogSourceException {
      if (mounted) setState(() => _loadingPrice = false);
    }
  }

  PriceKey get _priceKey {
    if (_isSealed) return PriceKey.sealed;
    if (_isGraded) return PriceKey.graded(Grading(_grader, _grade));
    return PriceKey.raw(_variant);
  }

  Money? get _referencePrice => _fetchedPrices
      .where((p) => p.priceKey == _priceKey)
      .map((p) => p.valueEur)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = widget.item;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.xl,
            ),
            children: [
              _Header(item: item),
              const SizedBox(height: Spacing.xl),

              if (!_isSealed) ...[
                _Label('Zustand'),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Rohkarte')),
                    ButtonSegment(value: true, label: Text('Gegradet')),
                  ],
                  selected: {_isGraded},
                  onSelectionChanged: (value) {
                    setState(() => _isGraded = value.first);
                    HapticFeedback.selectionClick();
                  },
                ),
                const SizedBox(height: Spacing.lg),
                if (_isGraded) ...[
                  _Label('Grading'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Grader>(
                          initialValue: _grader,
                          decoration: const InputDecoration(
                            labelText: 'Anbieter',
                          ),
                          items: [
                            for (final grader in Grader.values)
                              DropdownMenuItem(
                                value: grader,
                                child: Text(grader.code),
                              ),
                          ],
                          onChanged: (value) => setState(() {
                            _grader = value ?? Grader.psa;
                            if (!_grader.commonGrades.contains(_grade)) {
                              _grade = _grader.commonGrades.first;
                            }
                          }),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          initialValue: _grade,
                          decoration: const InputDecoration(labelText: 'Note'),
                          items: [
                            for (final grade in _grader.commonGrades)
                              DropdownMenuItem(
                                value: grade,
                                child: Text(Grading(_grader, grade).gradeLabel),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _grade = value ?? 10),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _Label('Variante'),
                  Wrap(
                    spacing: Spacing.sm,
                    children: [
                      for (final variant
                          in (item is CatalogCard
                              ? item.availableVariants
                              : CardVariant.values))
                        ChoiceChip(
                          label: Text(variant.label),
                          selected: _variant == variant,
                          onSelected: (_) => setState(() => _variant = variant),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  _Label('Erhaltung'),
                  DropdownButtonFormField<CardCondition>(
                    initialValue: _condition,
                    items: [
                      for (final condition in CardCondition.values)
                        DropdownMenuItem(
                          value: condition,
                          child: Text('${condition.code} — ${condition.label}'),
                        ),
                    ],
                    onChanged: (value) => setState(
                      () => _condition = value ?? CardCondition.nearMint,
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.lg),
              ],

              _Label('Menge'),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: context.texts.headlineMedium,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              _Label('Kaufpreis je Stück'),
              TextField(
                controller: _purchaseController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '0,00',
                  suffixText: '€',
                ),
              ),
              const SizedBox(height: Spacing.lg),

              _Label('Kaufdatum'),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(Spacing.radiusMedium),
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: colors.labelSecondary,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(Formats.dateLong(_purchaseDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              _PricePreview(
                isLoading: _loadingPrice,
                reference: _referencePrice,
                isSealed: _isSealed,
                isGraded: _isGraded,
                useManual: _useManualPrice,
                controller: _manualPriceController,
                onToggleManual: (value) =>
                    setState(() => _useManualPrice = value),
              ),
              const SizedBox(height: Spacing.lg),

              _Label('Notiz (optional)'),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'z. B. Fundort, Sammelbestellung, Zustandsdetail',
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Zur Sammlung hinzufügen'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(1996),
      lastDate: DateTime.now(),
      helpText: 'Kaufdatum wählen',
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final manualPrice = _useManualPrice
        ? Formats.parseMoney(_manualPriceController.text)
        : null;
    final now = DateTime.now();

    final holding = Holding(
      id: 'h-${now.microsecondsSinceEpoch}',
      portfolioId: kPortfolioId,
      type: _isSealed ? HoldingType.sealed : HoldingType.card,
      catalogId: widget.item.id,
      quantity: _quantity,
      purchaseDate: _purchaseDate,
      createdAt: now,
      variant: _variant,
      condition: _condition,
      grading: _isGraded ? Grading(_grader, _grade) : null,
      purchasePrice:
          Formats.parseMoney(_purchaseController.text) ?? const Money.zero(),
      priceMode: manualPrice == null ? PriceMode.auto : PriceMode.manual,
      manualPrice: manualPrice,
      manualPriceSetAt: manualPrice == null ? null : now,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    await ref
        .read(collectionControllerProvider)
        .addHolding(
          holding: holding,
          item: widget.item,
          prices: _fetchedPrices,
        );

    if (mounted) {
      HapticFeedback.mediumImpact();
      widget.onSaved();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        CatalogImage(item: item, width: 58, quality: ImageQuality.high),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.fullLabel, style: context.texts.headlineMedium),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: context.texts.bodySmall?.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.sm),
    child: Text(
      text,
      style: context.texts.titleMedium?.copyWith(
        color: context.colors.labelSecondary,
      ),
    ),
  );
}

/// Zeigt an, welcher Preis gelten wird — und lässt ihn überschreiben.
///
/// Bei gegradeten Karten und versiegelten Produkten ist der manuelle Preis
/// oft der einzig realistische (§3.6); er wird deshalb gleichwertig und nicht
/// als Ausnahme dargestellt.
class _PricePreview extends StatelessWidget {
  const _PricePreview({
    required this.isLoading,
    required this.reference,
    required this.isSealed,
    required this.isGraded,
    required this.useManual,
    required this.controller,
    required this.onToggleManual,
  });

  final bool isLoading;
  final Money? reference;
  final bool isSealed;
  final bool isGraded;
  final bool useManual;
  final TextEditingController controller;
  final ValueChanged<bool> onToggleManual;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final String status;
    if (isLoading) {
      status = 'Marktpreis wird geladen …';
    } else if (reference != null) {
      status = 'Cardmarket-Trend: ${Formats.money(reference!)}';
    } else if (isSealed) {
      status =
          'Für versiegelte Produkte gibt es keine automatische '
          'Preisquelle in Euro — bitte eigenen Wert setzen.';
    } else if (isGraded) {
      status =
          'Für diese Bewertung liegt kein automatischer Preis vor. '
          'Eigener Wert empfohlen.';
    } else {
      status = 'Kein Marktpreis gefunden — der Kaufpreis dient als Anhalt.';
    }

    // Material statt eingefärbter Box, damit der enthaltene Schalter seine
    // Tipp-Effekte zeichnen kann.
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusMedium),
        side: BorderSide(color: colors.separator, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reference != null
                      ? Icons.trending_up_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: reference != null
                      ? colors.accent
                      : colors.labelSecondary,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    status,
                    style: context.texts.bodySmall?.copyWith(
                      color: reference != null
                          ? colors.label
                          : colors.labelSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: useManual,
              onChanged: onToggleManual,
              title: Text(
                'Eigenen Preis verwenden',
                style: context.texts.bodyMedium,
              ),
            ),
            if (useManual)
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '0,00',
                  suffixText: '€',
                  helperText: 'Wert je Stück',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
