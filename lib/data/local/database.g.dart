// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CardEntriesTable extends CardEntries
    with TableInfo<$CardEntriesTable, CardEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameDeMeta = const VerificationMeta('nameDe');
  @override
  late final GeneratedColumn<String> nameDe = GeneratedColumn<String>(
    'name_de',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageBaseMeta = const VerificationMeta(
    'imageBase',
  );
  @override
  late final GeneratedColumn<String> imageBase = GeneratedColumn<String>(
    'image_base',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageBaseEnMeta = const VerificationMeta(
    'imageBaseEn',
  );
  @override
  late final GeneratedColumn<String> imageBaseEn = GeneratedColumn<String>(
    'image_base_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setCardCountMeta = const VerificationMeta(
    'setCardCount',
  );
  @override
  late final GeneratedColumn<int> setCardCount = GeneratedColumn<int>(
    'set_card_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variantsMeta = const VerificationMeta(
    'variants',
  );
  @override
  late final GeneratedColumn<String> variants = GeneratedColumn<String>(
    'variants',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    setId,
    setName,
    localId,
    nameEn,
    nameDe,
    rarity,
    imageBase,
    imageBaseEn,
    setCardCount,
    variants,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    } else if (isInserting) {
      context.missing(_setNameMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_de')) {
      context.handle(
        _nameDeMeta,
        nameDe.isAcceptableOrUnknown(data['name_de']!, _nameDeMeta),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    if (data.containsKey('image_base')) {
      context.handle(
        _imageBaseMeta,
        imageBase.isAcceptableOrUnknown(data['image_base']!, _imageBaseMeta),
      );
    }
    if (data.containsKey('image_base_en')) {
      context.handle(
        _imageBaseEnMeta,
        imageBaseEn.isAcceptableOrUnknown(
          data['image_base_en']!,
          _imageBaseEnMeta,
        ),
      );
    }
    if (data.containsKey('set_card_count')) {
      context.handle(
        _setCardCountMeta,
        setCardCount.isAcceptableOrUnknown(
          data['set_card_count']!,
          _setCardCountMeta,
        ),
      );
    }
    if (data.containsKey('variants')) {
      context.handle(
        _variantsMeta,
        variants.isAcceptableOrUnknown(data['variants']!, _variantsMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameDe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_de'],
      ),
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      ),
      imageBase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_base'],
      ),
      imageBaseEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_base_en'],
      ),
      setCardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_card_count'],
      ),
      variants: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variants'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CardEntriesTable createAlias(String alias) {
    return $CardEntriesTable(attachedDatabase, alias);
  }
}

class CardEntry extends DataClass implements Insertable<CardEntry> {
  final String id;
  final String setId;
  final String setName;
  final String localId;
  final String nameEn;
  final String? nameDe;
  final String? rarity;
  final String? imageBase;
  final String? imageBaseEn;
  final int? setCardCount;

  /// Kommaseparierte Variantencodes, z. B. `normal,reverse`.
  final String variants;
  final DateTime cachedAt;
  const CardEntry({
    required this.id,
    required this.setId,
    required this.setName,
    required this.localId,
    required this.nameEn,
    this.nameDe,
    this.rarity,
    this.imageBase,
    this.imageBaseEn,
    this.setCardCount,
    required this.variants,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['set_id'] = Variable<String>(setId);
    map['set_name'] = Variable<String>(setName);
    map['local_id'] = Variable<String>(localId);
    map['name_en'] = Variable<String>(nameEn);
    if (!nullToAbsent || nameDe != null) {
      map['name_de'] = Variable<String>(nameDe);
    }
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<String>(rarity);
    }
    if (!nullToAbsent || imageBase != null) {
      map['image_base'] = Variable<String>(imageBase);
    }
    if (!nullToAbsent || imageBaseEn != null) {
      map['image_base_en'] = Variable<String>(imageBaseEn);
    }
    if (!nullToAbsent || setCardCount != null) {
      map['set_card_count'] = Variable<int>(setCardCount);
    }
    map['variants'] = Variable<String>(variants);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CardEntriesCompanion toCompanion(bool nullToAbsent) {
    return CardEntriesCompanion(
      id: Value(id),
      setId: Value(setId),
      setName: Value(setName),
      localId: Value(localId),
      nameEn: Value(nameEn),
      nameDe: nameDe == null && nullToAbsent
          ? const Value.absent()
          : Value(nameDe),
      rarity: rarity == null && nullToAbsent
          ? const Value.absent()
          : Value(rarity),
      imageBase: imageBase == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBase),
      imageBaseEn: imageBaseEn == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBaseEn),
      setCardCount: setCardCount == null && nullToAbsent
          ? const Value.absent()
          : Value(setCardCount),
      variants: Value(variants),
      cachedAt: Value(cachedAt),
    );
  }

  factory CardEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardEntry(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String>(json['setId']),
      setName: serializer.fromJson<String>(json['setName']),
      localId: serializer.fromJson<String>(json['localId']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameDe: serializer.fromJson<String?>(json['nameDe']),
      rarity: serializer.fromJson<String?>(json['rarity']),
      imageBase: serializer.fromJson<String?>(json['imageBase']),
      imageBaseEn: serializer.fromJson<String?>(json['imageBaseEn']),
      setCardCount: serializer.fromJson<int?>(json['setCardCount']),
      variants: serializer.fromJson<String>(json['variants']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String>(setId),
      'setName': serializer.toJson<String>(setName),
      'localId': serializer.toJson<String>(localId),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameDe': serializer.toJson<String?>(nameDe),
      'rarity': serializer.toJson<String?>(rarity),
      'imageBase': serializer.toJson<String?>(imageBase),
      'imageBaseEn': serializer.toJson<String?>(imageBaseEn),
      'setCardCount': serializer.toJson<int?>(setCardCount),
      'variants': serializer.toJson<String>(variants),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CardEntry copyWith({
    String? id,
    String? setId,
    String? setName,
    String? localId,
    String? nameEn,
    Value<String?> nameDe = const Value.absent(),
    Value<String?> rarity = const Value.absent(),
    Value<String?> imageBase = const Value.absent(),
    Value<String?> imageBaseEn = const Value.absent(),
    Value<int?> setCardCount = const Value.absent(),
    String? variants,
    DateTime? cachedAt,
  }) => CardEntry(
    id: id ?? this.id,
    setId: setId ?? this.setId,
    setName: setName ?? this.setName,
    localId: localId ?? this.localId,
    nameEn: nameEn ?? this.nameEn,
    nameDe: nameDe.present ? nameDe.value : this.nameDe,
    rarity: rarity.present ? rarity.value : this.rarity,
    imageBase: imageBase.present ? imageBase.value : this.imageBase,
    imageBaseEn: imageBaseEn.present ? imageBaseEn.value : this.imageBaseEn,
    setCardCount: setCardCount.present ? setCardCount.value : this.setCardCount,
    variants: variants ?? this.variants,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CardEntry copyWithCompanion(CardEntriesCompanion data) {
    return CardEntry(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      setName: data.setName.present ? data.setName.value : this.setName,
      localId: data.localId.present ? data.localId.value : this.localId,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameDe: data.nameDe.present ? data.nameDe.value : this.nameDe,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      imageBase: data.imageBase.present ? data.imageBase.value : this.imageBase,
      imageBaseEn: data.imageBaseEn.present
          ? data.imageBaseEn.value
          : this.imageBaseEn,
      setCardCount: data.setCardCount.present
          ? data.setCardCount.value
          : this.setCardCount,
      variants: data.variants.present ? data.variants.value : this.variants,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardEntry(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('setName: $setName, ')
          ..write('localId: $localId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameDe: $nameDe, ')
          ..write('rarity: $rarity, ')
          ..write('imageBase: $imageBase, ')
          ..write('imageBaseEn: $imageBaseEn, ')
          ..write('setCardCount: $setCardCount, ')
          ..write('variants: $variants, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    setId,
    setName,
    localId,
    nameEn,
    nameDe,
    rarity,
    imageBase,
    imageBaseEn,
    setCardCount,
    variants,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardEntry &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.setName == this.setName &&
          other.localId == this.localId &&
          other.nameEn == this.nameEn &&
          other.nameDe == this.nameDe &&
          other.rarity == this.rarity &&
          other.imageBase == this.imageBase &&
          other.imageBaseEn == this.imageBaseEn &&
          other.setCardCount == this.setCardCount &&
          other.variants == this.variants &&
          other.cachedAt == this.cachedAt);
}

class CardEntriesCompanion extends UpdateCompanion<CardEntry> {
  final Value<String> id;
  final Value<String> setId;
  final Value<String> setName;
  final Value<String> localId;
  final Value<String> nameEn;
  final Value<String?> nameDe;
  final Value<String?> rarity;
  final Value<String?> imageBase;
  final Value<String?> imageBaseEn;
  final Value<int?> setCardCount;
  final Value<String> variants;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CardEntriesCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.setName = const Value.absent(),
    this.localId = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameDe = const Value.absent(),
    this.rarity = const Value.absent(),
    this.imageBase = const Value.absent(),
    this.imageBaseEn = const Value.absent(),
    this.setCardCount = const Value.absent(),
    this.variants = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardEntriesCompanion.insert({
    required String id,
    required String setId,
    required String setName,
    required String localId,
    required String nameEn,
    this.nameDe = const Value.absent(),
    this.rarity = const Value.absent(),
    this.imageBase = const Value.absent(),
    this.imageBaseEn = const Value.absent(),
    this.setCardCount = const Value.absent(),
    this.variants = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       setId = Value(setId),
       setName = Value(setName),
       localId = Value(localId),
       nameEn = Value(nameEn),
       cachedAt = Value(cachedAt);
  static Insertable<CardEntry> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<String>? setName,
    Expression<String>? localId,
    Expression<String>? nameEn,
    Expression<String>? nameDe,
    Expression<String>? rarity,
    Expression<String>? imageBase,
    Expression<String>? imageBaseEn,
    Expression<int>? setCardCount,
    Expression<String>? variants,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (setName != null) 'set_name': setName,
      if (localId != null) 'local_id': localId,
      if (nameEn != null) 'name_en': nameEn,
      if (nameDe != null) 'name_de': nameDe,
      if (rarity != null) 'rarity': rarity,
      if (imageBase != null) 'image_base': imageBase,
      if (imageBaseEn != null) 'image_base_en': imageBaseEn,
      if (setCardCount != null) 'set_card_count': setCardCount,
      if (variants != null) 'variants': variants,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? setId,
    Value<String>? setName,
    Value<String>? localId,
    Value<String>? nameEn,
    Value<String?>? nameDe,
    Value<String?>? rarity,
    Value<String?>? imageBase,
    Value<String?>? imageBaseEn,
    Value<int?>? setCardCount,
    Value<String>? variants,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CardEntriesCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      setName: setName ?? this.setName,
      localId: localId ?? this.localId,
      nameEn: nameEn ?? this.nameEn,
      nameDe: nameDe ?? this.nameDe,
      rarity: rarity ?? this.rarity,
      imageBase: imageBase ?? this.imageBase,
      imageBaseEn: imageBaseEn ?? this.imageBaseEn,
      setCardCount: setCardCount ?? this.setCardCount,
      variants: variants ?? this.variants,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameDe.present) {
      map['name_de'] = Variable<String>(nameDe.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (imageBase.present) {
      map['image_base'] = Variable<String>(imageBase.value);
    }
    if (imageBaseEn.present) {
      map['image_base_en'] = Variable<String>(imageBaseEn.value);
    }
    if (setCardCount.present) {
      map['set_card_count'] = Variable<int>(setCardCount.value);
    }
    if (variants.present) {
      map['variants'] = Variable<String>(variants.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardEntriesCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('setName: $setName, ')
          ..write('localId: $localId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameDe: $nameDe, ')
          ..write('rarity: $rarity, ')
          ..write('imageBase: $imageBase, ')
          ..write('imageBaseEn: $imageBaseEn, ')
          ..write('setCardCount: $setCardCount, ')
          ..write('variants: $variants, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SealedEntriesTable extends SealedEntries
    with TableInfo<$SealedEntriesTable, SealedEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SealedEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DE'),
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    setId,
    setName,
    language,
    image,
    isCustom,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sealed_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SealedEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SealedEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SealedEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      ),
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $SealedEntriesTable createAlias(String alias) {
    return $SealedEntriesTable(attachedDatabase, alias);
  }
}

class SealedEntry extends DataClass implements Insertable<SealedEntry> {
  final String id;
  final String name;
  final String type;
  final String? setId;
  final String? setName;
  final String language;
  final String? image;
  final bool isCustom;
  final DateTime cachedAt;
  const SealedEntry({
    required this.id,
    required this.name,
    required this.type,
    this.setId,
    this.setName,
    required this.language,
    this.image,
    required this.isCustom,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || setId != null) {
      map['set_id'] = Variable<String>(setId);
    }
    if (!nullToAbsent || setName != null) {
      map['set_name'] = Variable<String>(setName);
    }
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  SealedEntriesCompanion toCompanion(bool nullToAbsent) {
    return SealedEntriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      setId: setId == null && nullToAbsent
          ? const Value.absent()
          : Value(setId),
      setName: setName == null && nullToAbsent
          ? const Value.absent()
          : Value(setName),
      language: Value(language),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
      isCustom: Value(isCustom),
      cachedAt: Value(cachedAt),
    );
  }

  factory SealedEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SealedEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      setId: serializer.fromJson<String?>(json['setId']),
      setName: serializer.fromJson<String?>(json['setName']),
      language: serializer.fromJson<String>(json['language']),
      image: serializer.fromJson<String?>(json['image']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'setId': serializer.toJson<String?>(setId),
      'setName': serializer.toJson<String?>(setName),
      'language': serializer.toJson<String>(language),
      'image': serializer.toJson<String?>(image),
      'isCustom': serializer.toJson<bool>(isCustom),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  SealedEntry copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> setId = const Value.absent(),
    Value<String?> setName = const Value.absent(),
    String? language,
    Value<String?> image = const Value.absent(),
    bool? isCustom,
    DateTime? cachedAt,
  }) => SealedEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    setId: setId.present ? setId.value : this.setId,
    setName: setName.present ? setName.value : this.setName,
    language: language ?? this.language,
    image: image.present ? image.value : this.image,
    isCustom: isCustom ?? this.isCustom,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  SealedEntry copyWithCompanion(SealedEntriesCompanion data) {
    return SealedEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      setId: data.setId.present ? data.setId.value : this.setId,
      setName: data.setName.present ? data.setName.value : this.setName,
      language: data.language.present ? data.language.value : this.language,
      image: data.image.present ? data.image.value : this.image,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SealedEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('setId: $setId, ')
          ..write('setName: $setName, ')
          ..write('language: $language, ')
          ..write('image: $image, ')
          ..write('isCustom: $isCustom, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    setId,
    setName,
    language,
    image,
    isCustom,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SealedEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.setId == this.setId &&
          other.setName == this.setName &&
          other.language == this.language &&
          other.image == this.image &&
          other.isCustom == this.isCustom &&
          other.cachedAt == this.cachedAt);
}

class SealedEntriesCompanion extends UpdateCompanion<SealedEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> setId;
  final Value<String?> setName;
  final Value<String> language;
  final Value<String?> image;
  final Value<bool> isCustom;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const SealedEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.setId = const Value.absent(),
    this.setName = const Value.absent(),
    this.language = const Value.absent(),
    this.image = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SealedEntriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.setId = const Value.absent(),
    this.setName = const Value.absent(),
    this.language = const Value.absent(),
    this.image = const Value.absent(),
    this.isCustom = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       cachedAt = Value(cachedAt);
  static Insertable<SealedEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? setId,
    Expression<String>? setName,
    Expression<String>? language,
    Expression<String>? image,
    Expression<bool>? isCustom,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (setId != null) 'set_id': setId,
      if (setName != null) 'set_name': setName,
      if (language != null) 'language': language,
      if (image != null) 'image': image,
      if (isCustom != null) 'is_custom': isCustom,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SealedEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? setId,
    Value<String?>? setName,
    Value<String>? language,
    Value<String?>? image,
    Value<bool>? isCustom,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return SealedEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      setId: setId ?? this.setId,
      setName: setName ?? this.setName,
      language: language ?? this.language,
      image: image ?? this.image,
      isCustom: isCustom ?? this.isCustom,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SealedEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('setId: $setId, ')
          ..write('setName: $setName, ')
          ..write('language: $language, ')
          ..write('image: $image, ')
          ..write('isCustom: $isCustom, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HoldingEntriesTable extends HoldingEntries
    with TableInfo<$HoldingEntriesTable, HoldingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portfolioIdMeta = const VerificationMeta(
    'portfolioId',
  );
  @override
  late final GeneratedColumn<String> portfolioId = GeneratedColumn<String>(
    'portfolio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NM'),
  );
  static const VerificationMeta _graderCodeMeta = const VerificationMeta(
    'graderCode',
  );
  @override
  late final GeneratedColumn<String> graderCode = GeneratedColumn<String>(
    'grader_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<double> grade = GeneratedColumn<double>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _certificateNumberMeta = const VerificationMeta(
    'certificateNumber',
  );
  @override
  late final GeneratedColumn<String> certificateNumber =
      GeneratedColumn<String>(
        'certificate_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchasePriceCentsMeta =
      const VerificationMeta('purchasePriceCents');
  @override
  late final GeneratedColumn<int> purchasePriceCents = GeneratedColumn<int>(
    'purchase_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceModeMeta = const VerificationMeta(
    'priceMode',
  );
  @override
  late final GeneratedColumn<String> priceMode = GeneratedColumn<String>(
    'price_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _manualPriceCentsMeta = const VerificationMeta(
    'manualPriceCents',
  );
  @override
  late final GeneratedColumn<int> manualPriceCents = GeneratedColumn<int>(
    'manual_price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualPriceSetAtMeta = const VerificationMeta(
    'manualPriceSetAt',
  );
  @override
  late final GeneratedColumn<DateTime> manualPriceSetAt =
      GeneratedColumn<DateTime>(
        'manual_price_set_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    portfolioId,
    type,
    catalogId,
    quantity,
    variant,
    condition,
    graderCode,
    grade,
    certificateNumber,
    purchasePriceCents,
    purchaseDate,
    priceMode,
    manualPriceCents,
    manualPriceSetAt,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holding_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HoldingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('portfolio_id')) {
      context.handle(
        _portfolioIdMeta,
        portfolioId.isAcceptableOrUnknown(
          data['portfolio_id']!,
          _portfolioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_portfolioIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('grader_code')) {
      context.handle(
        _graderCodeMeta,
        graderCode.isAcceptableOrUnknown(data['grader_code']!, _graderCodeMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('certificate_number')) {
      context.handle(
        _certificateNumberMeta,
        certificateNumber.isAcceptableOrUnknown(
          data['certificate_number']!,
          _certificateNumberMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price_cents')) {
      context.handle(
        _purchasePriceCentsMeta,
        purchasePriceCents.isAcceptableOrUnknown(
          data['purchase_price_cents']!,
          _purchasePriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('price_mode')) {
      context.handle(
        _priceModeMeta,
        priceMode.isAcceptableOrUnknown(data['price_mode']!, _priceModeMeta),
      );
    }
    if (data.containsKey('manual_price_cents')) {
      context.handle(
        _manualPriceCentsMeta,
        manualPriceCents.isAcceptableOrUnknown(
          data['manual_price_cents']!,
          _manualPriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('manual_price_set_at')) {
      context.handle(
        _manualPriceSetAtMeta,
        manualPriceSetAt.isAcceptableOrUnknown(
          data['manual_price_set_at']!,
          _manualPriceSetAtMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HoldingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HoldingEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      portfolioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portfolio_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      )!,
      graderCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grader_code'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grade'],
      ),
      certificateNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certificate_number'],
      ),
      purchasePriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_price_cents'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      priceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_mode'],
      )!,
      manualPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_price_cents'],
      ),
      manualPriceSetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}manual_price_set_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HoldingEntriesTable createAlias(String alias) {
    return $HoldingEntriesTable(attachedDatabase, alias);
  }
}

class HoldingEntry extends DataClass implements Insertable<HoldingEntry> {
  final String id;
  final String portfolioId;
  final String type;
  final String catalogId;
  final int quantity;
  final String variant;
  final String condition;
  final String? graderCode;
  final double? grade;
  final String? certificateNumber;
  final int purchasePriceCents;
  final DateTime purchaseDate;
  final String priceMode;
  final int? manualPriceCents;
  final DateTime? manualPriceSetAt;
  final String? note;
  final DateTime createdAt;
  const HoldingEntry({
    required this.id,
    required this.portfolioId,
    required this.type,
    required this.catalogId,
    required this.quantity,
    required this.variant,
    required this.condition,
    this.graderCode,
    this.grade,
    this.certificateNumber,
    required this.purchasePriceCents,
    required this.purchaseDate,
    required this.priceMode,
    this.manualPriceCents,
    this.manualPriceSetAt,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['portfolio_id'] = Variable<String>(portfolioId);
    map['type'] = Variable<String>(type);
    map['catalog_id'] = Variable<String>(catalogId);
    map['quantity'] = Variable<int>(quantity);
    map['variant'] = Variable<String>(variant);
    map['condition'] = Variable<String>(condition);
    if (!nullToAbsent || graderCode != null) {
      map['grader_code'] = Variable<String>(graderCode);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<double>(grade);
    }
    if (!nullToAbsent || certificateNumber != null) {
      map['certificate_number'] = Variable<String>(certificateNumber);
    }
    map['purchase_price_cents'] = Variable<int>(purchasePriceCents);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['price_mode'] = Variable<String>(priceMode);
    if (!nullToAbsent || manualPriceCents != null) {
      map['manual_price_cents'] = Variable<int>(manualPriceCents);
    }
    if (!nullToAbsent || manualPriceSetAt != null) {
      map['manual_price_set_at'] = Variable<DateTime>(manualPriceSetAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HoldingEntriesCompanion toCompanion(bool nullToAbsent) {
    return HoldingEntriesCompanion(
      id: Value(id),
      portfolioId: Value(portfolioId),
      type: Value(type),
      catalogId: Value(catalogId),
      quantity: Value(quantity),
      variant: Value(variant),
      condition: Value(condition),
      graderCode: graderCode == null && nullToAbsent
          ? const Value.absent()
          : Value(graderCode),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      certificateNumber: certificateNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(certificateNumber),
      purchasePriceCents: Value(purchasePriceCents),
      purchaseDate: Value(purchaseDate),
      priceMode: Value(priceMode),
      manualPriceCents: manualPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(manualPriceCents),
      manualPriceSetAt: manualPriceSetAt == null && nullToAbsent
          ? const Value.absent()
          : Value(manualPriceSetAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory HoldingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HoldingEntry(
      id: serializer.fromJson<String>(json['id']),
      portfolioId: serializer.fromJson<String>(json['portfolioId']),
      type: serializer.fromJson<String>(json['type']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      variant: serializer.fromJson<String>(json['variant']),
      condition: serializer.fromJson<String>(json['condition']),
      graderCode: serializer.fromJson<String?>(json['graderCode']),
      grade: serializer.fromJson<double?>(json['grade']),
      certificateNumber: serializer.fromJson<String?>(
        json['certificateNumber'],
      ),
      purchasePriceCents: serializer.fromJson<int>(json['purchasePriceCents']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      priceMode: serializer.fromJson<String>(json['priceMode']),
      manualPriceCents: serializer.fromJson<int?>(json['manualPriceCents']),
      manualPriceSetAt: serializer.fromJson<DateTime?>(
        json['manualPriceSetAt'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'portfolioId': serializer.toJson<String>(portfolioId),
      'type': serializer.toJson<String>(type),
      'catalogId': serializer.toJson<String>(catalogId),
      'quantity': serializer.toJson<int>(quantity),
      'variant': serializer.toJson<String>(variant),
      'condition': serializer.toJson<String>(condition),
      'graderCode': serializer.toJson<String?>(graderCode),
      'grade': serializer.toJson<double?>(grade),
      'certificateNumber': serializer.toJson<String?>(certificateNumber),
      'purchasePriceCents': serializer.toJson<int>(purchasePriceCents),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'priceMode': serializer.toJson<String>(priceMode),
      'manualPriceCents': serializer.toJson<int?>(manualPriceCents),
      'manualPriceSetAt': serializer.toJson<DateTime?>(manualPriceSetAt),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HoldingEntry copyWith({
    String? id,
    String? portfolioId,
    String? type,
    String? catalogId,
    int? quantity,
    String? variant,
    String? condition,
    Value<String?> graderCode = const Value.absent(),
    Value<double?> grade = const Value.absent(),
    Value<String?> certificateNumber = const Value.absent(),
    int? purchasePriceCents,
    DateTime? purchaseDate,
    String? priceMode,
    Value<int?> manualPriceCents = const Value.absent(),
    Value<DateTime?> manualPriceSetAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => HoldingEntry(
    id: id ?? this.id,
    portfolioId: portfolioId ?? this.portfolioId,
    type: type ?? this.type,
    catalogId: catalogId ?? this.catalogId,
    quantity: quantity ?? this.quantity,
    variant: variant ?? this.variant,
    condition: condition ?? this.condition,
    graderCode: graderCode.present ? graderCode.value : this.graderCode,
    grade: grade.present ? grade.value : this.grade,
    certificateNumber: certificateNumber.present
        ? certificateNumber.value
        : this.certificateNumber,
    purchasePriceCents: purchasePriceCents ?? this.purchasePriceCents,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    priceMode: priceMode ?? this.priceMode,
    manualPriceCents: manualPriceCents.present
        ? manualPriceCents.value
        : this.manualPriceCents,
    manualPriceSetAt: manualPriceSetAt.present
        ? manualPriceSetAt.value
        : this.manualPriceSetAt,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  HoldingEntry copyWithCompanion(HoldingEntriesCompanion data) {
    return HoldingEntry(
      id: data.id.present ? data.id.value : this.id,
      portfolioId: data.portfolioId.present
          ? data.portfolioId.value
          : this.portfolioId,
      type: data.type.present ? data.type.value : this.type,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      variant: data.variant.present ? data.variant.value : this.variant,
      condition: data.condition.present ? data.condition.value : this.condition,
      graderCode: data.graderCode.present
          ? data.graderCode.value
          : this.graderCode,
      grade: data.grade.present ? data.grade.value : this.grade,
      certificateNumber: data.certificateNumber.present
          ? data.certificateNumber.value
          : this.certificateNumber,
      purchasePriceCents: data.purchasePriceCents.present
          ? data.purchasePriceCents.value
          : this.purchasePriceCents,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      priceMode: data.priceMode.present ? data.priceMode.value : this.priceMode,
      manualPriceCents: data.manualPriceCents.present
          ? data.manualPriceCents.value
          : this.manualPriceCents,
      manualPriceSetAt: data.manualPriceSetAt.present
          ? data.manualPriceSetAt.value
          : this.manualPriceSetAt,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HoldingEntry(')
          ..write('id: $id, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('type: $type, ')
          ..write('catalogId: $catalogId, ')
          ..write('quantity: $quantity, ')
          ..write('variant: $variant, ')
          ..write('condition: $condition, ')
          ..write('graderCode: $graderCode, ')
          ..write('grade: $grade, ')
          ..write('certificateNumber: $certificateNumber, ')
          ..write('purchasePriceCents: $purchasePriceCents, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('priceMode: $priceMode, ')
          ..write('manualPriceCents: $manualPriceCents, ')
          ..write('manualPriceSetAt: $manualPriceSetAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    portfolioId,
    type,
    catalogId,
    quantity,
    variant,
    condition,
    graderCode,
    grade,
    certificateNumber,
    purchasePriceCents,
    purchaseDate,
    priceMode,
    manualPriceCents,
    manualPriceSetAt,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HoldingEntry &&
          other.id == this.id &&
          other.portfolioId == this.portfolioId &&
          other.type == this.type &&
          other.catalogId == this.catalogId &&
          other.quantity == this.quantity &&
          other.variant == this.variant &&
          other.condition == this.condition &&
          other.graderCode == this.graderCode &&
          other.grade == this.grade &&
          other.certificateNumber == this.certificateNumber &&
          other.purchasePriceCents == this.purchasePriceCents &&
          other.purchaseDate == this.purchaseDate &&
          other.priceMode == this.priceMode &&
          other.manualPriceCents == this.manualPriceCents &&
          other.manualPriceSetAt == this.manualPriceSetAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class HoldingEntriesCompanion extends UpdateCompanion<HoldingEntry> {
  final Value<String> id;
  final Value<String> portfolioId;
  final Value<String> type;
  final Value<String> catalogId;
  final Value<int> quantity;
  final Value<String> variant;
  final Value<String> condition;
  final Value<String?> graderCode;
  final Value<double?> grade;
  final Value<String?> certificateNumber;
  final Value<int> purchasePriceCents;
  final Value<DateTime> purchaseDate;
  final Value<String> priceMode;
  final Value<int?> manualPriceCents;
  final Value<DateTime?> manualPriceSetAt;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HoldingEntriesCompanion({
    this.id = const Value.absent(),
    this.portfolioId = const Value.absent(),
    this.type = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.variant = const Value.absent(),
    this.condition = const Value.absent(),
    this.graderCode = const Value.absent(),
    this.grade = const Value.absent(),
    this.certificateNumber = const Value.absent(),
    this.purchasePriceCents = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.priceMode = const Value.absent(),
    this.manualPriceCents = const Value.absent(),
    this.manualPriceSetAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HoldingEntriesCompanion.insert({
    required String id,
    required String portfolioId,
    required String type,
    required String catalogId,
    required int quantity,
    this.variant = const Value.absent(),
    this.condition = const Value.absent(),
    this.graderCode = const Value.absent(),
    this.grade = const Value.absent(),
    this.certificateNumber = const Value.absent(),
    this.purchasePriceCents = const Value.absent(),
    required DateTime purchaseDate,
    this.priceMode = const Value.absent(),
    this.manualPriceCents = const Value.absent(),
    this.manualPriceSetAt = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       portfolioId = Value(portfolioId),
       type = Value(type),
       catalogId = Value(catalogId),
       quantity = Value(quantity),
       purchaseDate = Value(purchaseDate),
       createdAt = Value(createdAt);
  static Insertable<HoldingEntry> custom({
    Expression<String>? id,
    Expression<String>? portfolioId,
    Expression<String>? type,
    Expression<String>? catalogId,
    Expression<int>? quantity,
    Expression<String>? variant,
    Expression<String>? condition,
    Expression<String>? graderCode,
    Expression<double>? grade,
    Expression<String>? certificateNumber,
    Expression<int>? purchasePriceCents,
    Expression<DateTime>? purchaseDate,
    Expression<String>? priceMode,
    Expression<int>? manualPriceCents,
    Expression<DateTime>? manualPriceSetAt,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (portfolioId != null) 'portfolio_id': portfolioId,
      if (type != null) 'type': type,
      if (catalogId != null) 'catalog_id': catalogId,
      if (quantity != null) 'quantity': quantity,
      if (variant != null) 'variant': variant,
      if (condition != null) 'condition': condition,
      if (graderCode != null) 'grader_code': graderCode,
      if (grade != null) 'grade': grade,
      if (certificateNumber != null) 'certificate_number': certificateNumber,
      if (purchasePriceCents != null)
        'purchase_price_cents': purchasePriceCents,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (priceMode != null) 'price_mode': priceMode,
      if (manualPriceCents != null) 'manual_price_cents': manualPriceCents,
      if (manualPriceSetAt != null) 'manual_price_set_at': manualPriceSetAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HoldingEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? portfolioId,
    Value<String>? type,
    Value<String>? catalogId,
    Value<int>? quantity,
    Value<String>? variant,
    Value<String>? condition,
    Value<String?>? graderCode,
    Value<double?>? grade,
    Value<String?>? certificateNumber,
    Value<int>? purchasePriceCents,
    Value<DateTime>? purchaseDate,
    Value<String>? priceMode,
    Value<int?>? manualPriceCents,
    Value<DateTime?>? manualPriceSetAt,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HoldingEntriesCompanion(
      id: id ?? this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      type: type ?? this.type,
      catalogId: catalogId ?? this.catalogId,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      condition: condition ?? this.condition,
      graderCode: graderCode ?? this.graderCode,
      grade: grade ?? this.grade,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      purchasePriceCents: purchasePriceCents ?? this.purchasePriceCents,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      priceMode: priceMode ?? this.priceMode,
      manualPriceCents: manualPriceCents ?? this.manualPriceCents,
      manualPriceSetAt: manualPriceSetAt ?? this.manualPriceSetAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (portfolioId.present) {
      map['portfolio_id'] = Variable<String>(portfolioId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (graderCode.present) {
      map['grader_code'] = Variable<String>(graderCode.value);
    }
    if (grade.present) {
      map['grade'] = Variable<double>(grade.value);
    }
    if (certificateNumber.present) {
      map['certificate_number'] = Variable<String>(certificateNumber.value);
    }
    if (purchasePriceCents.present) {
      map['purchase_price_cents'] = Variable<int>(purchasePriceCents.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (priceMode.present) {
      map['price_mode'] = Variable<String>(priceMode.value);
    }
    if (manualPriceCents.present) {
      map['manual_price_cents'] = Variable<int>(manualPriceCents.value);
    }
    if (manualPriceSetAt.present) {
      map['manual_price_set_at'] = Variable<DateTime>(manualPriceSetAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingEntriesCompanion(')
          ..write('id: $id, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('type: $type, ')
          ..write('catalogId: $catalogId, ')
          ..write('quantity: $quantity, ')
          ..write('variant: $variant, ')
          ..write('condition: $condition, ')
          ..write('graderCode: $graderCode, ')
          ..write('grade: $grade, ')
          ..write('certificateNumber: $certificateNumber, ')
          ..write('purchasePriceCents: $purchasePriceCents, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('priceMode: $priceMode, ')
          ..write('manualPriceCents: $manualPriceCents, ')
          ..write('manualPriceSetAt: $manualPriceSetAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PriceEntriesTable extends PriceEntries
    with TableInfo<$PriceEntriesTable, PriceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceKeyMeta = const VerificationMeta(
    'priceKey',
  );
  @override
  late final GeneratedColumn<String> priceKey = GeneratedColumn<String>(
    'price_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueCentsMeta = const VerificationMeta(
    'valueCents',
  );
  @override
  late final GeneratedColumn<int> valueCents = GeneratedColumn<int>(
    'value_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _valueEurCentsMeta = const VerificationMeta(
    'valueEurCents',
  );
  @override
  late final GeneratedColumn<int> valueEurCents = GeneratedColumn<int>(
    'value_eur_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catalogId,
    priceKey,
    source,
    valueCents,
    currency,
    valueEurCents,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('price_key')) {
      context.handle(
        _priceKeyMeta,
        priceKey.isAcceptableOrUnknown(data['price_key']!, _priceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_priceKeyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('value_cents')) {
      context.handle(
        _valueCentsMeta,
        valueCents.isAcceptableOrUnknown(data['value_cents']!, _valueCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_valueCentsMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('value_eur_cents')) {
      context.handle(
        _valueEurCentsMeta,
        valueEurCents.isAcceptableOrUnknown(
          data['value_eur_cents']!,
          _valueEurCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueEurCentsMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      priceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_key'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      valueCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_cents'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      valueEurCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_eur_cents'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $PriceEntriesTable createAlias(String alias) {
    return $PriceEntriesTable(attachedDatabase, alias);
  }
}

class PriceEntry extends DataClass implements Insertable<PriceEntry> {
  final int id;
  final String catalogId;
  final String priceKey;
  final String source;
  final int valueCents;
  final String currency;
  final int valueEurCents;
  final DateTime capturedAt;
  const PriceEntry({
    required this.id,
    required this.catalogId,
    required this.priceKey,
    required this.source,
    required this.valueCents,
    required this.currency,
    required this.valueEurCents,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['catalog_id'] = Variable<String>(catalogId);
    map['price_key'] = Variable<String>(priceKey);
    map['source'] = Variable<String>(source);
    map['value_cents'] = Variable<int>(valueCents);
    map['currency'] = Variable<String>(currency);
    map['value_eur_cents'] = Variable<int>(valueEurCents);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  PriceEntriesCompanion toCompanion(bool nullToAbsent) {
    return PriceEntriesCompanion(
      id: Value(id),
      catalogId: Value(catalogId),
      priceKey: Value(priceKey),
      source: Value(source),
      valueCents: Value(valueCents),
      currency: Value(currency),
      valueEurCents: Value(valueEurCents),
      capturedAt: Value(capturedAt),
    );
  }

  factory PriceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceEntry(
      id: serializer.fromJson<int>(json['id']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      priceKey: serializer.fromJson<String>(json['priceKey']),
      source: serializer.fromJson<String>(json['source']),
      valueCents: serializer.fromJson<int>(json['valueCents']),
      currency: serializer.fromJson<String>(json['currency']),
      valueEurCents: serializer.fromJson<int>(json['valueEurCents']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catalogId': serializer.toJson<String>(catalogId),
      'priceKey': serializer.toJson<String>(priceKey),
      'source': serializer.toJson<String>(source),
      'valueCents': serializer.toJson<int>(valueCents),
      'currency': serializer.toJson<String>(currency),
      'valueEurCents': serializer.toJson<int>(valueEurCents),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  PriceEntry copyWith({
    int? id,
    String? catalogId,
    String? priceKey,
    String? source,
    int? valueCents,
    String? currency,
    int? valueEurCents,
    DateTime? capturedAt,
  }) => PriceEntry(
    id: id ?? this.id,
    catalogId: catalogId ?? this.catalogId,
    priceKey: priceKey ?? this.priceKey,
    source: source ?? this.source,
    valueCents: valueCents ?? this.valueCents,
    currency: currency ?? this.currency,
    valueEurCents: valueEurCents ?? this.valueEurCents,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  PriceEntry copyWithCompanion(PriceEntriesCompanion data) {
    return PriceEntry(
      id: data.id.present ? data.id.value : this.id,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      priceKey: data.priceKey.present ? data.priceKey.value : this.priceKey,
      source: data.source.present ? data.source.value : this.source,
      valueCents: data.valueCents.present
          ? data.valueCents.value
          : this.valueCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      valueEurCents: data.valueEurCents.present
          ? data.valueEurCents.value
          : this.valueEurCents,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceEntry(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('priceKey: $priceKey, ')
          ..write('source: $source, ')
          ..write('valueCents: $valueCents, ')
          ..write('currency: $currency, ')
          ..write('valueEurCents: $valueEurCents, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catalogId,
    priceKey,
    source,
    valueCents,
    currency,
    valueEurCents,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceEntry &&
          other.id == this.id &&
          other.catalogId == this.catalogId &&
          other.priceKey == this.priceKey &&
          other.source == this.source &&
          other.valueCents == this.valueCents &&
          other.currency == this.currency &&
          other.valueEurCents == this.valueEurCents &&
          other.capturedAt == this.capturedAt);
}

class PriceEntriesCompanion extends UpdateCompanion<PriceEntry> {
  final Value<int> id;
  final Value<String> catalogId;
  final Value<String> priceKey;
  final Value<String> source;
  final Value<int> valueCents;
  final Value<String> currency;
  final Value<int> valueEurCents;
  final Value<DateTime> capturedAt;
  const PriceEntriesCompanion({
    this.id = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.priceKey = const Value.absent(),
    this.source = const Value.absent(),
    this.valueCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.valueEurCents = const Value.absent(),
    this.capturedAt = const Value.absent(),
  });
  PriceEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String catalogId,
    required String priceKey,
    required String source,
    required int valueCents,
    this.currency = const Value.absent(),
    required int valueEurCents,
    required DateTime capturedAt,
  }) : catalogId = Value(catalogId),
       priceKey = Value(priceKey),
       source = Value(source),
       valueCents = Value(valueCents),
       valueEurCents = Value(valueEurCents),
       capturedAt = Value(capturedAt);
  static Insertable<PriceEntry> custom({
    Expression<int>? id,
    Expression<String>? catalogId,
    Expression<String>? priceKey,
    Expression<String>? source,
    Expression<int>? valueCents,
    Expression<String>? currency,
    Expression<int>? valueEurCents,
    Expression<DateTime>? capturedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catalogId != null) 'catalog_id': catalogId,
      if (priceKey != null) 'price_key': priceKey,
      if (source != null) 'source': source,
      if (valueCents != null) 'value_cents': valueCents,
      if (currency != null) 'currency': currency,
      if (valueEurCents != null) 'value_eur_cents': valueEurCents,
      if (capturedAt != null) 'captured_at': capturedAt,
    });
  }

  PriceEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? catalogId,
    Value<String>? priceKey,
    Value<String>? source,
    Value<int>? valueCents,
    Value<String>? currency,
    Value<int>? valueEurCents,
    Value<DateTime>? capturedAt,
  }) {
    return PriceEntriesCompanion(
      id: id ?? this.id,
      catalogId: catalogId ?? this.catalogId,
      priceKey: priceKey ?? this.priceKey,
      source: source ?? this.source,
      valueCents: valueCents ?? this.valueCents,
      currency: currency ?? this.currency,
      valueEurCents: valueEurCents ?? this.valueEurCents,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (priceKey.present) {
      map['price_key'] = Variable<String>(priceKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (valueCents.present) {
      map['value_cents'] = Variable<int>(valueCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (valueEurCents.present) {
      map['value_eur_cents'] = Variable<int>(valueEurCents.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceEntriesCompanion(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('priceKey: $priceKey, ')
          ..write('source: $source, ')
          ..write('valueCents: $valueCents, ')
          ..write('currency: $currency, ')
          ..write('valueEurCents: $valueEurCents, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }
}

class $SnapshotEntriesTable extends SnapshotEntries
    with TableInfo<$SnapshotEntriesTable, SnapshotEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _portfolioIdMeta = const VerificationMeta(
    'portfolioId',
  );
  @override
  late final GeneratedColumn<String> portfolioId = GeneratedColumn<String>(
    'portfolio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardsCentsMeta = const VerificationMeta(
    'cardsCents',
  );
  @override
  late final GeneratedColumn<int> cardsCents = GeneratedColumn<int>(
    'cards_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sealedCentsMeta = const VerificationMeta(
    'sealedCents',
  );
  @override
  late final GeneratedColumn<int> sealedCents = GeneratedColumn<int>(
    'sealed_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _investedCentsMeta = const VerificationMeta(
    'investedCents',
  );
  @override
  late final GeneratedColumn<int> investedCents = GeneratedColumn<int>(
    'invested_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    portfolioId,
    date,
    totalCents,
    cardsCents,
    sealedCents,
    investedCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshot_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnapshotEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('portfolio_id')) {
      context.handle(
        _portfolioIdMeta,
        portfolioId.isAcceptableOrUnknown(
          data['portfolio_id']!,
          _portfolioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_portfolioIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('cards_cents')) {
      context.handle(
        _cardsCentsMeta,
        cardsCents.isAcceptableOrUnknown(data['cards_cents']!, _cardsCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_cardsCentsMeta);
    }
    if (data.containsKey('sealed_cents')) {
      context.handle(
        _sealedCentsMeta,
        sealedCents.isAcceptableOrUnknown(
          data['sealed_cents']!,
          _sealedCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sealedCentsMeta);
    }
    if (data.containsKey('invested_cents')) {
      context.handle(
        _investedCentsMeta,
        investedCents.isAcceptableOrUnknown(
          data['invested_cents']!,
          _investedCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investedCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {portfolioId, date};
  @override
  SnapshotEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnapshotEntry(
      portfolioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portfolio_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      cardsCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cards_cents'],
      )!,
      sealedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sealed_cents'],
      )!,
      investedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invested_cents'],
      )!,
    );
  }

  @override
  $SnapshotEntriesTable createAlias(String alias) {
    return $SnapshotEntriesTable(attachedDatabase, alias);
  }
}

class SnapshotEntry extends DataClass implements Insertable<SnapshotEntry> {
  final String portfolioId;
  final DateTime date;
  final int totalCents;
  final int cardsCents;
  final int sealedCents;
  final int investedCents;
  const SnapshotEntry({
    required this.portfolioId,
    required this.date,
    required this.totalCents,
    required this.cardsCents,
    required this.sealedCents,
    required this.investedCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['portfolio_id'] = Variable<String>(portfolioId);
    map['date'] = Variable<DateTime>(date);
    map['total_cents'] = Variable<int>(totalCents);
    map['cards_cents'] = Variable<int>(cardsCents);
    map['sealed_cents'] = Variable<int>(sealedCents);
    map['invested_cents'] = Variable<int>(investedCents);
    return map;
  }

  SnapshotEntriesCompanion toCompanion(bool nullToAbsent) {
    return SnapshotEntriesCompanion(
      portfolioId: Value(portfolioId),
      date: Value(date),
      totalCents: Value(totalCents),
      cardsCents: Value(cardsCents),
      sealedCents: Value(sealedCents),
      investedCents: Value(investedCents),
    );
  }

  factory SnapshotEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnapshotEntry(
      portfolioId: serializer.fromJson<String>(json['portfolioId']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      cardsCents: serializer.fromJson<int>(json['cardsCents']),
      sealedCents: serializer.fromJson<int>(json['sealedCents']),
      investedCents: serializer.fromJson<int>(json['investedCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'portfolioId': serializer.toJson<String>(portfolioId),
      'date': serializer.toJson<DateTime>(date),
      'totalCents': serializer.toJson<int>(totalCents),
      'cardsCents': serializer.toJson<int>(cardsCents),
      'sealedCents': serializer.toJson<int>(sealedCents),
      'investedCents': serializer.toJson<int>(investedCents),
    };
  }

  SnapshotEntry copyWith({
    String? portfolioId,
    DateTime? date,
    int? totalCents,
    int? cardsCents,
    int? sealedCents,
    int? investedCents,
  }) => SnapshotEntry(
    portfolioId: portfolioId ?? this.portfolioId,
    date: date ?? this.date,
    totalCents: totalCents ?? this.totalCents,
    cardsCents: cardsCents ?? this.cardsCents,
    sealedCents: sealedCents ?? this.sealedCents,
    investedCents: investedCents ?? this.investedCents,
  );
  SnapshotEntry copyWithCompanion(SnapshotEntriesCompanion data) {
    return SnapshotEntry(
      portfolioId: data.portfolioId.present
          ? data.portfolioId.value
          : this.portfolioId,
      date: data.date.present ? data.date.value : this.date,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      cardsCents: data.cardsCents.present
          ? data.cardsCents.value
          : this.cardsCents,
      sealedCents: data.sealedCents.present
          ? data.sealedCents.value
          : this.sealedCents,
      investedCents: data.investedCents.present
          ? data.investedCents.value
          : this.investedCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotEntry(')
          ..write('portfolioId: $portfolioId, ')
          ..write('date: $date, ')
          ..write('totalCents: $totalCents, ')
          ..write('cardsCents: $cardsCents, ')
          ..write('sealedCents: $sealedCents, ')
          ..write('investedCents: $investedCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    portfolioId,
    date,
    totalCents,
    cardsCents,
    sealedCents,
    investedCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnapshotEntry &&
          other.portfolioId == this.portfolioId &&
          other.date == this.date &&
          other.totalCents == this.totalCents &&
          other.cardsCents == this.cardsCents &&
          other.sealedCents == this.sealedCents &&
          other.investedCents == this.investedCents);
}

class SnapshotEntriesCompanion extends UpdateCompanion<SnapshotEntry> {
  final Value<String> portfolioId;
  final Value<DateTime> date;
  final Value<int> totalCents;
  final Value<int> cardsCents;
  final Value<int> sealedCents;
  final Value<int> investedCents;
  final Value<int> rowid;
  const SnapshotEntriesCompanion({
    this.portfolioId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.cardsCents = const Value.absent(),
    this.sealedCents = const Value.absent(),
    this.investedCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnapshotEntriesCompanion.insert({
    required String portfolioId,
    required DateTime date,
    required int totalCents,
    required int cardsCents,
    required int sealedCents,
    required int investedCents,
    this.rowid = const Value.absent(),
  }) : portfolioId = Value(portfolioId),
       date = Value(date),
       totalCents = Value(totalCents),
       cardsCents = Value(cardsCents),
       sealedCents = Value(sealedCents),
       investedCents = Value(investedCents);
  static Insertable<SnapshotEntry> custom({
    Expression<String>? portfolioId,
    Expression<DateTime>? date,
    Expression<int>? totalCents,
    Expression<int>? cardsCents,
    Expression<int>? sealedCents,
    Expression<int>? investedCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (portfolioId != null) 'portfolio_id': portfolioId,
      if (date != null) 'date': date,
      if (totalCents != null) 'total_cents': totalCents,
      if (cardsCents != null) 'cards_cents': cardsCents,
      if (sealedCents != null) 'sealed_cents': sealedCents,
      if (investedCents != null) 'invested_cents': investedCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnapshotEntriesCompanion copyWith({
    Value<String>? portfolioId,
    Value<DateTime>? date,
    Value<int>? totalCents,
    Value<int>? cardsCents,
    Value<int>? sealedCents,
    Value<int>? investedCents,
    Value<int>? rowid,
  }) {
    return SnapshotEntriesCompanion(
      portfolioId: portfolioId ?? this.portfolioId,
      date: date ?? this.date,
      totalCents: totalCents ?? this.totalCents,
      cardsCents: cardsCents ?? this.cardsCents,
      sealedCents: sealedCents ?? this.sealedCents,
      investedCents: investedCents ?? this.investedCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (portfolioId.present) {
      map['portfolio_id'] = Variable<String>(portfolioId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (cardsCents.present) {
      map['cards_cents'] = Variable<int>(cardsCents.value);
    }
    if (sealedCents.present) {
      map['sealed_cents'] = Variable<int>(sealedCents.value);
    }
    if (investedCents.present) {
      map['invested_cents'] = Variable<int>(investedCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotEntriesCompanion(')
          ..write('portfolioId: $portfolioId, ')
          ..write('date: $date, ')
          ..write('totalCents: $totalCents, ')
          ..write('cardsCents: $cardsCents, ')
          ..write('sealedCents: $sealedCents, ')
          ..write('investedCents: $investedCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardEntriesTable cardEntries = $CardEntriesTable(this);
  late final $SealedEntriesTable sealedEntries = $SealedEntriesTable(this);
  late final $HoldingEntriesTable holdingEntries = $HoldingEntriesTable(this);
  late final $PriceEntriesTable priceEntries = $PriceEntriesTable(this);
  late final $SnapshotEntriesTable snapshotEntries = $SnapshotEntriesTable(
    this,
  );
  late final Index priceLookup = Index(
    'price_lookup',
    'CREATE INDEX price_lookup ON price_entries (catalog_id, price_key, captured_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cardEntries,
    sealedEntries,
    holdingEntries,
    priceEntries,
    snapshotEntries,
    priceLookup,
  ];
}

typedef $$CardEntriesTableCreateCompanionBuilder =
    CardEntriesCompanion Function({
      required String id,
      required String setId,
      required String setName,
      required String localId,
      required String nameEn,
      Value<String?> nameDe,
      Value<String?> rarity,
      Value<String?> imageBase,
      Value<String?> imageBaseEn,
      Value<int?> setCardCount,
      Value<String> variants,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CardEntriesTableUpdateCompanionBuilder =
    CardEntriesCompanion Function({
      Value<String> id,
      Value<String> setId,
      Value<String> setName,
      Value<String> localId,
      Value<String> nameEn,
      Value<String?> nameDe,
      Value<String?> rarity,
      Value<String?> imageBase,
      Value<String?> imageBaseEn,
      Value<int?> setCardCount,
      Value<String> variants,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CardEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CardEntriesTable> {
  $$CardEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameDe => $composableBuilder(
    column: $table.nameDe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageBase => $composableBuilder(
    column: $table.imageBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageBaseEn => $composableBuilder(
    column: $table.imageBaseEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setCardCount => $composableBuilder(
    column: $table.setCardCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variants => $composableBuilder(
    column: $table.variants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardEntriesTable> {
  $$CardEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameDe => $composableBuilder(
    column: $table.nameDe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageBase => $composableBuilder(
    column: $table.imageBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageBaseEn => $composableBuilder(
    column: $table.imageBaseEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setCardCount => $composableBuilder(
    column: $table.setCardCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variants => $composableBuilder(
    column: $table.variants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardEntriesTable> {
  $$CardEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameDe =>
      $composableBuilder(column: $table.nameDe, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get imageBase =>
      $composableBuilder(column: $table.imageBase, builder: (column) => column);

  GeneratedColumn<String> get imageBaseEn => $composableBuilder(
    column: $table.imageBaseEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setCardCount => $composableBuilder(
    column: $table.setCardCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variants =>
      $composableBuilder(column: $table.variants, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CardEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardEntriesTable,
          CardEntry,
          $$CardEntriesTableFilterComposer,
          $$CardEntriesTableOrderingComposer,
          $$CardEntriesTableAnnotationComposer,
          $$CardEntriesTableCreateCompanionBuilder,
          $$CardEntriesTableUpdateCompanionBuilder,
          (
            CardEntry,
            BaseReferences<_$AppDatabase, $CardEntriesTable, CardEntry>,
          ),
          CardEntry,
          PrefetchHooks Function()
        > {
  $$CardEntriesTableTableManager(_$AppDatabase db, $CardEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> setId = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String?> nameDe = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
                Value<String?> imageBase = const Value.absent(),
                Value<String?> imageBaseEn = const Value.absent(),
                Value<int?> setCardCount = const Value.absent(),
                Value<String> variants = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardEntriesCompanion(
                id: id,
                setId: setId,
                setName: setName,
                localId: localId,
                nameEn: nameEn,
                nameDe: nameDe,
                rarity: rarity,
                imageBase: imageBase,
                imageBaseEn: imageBaseEn,
                setCardCount: setCardCount,
                variants: variants,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String setId,
                required String setName,
                required String localId,
                required String nameEn,
                Value<String?> nameDe = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
                Value<String?> imageBase = const Value.absent(),
                Value<String?> imageBaseEn = const Value.absent(),
                Value<int?> setCardCount = const Value.absent(),
                Value<String> variants = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CardEntriesCompanion.insert(
                id: id,
                setId: setId,
                setName: setName,
                localId: localId,
                nameEn: nameEn,
                nameDe: nameDe,
                rarity: rarity,
                imageBase: imageBase,
                imageBaseEn: imageBaseEn,
                setCardCount: setCardCount,
                variants: variants,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardEntriesTable,
      CardEntry,
      $$CardEntriesTableFilterComposer,
      $$CardEntriesTableOrderingComposer,
      $$CardEntriesTableAnnotationComposer,
      $$CardEntriesTableCreateCompanionBuilder,
      $$CardEntriesTableUpdateCompanionBuilder,
      (CardEntry, BaseReferences<_$AppDatabase, $CardEntriesTable, CardEntry>),
      CardEntry,
      PrefetchHooks Function()
    >;
typedef $$SealedEntriesTableCreateCompanionBuilder =
    SealedEntriesCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<String?> setId,
      Value<String?> setName,
      Value<String> language,
      Value<String?> image,
      Value<bool> isCustom,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$SealedEntriesTableUpdateCompanionBuilder =
    SealedEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> setId,
      Value<String?> setName,
      Value<String> language,
      Value<String?> image,
      Value<bool> isCustom,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$SealedEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SealedEntriesTable> {
  $$SealedEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SealedEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SealedEntriesTable> {
  $$SealedEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SealedEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SealedEntriesTable> {
  $$SealedEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$SealedEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SealedEntriesTable,
          SealedEntry,
          $$SealedEntriesTableFilterComposer,
          $$SealedEntriesTableOrderingComposer,
          $$SealedEntriesTableAnnotationComposer,
          $$SealedEntriesTableCreateCompanionBuilder,
          $$SealedEntriesTableUpdateCompanionBuilder,
          (
            SealedEntry,
            BaseReferences<_$AppDatabase, $SealedEntriesTable, SealedEntry>,
          ),
          SealedEntry,
          PrefetchHooks Function()
        > {
  $$SealedEntriesTableTableManager(_$AppDatabase db, $SealedEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SealedEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SealedEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SealedEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> setId = const Value.absent(),
                Value<String?> setName = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SealedEntriesCompanion(
                id: id,
                name: name,
                type: type,
                setId: setId,
                setName: setName,
                language: language,
                image: image,
                isCustom: isCustom,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<String?> setId = const Value.absent(),
                Value<String?> setName = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => SealedEntriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                setId: setId,
                setName: setName,
                language: language,
                image: image,
                isCustom: isCustom,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SealedEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SealedEntriesTable,
      SealedEntry,
      $$SealedEntriesTableFilterComposer,
      $$SealedEntriesTableOrderingComposer,
      $$SealedEntriesTableAnnotationComposer,
      $$SealedEntriesTableCreateCompanionBuilder,
      $$SealedEntriesTableUpdateCompanionBuilder,
      (
        SealedEntry,
        BaseReferences<_$AppDatabase, $SealedEntriesTable, SealedEntry>,
      ),
      SealedEntry,
      PrefetchHooks Function()
    >;
typedef $$HoldingEntriesTableCreateCompanionBuilder =
    HoldingEntriesCompanion Function({
      required String id,
      required String portfolioId,
      required String type,
      required String catalogId,
      required int quantity,
      Value<String> variant,
      Value<String> condition,
      Value<String?> graderCode,
      Value<double?> grade,
      Value<String?> certificateNumber,
      Value<int> purchasePriceCents,
      required DateTime purchaseDate,
      Value<String> priceMode,
      Value<int?> manualPriceCents,
      Value<DateTime?> manualPriceSetAt,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$HoldingEntriesTableUpdateCompanionBuilder =
    HoldingEntriesCompanion Function({
      Value<String> id,
      Value<String> portfolioId,
      Value<String> type,
      Value<String> catalogId,
      Value<int> quantity,
      Value<String> variant,
      Value<String> condition,
      Value<String?> graderCode,
      Value<double?> grade,
      Value<String?> certificateNumber,
      Value<int> purchasePriceCents,
      Value<DateTime> purchaseDate,
      Value<String> priceMode,
      Value<int?> manualPriceCents,
      Value<DateTime?> manualPriceSetAt,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HoldingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HoldingEntriesTable> {
  $$HoldingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portfolioId => $composableBuilder(
    column: $table.portfolioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graderCode => $composableBuilder(
    column: $table.graderCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certificateNumber => $composableBuilder(
    column: $table.certificateNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasePriceCents => $composableBuilder(
    column: $table.purchasePriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceMode => $composableBuilder(
    column: $table.priceMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manualPriceCents => $composableBuilder(
    column: $table.manualPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get manualPriceSetAt => $composableBuilder(
    column: $table.manualPriceSetAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HoldingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldingEntriesTable> {
  $$HoldingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portfolioId => $composableBuilder(
    column: $table.portfolioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graderCode => $composableBuilder(
    column: $table.graderCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certificateNumber => $composableBuilder(
    column: $table.certificateNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasePriceCents => $composableBuilder(
    column: $table.purchasePriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceMode => $composableBuilder(
    column: $table.priceMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualPriceCents => $composableBuilder(
    column: $table.manualPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get manualPriceSetAt => $composableBuilder(
    column: $table.manualPriceSetAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HoldingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldingEntriesTable> {
  $$HoldingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get portfolioId => $composableBuilder(
    column: $table.portfolioId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get graderCode => $composableBuilder(
    column: $table.graderCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get certificateNumber => $composableBuilder(
    column: $table.certificateNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purchasePriceCents => $composableBuilder(
    column: $table.purchasePriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priceMode =>
      $composableBuilder(column: $table.priceMode, builder: (column) => column);

  GeneratedColumn<int> get manualPriceCents => $composableBuilder(
    column: $table.manualPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get manualPriceSetAt => $composableBuilder(
    column: $table.manualPriceSetAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HoldingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldingEntriesTable,
          HoldingEntry,
          $$HoldingEntriesTableFilterComposer,
          $$HoldingEntriesTableOrderingComposer,
          $$HoldingEntriesTableAnnotationComposer,
          $$HoldingEntriesTableCreateCompanionBuilder,
          $$HoldingEntriesTableUpdateCompanionBuilder,
          (
            HoldingEntry,
            BaseReferences<_$AppDatabase, $HoldingEntriesTable, HoldingEntry>,
          ),
          HoldingEntry,
          PrefetchHooks Function()
        > {
  $$HoldingEntriesTableTableManager(
    _$AppDatabase db,
    $HoldingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> portfolioId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> variant = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String?> graderCode = const Value.absent(),
                Value<double?> grade = const Value.absent(),
                Value<String?> certificateNumber = const Value.absent(),
                Value<int> purchasePriceCents = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<String> priceMode = const Value.absent(),
                Value<int?> manualPriceCents = const Value.absent(),
                Value<DateTime?> manualPriceSetAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HoldingEntriesCompanion(
                id: id,
                portfolioId: portfolioId,
                type: type,
                catalogId: catalogId,
                quantity: quantity,
                variant: variant,
                condition: condition,
                graderCode: graderCode,
                grade: grade,
                certificateNumber: certificateNumber,
                purchasePriceCents: purchasePriceCents,
                purchaseDate: purchaseDate,
                priceMode: priceMode,
                manualPriceCents: manualPriceCents,
                manualPriceSetAt: manualPriceSetAt,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String portfolioId,
                required String type,
                required String catalogId,
                required int quantity,
                Value<String> variant = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String?> graderCode = const Value.absent(),
                Value<double?> grade = const Value.absent(),
                Value<String?> certificateNumber = const Value.absent(),
                Value<int> purchasePriceCents = const Value.absent(),
                required DateTime purchaseDate,
                Value<String> priceMode = const Value.absent(),
                Value<int?> manualPriceCents = const Value.absent(),
                Value<DateTime?> manualPriceSetAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HoldingEntriesCompanion.insert(
                id: id,
                portfolioId: portfolioId,
                type: type,
                catalogId: catalogId,
                quantity: quantity,
                variant: variant,
                condition: condition,
                graderCode: graderCode,
                grade: grade,
                certificateNumber: certificateNumber,
                purchasePriceCents: purchasePriceCents,
                purchaseDate: purchaseDate,
                priceMode: priceMode,
                manualPriceCents: manualPriceCents,
                manualPriceSetAt: manualPriceSetAt,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HoldingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldingEntriesTable,
      HoldingEntry,
      $$HoldingEntriesTableFilterComposer,
      $$HoldingEntriesTableOrderingComposer,
      $$HoldingEntriesTableAnnotationComposer,
      $$HoldingEntriesTableCreateCompanionBuilder,
      $$HoldingEntriesTableUpdateCompanionBuilder,
      (
        HoldingEntry,
        BaseReferences<_$AppDatabase, $HoldingEntriesTable, HoldingEntry>,
      ),
      HoldingEntry,
      PrefetchHooks Function()
    >;
typedef $$PriceEntriesTableCreateCompanionBuilder =
    PriceEntriesCompanion Function({
      Value<int> id,
      required String catalogId,
      required String priceKey,
      required String source,
      required int valueCents,
      Value<String> currency,
      required int valueEurCents,
      required DateTime capturedAt,
    });
typedef $$PriceEntriesTableUpdateCompanionBuilder =
    PriceEntriesCompanion Function({
      Value<int> id,
      Value<String> catalogId,
      Value<String> priceKey,
      Value<String> source,
      Value<int> valueCents,
      Value<String> currency,
      Value<int> valueEurCents,
      Value<DateTime> capturedAt,
    });

class $$PriceEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PriceEntriesTable> {
  $$PriceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceKey => $composableBuilder(
    column: $table.priceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valueCents => $composableBuilder(
    column: $table.valueCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valueEurCents => $composableBuilder(
    column: $table.valueEurCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceEntriesTable> {
  $$PriceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceKey => $composableBuilder(
    column: $table.priceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueCents => $composableBuilder(
    column: $table.valueCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueEurCents => $composableBuilder(
    column: $table.valueEurCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceEntriesTable> {
  $$PriceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<String> get priceKey =>
      $composableBuilder(column: $table.priceKey, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get valueCents => $composableBuilder(
    column: $table.valueCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get valueEurCents => $composableBuilder(
    column: $table.valueEurCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );
}

class $$PriceEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceEntriesTable,
          PriceEntry,
          $$PriceEntriesTableFilterComposer,
          $$PriceEntriesTableOrderingComposer,
          $$PriceEntriesTableAnnotationComposer,
          $$PriceEntriesTableCreateCompanionBuilder,
          $$PriceEntriesTableUpdateCompanionBuilder,
          (
            PriceEntry,
            BaseReferences<_$AppDatabase, $PriceEntriesTable, PriceEntry>,
          ),
          PriceEntry,
          PrefetchHooks Function()
        > {
  $$PriceEntriesTableTableManager(_$AppDatabase db, $PriceEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String> priceKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> valueCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> valueEurCents = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
              }) => PriceEntriesCompanion(
                id: id,
                catalogId: catalogId,
                priceKey: priceKey,
                source: source,
                valueCents: valueCents,
                currency: currency,
                valueEurCents: valueEurCents,
                capturedAt: capturedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String catalogId,
                required String priceKey,
                required String source,
                required int valueCents,
                Value<String> currency = const Value.absent(),
                required int valueEurCents,
                required DateTime capturedAt,
              }) => PriceEntriesCompanion.insert(
                id: id,
                catalogId: catalogId,
                priceKey: priceKey,
                source: source,
                valueCents: valueCents,
                currency: currency,
                valueEurCents: valueEurCents,
                capturedAt: capturedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceEntriesTable,
      PriceEntry,
      $$PriceEntriesTableFilterComposer,
      $$PriceEntriesTableOrderingComposer,
      $$PriceEntriesTableAnnotationComposer,
      $$PriceEntriesTableCreateCompanionBuilder,
      $$PriceEntriesTableUpdateCompanionBuilder,
      (
        PriceEntry,
        BaseReferences<_$AppDatabase, $PriceEntriesTable, PriceEntry>,
      ),
      PriceEntry,
      PrefetchHooks Function()
    >;
typedef $$SnapshotEntriesTableCreateCompanionBuilder =
    SnapshotEntriesCompanion Function({
      required String portfolioId,
      required DateTime date,
      required int totalCents,
      required int cardsCents,
      required int sealedCents,
      required int investedCents,
      Value<int> rowid,
    });
typedef $$SnapshotEntriesTableUpdateCompanionBuilder =
    SnapshotEntriesCompanion Function({
      Value<String> portfolioId,
      Value<DateTime> date,
      Value<int> totalCents,
      Value<int> cardsCents,
      Value<int> sealedCents,
      Value<int> investedCents,
      Value<int> rowid,
    });

class $$SnapshotEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotEntriesTable> {
  $$SnapshotEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get portfolioId => $composableBuilder(
    column: $table.portfolioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardsCents => $composableBuilder(
    column: $table.cardsCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sealedCents => $composableBuilder(
    column: $table.sealedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get investedCents => $composableBuilder(
    column: $table.investedCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnapshotEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotEntriesTable> {
  $$SnapshotEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get portfolioId => $composableBuilder(
    column: $table.portfolioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardsCents => $composableBuilder(
    column: $table.cardsCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sealedCents => $composableBuilder(
    column: $table.sealedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get investedCents => $composableBuilder(
    column: $table.investedCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnapshotEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotEntriesTable> {
  $$SnapshotEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get portfolioId => $composableBuilder(
    column: $table.portfolioId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardsCents => $composableBuilder(
    column: $table.cardsCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sealedCents => $composableBuilder(
    column: $table.sealedCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get investedCents => $composableBuilder(
    column: $table.investedCents,
    builder: (column) => column,
  );
}

class $$SnapshotEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnapshotEntriesTable,
          SnapshotEntry,
          $$SnapshotEntriesTableFilterComposer,
          $$SnapshotEntriesTableOrderingComposer,
          $$SnapshotEntriesTableAnnotationComposer,
          $$SnapshotEntriesTableCreateCompanionBuilder,
          $$SnapshotEntriesTableUpdateCompanionBuilder,
          (
            SnapshotEntry,
            BaseReferences<_$AppDatabase, $SnapshotEntriesTable, SnapshotEntry>,
          ),
          SnapshotEntry,
          PrefetchHooks Function()
        > {
  $$SnapshotEntriesTableTableManager(
    _$AppDatabase db,
    $SnapshotEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> portfolioId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> cardsCents = const Value.absent(),
                Value<int> sealedCents = const Value.absent(),
                Value<int> investedCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnapshotEntriesCompanion(
                portfolioId: portfolioId,
                date: date,
                totalCents: totalCents,
                cardsCents: cardsCents,
                sealedCents: sealedCents,
                investedCents: investedCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String portfolioId,
                required DateTime date,
                required int totalCents,
                required int cardsCents,
                required int sealedCents,
                required int investedCents,
                Value<int> rowid = const Value.absent(),
              }) => SnapshotEntriesCompanion.insert(
                portfolioId: portfolioId,
                date: date,
                totalCents: totalCents,
                cardsCents: cardsCents,
                sealedCents: sealedCents,
                investedCents: investedCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnapshotEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnapshotEntriesTable,
      SnapshotEntry,
      $$SnapshotEntriesTableFilterComposer,
      $$SnapshotEntriesTableOrderingComposer,
      $$SnapshotEntriesTableAnnotationComposer,
      $$SnapshotEntriesTableCreateCompanionBuilder,
      $$SnapshotEntriesTableUpdateCompanionBuilder,
      (
        SnapshotEntry,
        BaseReferences<_$AppDatabase, $SnapshotEntriesTable, SnapshotEntry>,
      ),
      SnapshotEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardEntriesTableTableManager get cardEntries =>
      $$CardEntriesTableTableManager(_db, _db.cardEntries);
  $$SealedEntriesTableTableManager get sealedEntries =>
      $$SealedEntriesTableTableManager(_db, _db.sealedEntries);
  $$HoldingEntriesTableTableManager get holdingEntries =>
      $$HoldingEntriesTableTableManager(_db, _db.holdingEntries);
  $$PriceEntriesTableTableManager get priceEntries =>
      $$PriceEntriesTableTableManager(_db, _db.priceEntries);
  $$SnapshotEntriesTableTableManager get snapshotEntries =>
      $$SnapshotEntriesTableTableManager(_db, _db.snapshotEntries);
}
