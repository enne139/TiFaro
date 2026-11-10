// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ArgomentiTable extends Argomenti
    with TableInfo<$ArgomentiTable, Argomento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArgomentiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coloreMeta = const VerificationMeta('colore');
  @override
  late final GeneratedColumn<int> colore = GeneratedColumn<int>(
    'colore',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconaMeta = const VerificationMeta('icona');
  @override
  late final GeneratedColumn<String> icona = GeneratedColumn<String>(
    'icona',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('etichetta'),
  );
  static const VerificationMeta _ordineMeta = const VerificationMeta('ordine');
  @override
  late final GeneratedColumn<int> ordine = GeneratedColumn<int>(
    'ordine',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _predefinitoMeta = const VerificationMeta(
    'predefinito',
  );
  @override
  late final GeneratedColumn<bool> predefinito = GeneratedColumn<bool>(
    'predefinito',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("predefinito" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _aggiornatoIlMeta = const VerificationMeta(
    'aggiornatoIl',
  );
  @override
  late final GeneratedColumn<DateTime> aggiornatoIl = GeneratedColumn<DateTime>(
    'aggiornato_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancellatoIlMeta = const VerificationMeta(
    'cancellatoIl',
  );
  @override
  late final GeneratedColumn<DateTime> cancellatoIl = GeneratedColumn<DateTime>(
    'cancellato_il',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    colore,
    icona,
    ordine,
    predefinito,
    aggiornatoIl,
    cancellatoIl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'argomenti';
  @override
  VerificationContext validateIntegrity(
    Insertable<Argomento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('colore')) {
      context.handle(
        _coloreMeta,
        colore.isAcceptableOrUnknown(data['colore']!, _coloreMeta),
      );
    }
    if (data.containsKey('icona')) {
      context.handle(
        _iconaMeta,
        icona.isAcceptableOrUnknown(data['icona']!, _iconaMeta),
      );
    }
    if (data.containsKey('ordine')) {
      context.handle(
        _ordineMeta,
        ordine.isAcceptableOrUnknown(data['ordine']!, _ordineMeta),
      );
    }
    if (data.containsKey('predefinito')) {
      context.handle(
        _predefinitoMeta,
        predefinito.isAcceptableOrUnknown(
          data['predefinito']!,
          _predefinitoMeta,
        ),
      );
    }
    if (data.containsKey('aggiornato_il')) {
      context.handle(
        _aggiornatoIlMeta,
        aggiornatoIl.isAcceptableOrUnknown(
          data['aggiornato_il']!,
          _aggiornatoIlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggiornatoIlMeta);
    }
    if (data.containsKey('cancellato_il')) {
      context.handle(
        _cancellatoIlMeta,
        cancellatoIl.isAcceptableOrUnknown(
          data['cancellato_il']!,
          _cancellatoIlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Argomento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Argomento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      colore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colore'],
      )!,
      icona: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icona'],
      )!,
      ordine: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordine'],
      )!,
      predefinito: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}predefinito'],
      )!,
      aggiornatoIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}aggiornato_il'],
      )!,
      cancellatoIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancellato_il'],
      ),
    );
  }

  @override
  $ArgomentiTable createAlias(String alias) {
    return $ArgomentiTable(attachedDatabase, alias);
  }
}

class Argomento extends DataClass implements Insertable<Argomento> {
  /// UUID, oppure un id fisso per quelli creati al primo avvio (voce 004).
  final String id;

  /// Il nome che si vede, per esempio "Ambulanza".
  final String nome;

  /// Indice in `paletteArgomenti`: si salva l'indice, non il colore, così la
  /// tavolozza può corrispondere ai colori di Google Calendar (voce 008).
  final int colore;

  /// Chiave di `iconeDisponibili`.
  final String icona;

  /// Posizione nell'elenco degli argomenti.
  final int ordine;

  /// L'argomento usato dalla cattura veloce quando non se ne scrive uno.
  /// Ce n'è sempre esattamente uno.
  final bool predefinito;

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  final DateTime aggiornatoIl;

  /// Se non è nullo l'argomento è stato tolto: la riga resta perché la
  /// cancellazione possa arrivare anche agli altri dispositivi (voce 003).
  final DateTime? cancellatoIl;
  const Argomento({
    required this.id,
    required this.nome,
    required this.colore,
    required this.icona,
    required this.ordine,
    required this.predefinito,
    required this.aggiornatoIl,
    this.cancellatoIl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['colore'] = Variable<int>(colore);
    map['icona'] = Variable<String>(icona);
    map['ordine'] = Variable<int>(ordine);
    map['predefinito'] = Variable<bool>(predefinito);
    map['aggiornato_il'] = Variable<DateTime>(aggiornatoIl);
    if (!nullToAbsent || cancellatoIl != null) {
      map['cancellato_il'] = Variable<DateTime>(cancellatoIl);
    }
    return map;
  }

  ArgomentiCompanion toCompanion(bool nullToAbsent) {
    return ArgomentiCompanion(
      id: Value(id),
      nome: Value(nome),
      colore: Value(colore),
      icona: Value(icona),
      ordine: Value(ordine),
      predefinito: Value(predefinito),
      aggiornatoIl: Value(aggiornatoIl),
      cancellatoIl: cancellatoIl == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellatoIl),
    );
  }

  factory Argomento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Argomento(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      colore: serializer.fromJson<int>(json['colore']),
      icona: serializer.fromJson<String>(json['icona']),
      ordine: serializer.fromJson<int>(json['ordine']),
      predefinito: serializer.fromJson<bool>(json['predefinito']),
      aggiornatoIl: serializer.fromJson<DateTime>(json['aggiornatoIl']),
      cancellatoIl: serializer.fromJson<DateTime?>(json['cancellatoIl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'colore': serializer.toJson<int>(colore),
      'icona': serializer.toJson<String>(icona),
      'ordine': serializer.toJson<int>(ordine),
      'predefinito': serializer.toJson<bool>(predefinito),
      'aggiornatoIl': serializer.toJson<DateTime>(aggiornatoIl),
      'cancellatoIl': serializer.toJson<DateTime?>(cancellatoIl),
    };
  }

  Argomento copyWith({
    String? id,
    String? nome,
    int? colore,
    String? icona,
    int? ordine,
    bool? predefinito,
    DateTime? aggiornatoIl,
    Value<DateTime?> cancellatoIl = const Value.absent(),
  }) => Argomento(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    colore: colore ?? this.colore,
    icona: icona ?? this.icona,
    ordine: ordine ?? this.ordine,
    predefinito: predefinito ?? this.predefinito,
    aggiornatoIl: aggiornatoIl ?? this.aggiornatoIl,
    cancellatoIl: cancellatoIl.present ? cancellatoIl.value : this.cancellatoIl,
  );
  Argomento copyWithCompanion(ArgomentiCompanion data) {
    return Argomento(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      colore: data.colore.present ? data.colore.value : this.colore,
      icona: data.icona.present ? data.icona.value : this.icona,
      ordine: data.ordine.present ? data.ordine.value : this.ordine,
      predefinito: data.predefinito.present
          ? data.predefinito.value
          : this.predefinito,
      aggiornatoIl: data.aggiornatoIl.present
          ? data.aggiornatoIl.value
          : this.aggiornatoIl,
      cancellatoIl: data.cancellatoIl.present
          ? data.cancellatoIl.value
          : this.cancellatoIl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Argomento(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('colore: $colore, ')
          ..write('icona: $icona, ')
          ..write('ordine: $ordine, ')
          ..write('predefinito: $predefinito, ')
          ..write('aggiornatoIl: $aggiornatoIl, ')
          ..write('cancellatoIl: $cancellatoIl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    colore,
    icona,
    ordine,
    predefinito,
    aggiornatoIl,
    cancellatoIl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Argomento &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.colore == this.colore &&
          other.icona == this.icona &&
          other.ordine == this.ordine &&
          other.predefinito == this.predefinito &&
          other.aggiornatoIl == this.aggiornatoIl &&
          other.cancellatoIl == this.cancellatoIl);
}

class ArgomentiCompanion extends UpdateCompanion<Argomento> {
  final Value<String> id;
  final Value<String> nome;
  final Value<int> colore;
  final Value<String> icona;
  final Value<int> ordine;
  final Value<bool> predefinito;
  final Value<DateTime> aggiornatoIl;
  final Value<DateTime?> cancellatoIl;
  final Value<int> rowid;
  const ArgomentiCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.colore = const Value.absent(),
    this.icona = const Value.absent(),
    this.ordine = const Value.absent(),
    this.predefinito = const Value.absent(),
    this.aggiornatoIl = const Value.absent(),
    this.cancellatoIl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArgomentiCompanion.insert({
    required String id,
    required String nome,
    this.colore = const Value.absent(),
    this.icona = const Value.absent(),
    this.ordine = const Value.absent(),
    this.predefinito = const Value.absent(),
    required DateTime aggiornatoIl,
    this.cancellatoIl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       aggiornatoIl = Value(aggiornatoIl);
  static Insertable<Argomento> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<int>? colore,
    Expression<String>? icona,
    Expression<int>? ordine,
    Expression<bool>? predefinito,
    Expression<DateTime>? aggiornatoIl,
    Expression<DateTime>? cancellatoIl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (colore != null) 'colore': colore,
      if (icona != null) 'icona': icona,
      if (ordine != null) 'ordine': ordine,
      if (predefinito != null) 'predefinito': predefinito,
      if (aggiornatoIl != null) 'aggiornato_il': aggiornatoIl,
      if (cancellatoIl != null) 'cancellato_il': cancellatoIl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArgomentiCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<int>? colore,
    Value<String>? icona,
    Value<int>? ordine,
    Value<bool>? predefinito,
    Value<DateTime>? aggiornatoIl,
    Value<DateTime?>? cancellatoIl,
    Value<int>? rowid,
  }) {
    return ArgomentiCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      colore: colore ?? this.colore,
      icona: icona ?? this.icona,
      ordine: ordine ?? this.ordine,
      predefinito: predefinito ?? this.predefinito,
      aggiornatoIl: aggiornatoIl ?? this.aggiornatoIl,
      cancellatoIl: cancellatoIl ?? this.cancellatoIl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (colore.present) {
      map['colore'] = Variable<int>(colore.value);
    }
    if (icona.present) {
      map['icona'] = Variable<String>(icona.value);
    }
    if (ordine.present) {
      map['ordine'] = Variable<int>(ordine.value);
    }
    if (predefinito.present) {
      map['predefinito'] = Variable<bool>(predefinito.value);
    }
    if (aggiornatoIl.present) {
      map['aggiornato_il'] = Variable<DateTime>(aggiornatoIl.value);
    }
    if (cancellatoIl.present) {
      map['cancellato_il'] = Variable<DateTime>(cancellatoIl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArgomentiCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('colore: $colore, ')
          ..write('icona: $icona, ')
          ..write('ordine: $ordine, ')
          ..write('predefinito: $predefinito, ')
          ..write('aggiornatoIl: $aggiornatoIl, ')
          ..write('cancellatoIl: $cancellatoIl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TipologieTable extends Tipologie
    with TableInfo<$TipologieTable, Tipologia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipologieTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconaMeta = const VerificationMeta('icona');
  @override
  late final GeneratedColumn<String> icona = GeneratedColumn<String>(
    'icona',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('etichetta'),
  );
  static const VerificationMeta _aggiornataIlMeta = const VerificationMeta(
    'aggiornataIl',
  );
  @override
  late final GeneratedColumn<DateTime> aggiornataIl = GeneratedColumn<DateTime>(
    'aggiornata_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancellataIlMeta = const VerificationMeta(
    'cancellataIl',
  );
  @override
  late final GeneratedColumn<DateTime> cancellataIl = GeneratedColumn<DateTime>(
    'cancellata_il',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    icona,
    aggiornataIl,
    cancellataIl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tipologie';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tipologia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('icona')) {
      context.handle(
        _iconaMeta,
        icona.isAcceptableOrUnknown(data['icona']!, _iconaMeta),
      );
    }
    if (data.containsKey('aggiornata_il')) {
      context.handle(
        _aggiornataIlMeta,
        aggiornataIl.isAcceptableOrUnknown(
          data['aggiornata_il']!,
          _aggiornataIlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggiornataIlMeta);
    }
    if (data.containsKey('cancellata_il')) {
      context.handle(
        _cancellataIlMeta,
        cancellataIl.isAcceptableOrUnknown(
          data['cancellata_il']!,
          _cancellataIlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tipologia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tipologia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      icona: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icona'],
      )!,
      aggiornataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}aggiornata_il'],
      )!,
      cancellataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancellata_il'],
      ),
    );
  }

  @override
  $TipologieTable createAlias(String alias) {
    return $TipologieTable(attachedDatabase, alias);
  }
}

class Tipologia extends DataClass implements Insertable<Tipologia> {
  /// UUID, oppure un id fisso per quelle create al primo avvio (voce 004).
  final String id;

  /// Il nome che si vede, per esempio "Telefonata".
  final String nome;

  /// Chiave di `iconeDisponibili`.
  final String icona;

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  final DateTime aggiornataIl;

  /// Se non è nullo la tipologia è stata tolta (voce 003).
  final DateTime? cancellataIl;
  const Tipologia({
    required this.id,
    required this.nome,
    required this.icona,
    required this.aggiornataIl,
    this.cancellataIl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['icona'] = Variable<String>(icona);
    map['aggiornata_il'] = Variable<DateTime>(aggiornataIl);
    if (!nullToAbsent || cancellataIl != null) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl);
    }
    return map;
  }

  TipologieCompanion toCompanion(bool nullToAbsent) {
    return TipologieCompanion(
      id: Value(id),
      nome: Value(nome),
      icona: Value(icona),
      aggiornataIl: Value(aggiornataIl),
      cancellataIl: cancellataIl == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellataIl),
    );
  }

  factory Tipologia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tipologia(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      icona: serializer.fromJson<String>(json['icona']),
      aggiornataIl: serializer.fromJson<DateTime>(json['aggiornataIl']),
      cancellataIl: serializer.fromJson<DateTime?>(json['cancellataIl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'icona': serializer.toJson<String>(icona),
      'aggiornataIl': serializer.toJson<DateTime>(aggiornataIl),
      'cancellataIl': serializer.toJson<DateTime?>(cancellataIl),
    };
  }

  Tipologia copyWith({
    String? id,
    String? nome,
    String? icona,
    DateTime? aggiornataIl,
    Value<DateTime?> cancellataIl = const Value.absent(),
  }) => Tipologia(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    icona: icona ?? this.icona,
    aggiornataIl: aggiornataIl ?? this.aggiornataIl,
    cancellataIl: cancellataIl.present ? cancellataIl.value : this.cancellataIl,
  );
  Tipologia copyWithCompanion(TipologieCompanion data) {
    return Tipologia(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      icona: data.icona.present ? data.icona.value : this.icona,
      aggiornataIl: data.aggiornataIl.present
          ? data.aggiornataIl.value
          : this.aggiornataIl,
      cancellataIl: data.cancellataIl.present
          ? data.cancellataIl.value
          : this.cancellataIl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tipologia(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('icona: $icona, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, icona, aggiornataIl, cancellataIl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tipologia &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.icona == this.icona &&
          other.aggiornataIl == this.aggiornataIl &&
          other.cancellataIl == this.cancellataIl);
}

class TipologieCompanion extends UpdateCompanion<Tipologia> {
  final Value<String> id;
  final Value<String> nome;
  final Value<String> icona;
  final Value<DateTime> aggiornataIl;
  final Value<DateTime?> cancellataIl;
  final Value<int> rowid;
  const TipologieCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.icona = const Value.absent(),
    this.aggiornataIl = const Value.absent(),
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TipologieCompanion.insert({
    required String id,
    required String nome,
    this.icona = const Value.absent(),
    required DateTime aggiornataIl,
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       aggiornataIl = Value(aggiornataIl);
  static Insertable<Tipologia> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<String>? icona,
    Expression<DateTime>? aggiornataIl,
    Expression<DateTime>? cancellataIl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (icona != null) 'icona': icona,
      if (aggiornataIl != null) 'aggiornata_il': aggiornataIl,
      if (cancellataIl != null) 'cancellata_il': cancellataIl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TipologieCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<String>? icona,
    Value<DateTime>? aggiornataIl,
    Value<DateTime?>? cancellataIl,
    Value<int>? rowid,
  }) {
    return TipologieCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      icona: icona ?? this.icona,
      aggiornataIl: aggiornataIl ?? this.aggiornataIl,
      cancellataIl: cancellataIl ?? this.cancellataIl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (icona.present) {
      map['icona'] = Variable<String>(icona.value);
    }
    if (aggiornataIl.present) {
      map['aggiornata_il'] = Variable<DateTime>(aggiornataIl.value);
    }
    if (cancellataIl.present) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipologieCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('icona: $icona, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelliTable extends Modelli with TableInfo<$ModelliTable, Modello> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelliTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descrizioneMeta = const VerificationMeta(
    'descrizione',
  );
  @override
  late final GeneratedColumn<String> descrizione = GeneratedColumn<String>(
    'descrizione',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _argomentoIdMeta = const VerificationMeta(
    'argomentoId',
  );
  @override
  late final GeneratedColumn<String> argomentoId = GeneratedColumn<String>(
    'argomento_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES argomenti (id)',
    ),
  );
  static const VerificationMeta _tipologiaIdMeta = const VerificationMeta(
    'tipologiaId',
  );
  @override
  late final GeneratedColumn<String> tipologiaId = GeneratedColumn<String>(
    'tipologia_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tipologie (id)',
    ),
  );
  static const VerificationMeta _giorniMeta = const VerificationMeta('giorni');
  @override
  late final GeneratedColumn<int> giorni = GeneratedColumn<int>(
    'giorni',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minutiMeta = const VerificationMeta('minuti');
  @override
  late final GeneratedColumn<int> minuti = GeneratedColumn<int>(
    'minuti',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nelCalendarioMeta = const VerificationMeta(
    'nelCalendario',
  );
  @override
  late final GeneratedColumn<bool> nelCalendario = GeneratedColumn<bool>(
    'nel_calendario',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nel_calendario" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _aggiornatoIlMeta = const VerificationMeta(
    'aggiornatoIl',
  );
  @override
  late final GeneratedColumn<DateTime> aggiornatoIl = GeneratedColumn<DateTime>(
    'aggiornato_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancellatoIlMeta = const VerificationMeta(
    'cancellatoIl',
  );
  @override
  late final GeneratedColumn<DateTime> cancellatoIl = GeneratedColumn<DateTime>(
    'cancellato_il',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    descrizione,
    argomentoId,
    tipologiaId,
    giorni,
    minuti,
    nelCalendario,
    aggiornatoIl,
    cancellatoIl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modelli';
  @override
  VerificationContext validateIntegrity(
    Insertable<Modello> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('descrizione')) {
      context.handle(
        _descrizioneMeta,
        descrizione.isAcceptableOrUnknown(
          data['descrizione']!,
          _descrizioneMeta,
        ),
      );
    }
    if (data.containsKey('argomento_id')) {
      context.handle(
        _argomentoIdMeta,
        argomentoId.isAcceptableOrUnknown(
          data['argomento_id']!,
          _argomentoIdMeta,
        ),
      );
    }
    if (data.containsKey('tipologia_id')) {
      context.handle(
        _tipologiaIdMeta,
        tipologiaId.isAcceptableOrUnknown(
          data['tipologia_id']!,
          _tipologiaIdMeta,
        ),
      );
    }
    if (data.containsKey('giorni')) {
      context.handle(
        _giorniMeta,
        giorni.isAcceptableOrUnknown(data['giorni']!, _giorniMeta),
      );
    }
    if (data.containsKey('minuti')) {
      context.handle(
        _minutiMeta,
        minuti.isAcceptableOrUnknown(data['minuti']!, _minutiMeta),
      );
    }
    if (data.containsKey('nel_calendario')) {
      context.handle(
        _nelCalendarioMeta,
        nelCalendario.isAcceptableOrUnknown(
          data['nel_calendario']!,
          _nelCalendarioMeta,
        ),
      );
    }
    if (data.containsKey('aggiornato_il')) {
      context.handle(
        _aggiornatoIlMeta,
        aggiornatoIl.isAcceptableOrUnknown(
          data['aggiornato_il']!,
          _aggiornatoIlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggiornatoIlMeta);
    }
    if (data.containsKey('cancellato_il')) {
      context.handle(
        _cancellatoIlMeta,
        cancellatoIl.isAcceptableOrUnknown(
          data['cancellato_il']!,
          _cancellatoIlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Modello map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Modello(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      descrizione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descrizione'],
      )!,
      argomentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}argomento_id'],
      ),
      tipologiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipologia_id'],
      ),
      giorni: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}giorni'],
      ),
      minuti: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minuti'],
      ),
      nelCalendario: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nel_calendario'],
      )!,
      aggiornatoIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}aggiornato_il'],
      )!,
      cancellatoIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancellato_il'],
      ),
    );
  }

  @override
  $ModelliTable createAlias(String alias) {
    return $ModelliTable(attachedDatabase, alias);
  }
}

class Modello extends DataClass implements Insertable<Modello> {
  /// UUID.
  final String id;

  /// Il nome, che è anche il titolo dell'attività creata se nella cattura
  /// non se ne scrive un altro. Con `/nome` si sceglie nella cattura veloce.
  final String nome;

  /// La descrizione dell'attività creata.
  final String descrizione;

  /// L'argomento dell'attività creata; nullo vuol dire "quello della
  /// cattura" (scritto, scelto o il predefinito).
  final String? argomentoId;

  /// La tipologia dell'attività creata, facoltativa.
  final String? tipologiaId;

  /// Quanti giorni dopo la creazione scade l'attività; nullo se non ha una
  /// scadenza (voce 017).
  final int? giorni;

  /// L'ora della scadenza in minuti dalla mezzanotte; nulla se conta solo il
  /// giorno.
  final int? minuti;

  /// Se l'attività creata va nel calendario.
  final bool nelCalendario;

  /// Ultima modifica, per la sincronizzazione (voce 003).
  final DateTime aggiornatoIl;

  /// Se non è nullo il modello è stato tolto (voce 003).
  final DateTime? cancellatoIl;
  const Modello({
    required this.id,
    required this.nome,
    required this.descrizione,
    this.argomentoId,
    this.tipologiaId,
    this.giorni,
    this.minuti,
    required this.nelCalendario,
    required this.aggiornatoIl,
    this.cancellatoIl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['descrizione'] = Variable<String>(descrizione);
    if (!nullToAbsent || argomentoId != null) {
      map['argomento_id'] = Variable<String>(argomentoId);
    }
    if (!nullToAbsent || tipologiaId != null) {
      map['tipologia_id'] = Variable<String>(tipologiaId);
    }
    if (!nullToAbsent || giorni != null) {
      map['giorni'] = Variable<int>(giorni);
    }
    if (!nullToAbsent || minuti != null) {
      map['minuti'] = Variable<int>(minuti);
    }
    map['nel_calendario'] = Variable<bool>(nelCalendario);
    map['aggiornato_il'] = Variable<DateTime>(aggiornatoIl);
    if (!nullToAbsent || cancellatoIl != null) {
      map['cancellato_il'] = Variable<DateTime>(cancellatoIl);
    }
    return map;
  }

  ModelliCompanion toCompanion(bool nullToAbsent) {
    return ModelliCompanion(
      id: Value(id),
      nome: Value(nome),
      descrizione: Value(descrizione),
      argomentoId: argomentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(argomentoId),
      tipologiaId: tipologiaId == null && nullToAbsent
          ? const Value.absent()
          : Value(tipologiaId),
      giorni: giorni == null && nullToAbsent
          ? const Value.absent()
          : Value(giorni),
      minuti: minuti == null && nullToAbsent
          ? const Value.absent()
          : Value(minuti),
      nelCalendario: Value(nelCalendario),
      aggiornatoIl: Value(aggiornatoIl),
      cancellatoIl: cancellatoIl == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellatoIl),
    );
  }

  factory Modello.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Modello(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      descrizione: serializer.fromJson<String>(json['descrizione']),
      argomentoId: serializer.fromJson<String?>(json['argomentoId']),
      tipologiaId: serializer.fromJson<String?>(json['tipologiaId']),
      giorni: serializer.fromJson<int?>(json['giorni']),
      minuti: serializer.fromJson<int?>(json['minuti']),
      nelCalendario: serializer.fromJson<bool>(json['nelCalendario']),
      aggiornatoIl: serializer.fromJson<DateTime>(json['aggiornatoIl']),
      cancellatoIl: serializer.fromJson<DateTime?>(json['cancellatoIl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'descrizione': serializer.toJson<String>(descrizione),
      'argomentoId': serializer.toJson<String?>(argomentoId),
      'tipologiaId': serializer.toJson<String?>(tipologiaId),
      'giorni': serializer.toJson<int?>(giorni),
      'minuti': serializer.toJson<int?>(minuti),
      'nelCalendario': serializer.toJson<bool>(nelCalendario),
      'aggiornatoIl': serializer.toJson<DateTime>(aggiornatoIl),
      'cancellatoIl': serializer.toJson<DateTime?>(cancellatoIl),
    };
  }

  Modello copyWith({
    String? id,
    String? nome,
    String? descrizione,
    Value<String?> argomentoId = const Value.absent(),
    Value<String?> tipologiaId = const Value.absent(),
    Value<int?> giorni = const Value.absent(),
    Value<int?> minuti = const Value.absent(),
    bool? nelCalendario,
    DateTime? aggiornatoIl,
    Value<DateTime?> cancellatoIl = const Value.absent(),
  }) => Modello(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    descrizione: descrizione ?? this.descrizione,
    argomentoId: argomentoId.present ? argomentoId.value : this.argomentoId,
    tipologiaId: tipologiaId.present ? tipologiaId.value : this.tipologiaId,
    giorni: giorni.present ? giorni.value : this.giorni,
    minuti: minuti.present ? minuti.value : this.minuti,
    nelCalendario: nelCalendario ?? this.nelCalendario,
    aggiornatoIl: aggiornatoIl ?? this.aggiornatoIl,
    cancellatoIl: cancellatoIl.present ? cancellatoIl.value : this.cancellatoIl,
  );
  Modello copyWithCompanion(ModelliCompanion data) {
    return Modello(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      descrizione: data.descrizione.present
          ? data.descrizione.value
          : this.descrizione,
      argomentoId: data.argomentoId.present
          ? data.argomentoId.value
          : this.argomentoId,
      tipologiaId: data.tipologiaId.present
          ? data.tipologiaId.value
          : this.tipologiaId,
      giorni: data.giorni.present ? data.giorni.value : this.giorni,
      minuti: data.minuti.present ? data.minuti.value : this.minuti,
      nelCalendario: data.nelCalendario.present
          ? data.nelCalendario.value
          : this.nelCalendario,
      aggiornatoIl: data.aggiornatoIl.present
          ? data.aggiornatoIl.value
          : this.aggiornatoIl,
      cancellatoIl: data.cancellatoIl.present
          ? data.cancellatoIl.value
          : this.cancellatoIl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Modello(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('argomentoId: $argomentoId, ')
          ..write('tipologiaId: $tipologiaId, ')
          ..write('giorni: $giorni, ')
          ..write('minuti: $minuti, ')
          ..write('nelCalendario: $nelCalendario, ')
          ..write('aggiornatoIl: $aggiornatoIl, ')
          ..write('cancellatoIl: $cancellatoIl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    descrizione,
    argomentoId,
    tipologiaId,
    giorni,
    minuti,
    nelCalendario,
    aggiornatoIl,
    cancellatoIl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Modello &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.descrizione == this.descrizione &&
          other.argomentoId == this.argomentoId &&
          other.tipologiaId == this.tipologiaId &&
          other.giorni == this.giorni &&
          other.minuti == this.minuti &&
          other.nelCalendario == this.nelCalendario &&
          other.aggiornatoIl == this.aggiornatoIl &&
          other.cancellatoIl == this.cancellatoIl);
}

class ModelliCompanion extends UpdateCompanion<Modello> {
  final Value<String> id;
  final Value<String> nome;
  final Value<String> descrizione;
  final Value<String?> argomentoId;
  final Value<String?> tipologiaId;
  final Value<int?> giorni;
  final Value<int?> minuti;
  final Value<bool> nelCalendario;
  final Value<DateTime> aggiornatoIl;
  final Value<DateTime?> cancellatoIl;
  final Value<int> rowid;
  const ModelliCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.descrizione = const Value.absent(),
    this.argomentoId = const Value.absent(),
    this.tipologiaId = const Value.absent(),
    this.giorni = const Value.absent(),
    this.minuti = const Value.absent(),
    this.nelCalendario = const Value.absent(),
    this.aggiornatoIl = const Value.absent(),
    this.cancellatoIl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelliCompanion.insert({
    required String id,
    required String nome,
    this.descrizione = const Value.absent(),
    this.argomentoId = const Value.absent(),
    this.tipologiaId = const Value.absent(),
    this.giorni = const Value.absent(),
    this.minuti = const Value.absent(),
    this.nelCalendario = const Value.absent(),
    required DateTime aggiornatoIl,
    this.cancellatoIl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       aggiornatoIl = Value(aggiornatoIl);
  static Insertable<Modello> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<String>? descrizione,
    Expression<String>? argomentoId,
    Expression<String>? tipologiaId,
    Expression<int>? giorni,
    Expression<int>? minuti,
    Expression<bool>? nelCalendario,
    Expression<DateTime>? aggiornatoIl,
    Expression<DateTime>? cancellatoIl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (descrizione != null) 'descrizione': descrizione,
      if (argomentoId != null) 'argomento_id': argomentoId,
      if (tipologiaId != null) 'tipologia_id': tipologiaId,
      if (giorni != null) 'giorni': giorni,
      if (minuti != null) 'minuti': minuti,
      if (nelCalendario != null) 'nel_calendario': nelCalendario,
      if (aggiornatoIl != null) 'aggiornato_il': aggiornatoIl,
      if (cancellatoIl != null) 'cancellato_il': cancellatoIl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelliCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<String>? descrizione,
    Value<String?>? argomentoId,
    Value<String?>? tipologiaId,
    Value<int?>? giorni,
    Value<int?>? minuti,
    Value<bool>? nelCalendario,
    Value<DateTime>? aggiornatoIl,
    Value<DateTime?>? cancellatoIl,
    Value<int>? rowid,
  }) {
    return ModelliCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      argomentoId: argomentoId ?? this.argomentoId,
      tipologiaId: tipologiaId ?? this.tipologiaId,
      giorni: giorni ?? this.giorni,
      minuti: minuti ?? this.minuti,
      nelCalendario: nelCalendario ?? this.nelCalendario,
      aggiornatoIl: aggiornatoIl ?? this.aggiornatoIl,
      cancellatoIl: cancellatoIl ?? this.cancellatoIl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (descrizione.present) {
      map['descrizione'] = Variable<String>(descrizione.value);
    }
    if (argomentoId.present) {
      map['argomento_id'] = Variable<String>(argomentoId.value);
    }
    if (tipologiaId.present) {
      map['tipologia_id'] = Variable<String>(tipologiaId.value);
    }
    if (giorni.present) {
      map['giorni'] = Variable<int>(giorni.value);
    }
    if (minuti.present) {
      map['minuti'] = Variable<int>(minuti.value);
    }
    if (nelCalendario.present) {
      map['nel_calendario'] = Variable<bool>(nelCalendario.value);
    }
    if (aggiornatoIl.present) {
      map['aggiornato_il'] = Variable<DateTime>(aggiornatoIl.value);
    }
    if (cancellatoIl.present) {
      map['cancellato_il'] = Variable<DateTime>(cancellatoIl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelliCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('argomentoId: $argomentoId, ')
          ..write('tipologiaId: $tipologiaId, ')
          ..write('giorni: $giorni, ')
          ..write('minuti: $minuti, ')
          ..write('nelCalendario: $nelCalendario, ')
          ..write('aggiornatoIl: $aggiornatoIl, ')
          ..write('cancellatoIl: $cancellatoIl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VociModelloTable extends VociModello
    with TableInfo<$VociModelloTable, VoceModello> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VociModelloTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelloIdMeta = const VerificationMeta(
    'modelloId',
  );
  @override
  late final GeneratedColumn<String> modelloId = GeneratedColumn<String>(
    'modello_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES modelli (id)',
    ),
  );
  static const VerificationMeta _genitoreIdMeta = const VerificationMeta(
    'genitoreId',
  );
  @override
  late final GeneratedColumn<String> genitoreId = GeneratedColumn<String>(
    'genitore_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES voci_modello (id)',
    ),
  );
  static const VerificationMeta _titoloMeta = const VerificationMeta('titolo');
  @override
  late final GeneratedColumn<String> titolo = GeneratedColumn<String>(
    'titolo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descrizioneMeta = const VerificationMeta(
    'descrizione',
  );
  @override
  late final GeneratedColumn<String> descrizione = GeneratedColumn<String>(
    'descrizione',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tipologiaIdMeta = const VerificationMeta(
    'tipologiaId',
  );
  @override
  late final GeneratedColumn<String> tipologiaId = GeneratedColumn<String>(
    'tipologia_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tipologie (id)',
    ),
  );
  static const VerificationMeta _giorniMeta = const VerificationMeta('giorni');
  @override
  late final GeneratedColumn<int> giorni = GeneratedColumn<int>(
    'giorni',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minutiMeta = const VerificationMeta('minuti');
  @override
  late final GeneratedColumn<int> minuti = GeneratedColumn<int>(
    'minuti',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nelCalendarioMeta = const VerificationMeta(
    'nelCalendario',
  );
  @override
  late final GeneratedColumn<bool> nelCalendario = GeneratedColumn<bool>(
    'nel_calendario',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nel_calendario" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ordineMeta = const VerificationMeta('ordine');
  @override
  late final GeneratedColumn<int> ordine = GeneratedColumn<int>(
    'ordine',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aggiornataIlMeta = const VerificationMeta(
    'aggiornataIl',
  );
  @override
  late final GeneratedColumn<DateTime> aggiornataIl = GeneratedColumn<DateTime>(
    'aggiornata_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancellataIlMeta = const VerificationMeta(
    'cancellataIl',
  );
  @override
  late final GeneratedColumn<DateTime> cancellataIl = GeneratedColumn<DateTime>(
    'cancellata_il',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelloId,
    genitoreId,
    titolo,
    descrizione,
    tipologiaId,
    giorni,
    minuti,
    nelCalendario,
    ordine,
    aggiornataIl,
    cancellataIl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voci_modello';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoceModello> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('modello_id')) {
      context.handle(
        _modelloIdMeta,
        modelloId.isAcceptableOrUnknown(data['modello_id']!, _modelloIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelloIdMeta);
    }
    if (data.containsKey('genitore_id')) {
      context.handle(
        _genitoreIdMeta,
        genitoreId.isAcceptableOrUnknown(data['genitore_id']!, _genitoreIdMeta),
      );
    }
    if (data.containsKey('titolo')) {
      context.handle(
        _titoloMeta,
        titolo.isAcceptableOrUnknown(data['titolo']!, _titoloMeta),
      );
    } else if (isInserting) {
      context.missing(_titoloMeta);
    }
    if (data.containsKey('descrizione')) {
      context.handle(
        _descrizioneMeta,
        descrizione.isAcceptableOrUnknown(
          data['descrizione']!,
          _descrizioneMeta,
        ),
      );
    }
    if (data.containsKey('tipologia_id')) {
      context.handle(
        _tipologiaIdMeta,
        tipologiaId.isAcceptableOrUnknown(
          data['tipologia_id']!,
          _tipologiaIdMeta,
        ),
      );
    }
    if (data.containsKey('giorni')) {
      context.handle(
        _giorniMeta,
        giorni.isAcceptableOrUnknown(data['giorni']!, _giorniMeta),
      );
    }
    if (data.containsKey('minuti')) {
      context.handle(
        _minutiMeta,
        minuti.isAcceptableOrUnknown(data['minuti']!, _minutiMeta),
      );
    }
    if (data.containsKey('nel_calendario')) {
      context.handle(
        _nelCalendarioMeta,
        nelCalendario.isAcceptableOrUnknown(
          data['nel_calendario']!,
          _nelCalendarioMeta,
        ),
      );
    }
    if (data.containsKey('ordine')) {
      context.handle(
        _ordineMeta,
        ordine.isAcceptableOrUnknown(data['ordine']!, _ordineMeta),
      );
    }
    if (data.containsKey('aggiornata_il')) {
      context.handle(
        _aggiornataIlMeta,
        aggiornataIl.isAcceptableOrUnknown(
          data['aggiornata_il']!,
          _aggiornataIlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggiornataIlMeta);
    }
    if (data.containsKey('cancellata_il')) {
      context.handle(
        _cancellataIlMeta,
        cancellataIl.isAcceptableOrUnknown(
          data['cancellata_il']!,
          _cancellataIlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoceModello map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoceModello(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modelloId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modello_id'],
      )!,
      genitoreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genitore_id'],
      ),
      titolo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titolo'],
      )!,
      descrizione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descrizione'],
      )!,
      tipologiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipologia_id'],
      ),
      giorni: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}giorni'],
      ),
      minuti: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minuti'],
      ),
      nelCalendario: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nel_calendario'],
      )!,
      ordine: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordine'],
      )!,
      aggiornataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}aggiornata_il'],
      )!,
      cancellataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancellata_il'],
      ),
    );
  }

  @override
  $VociModelloTable createAlias(String alias) {
    return $VociModelloTable(attachedDatabase, alias);
  }
}

class VoceModello extends DataClass implements Insertable<VoceModello> {
  /// UUID.
  final String id;

  /// Il modello a cui appartiene.
  final String modelloId;

  /// La voce di cui questa è una sotto-voce; nulla per le figlie dirette
  /// dell'attività principale (cioè del modello).
  final String? genitoreId;

  /// Il titolo della sotto-attività creata.
  final String titolo;

  /// La descrizione della sotto-attività creata.
  final String descrizione;

  /// La tipologia, facoltativa.
  final String? tipologiaId;

  /// Giorni rispetto alla scadenza della principale (o alla creazione, se la
  /// principale non ha scadenza): negativi prima, positivi dopo. Nullo se la
  /// sotto-attività non ha scadenza (voce 017).
  final int? giorni;

  /// L'ora della scadenza in minuti dalla mezzanotte; nulla se conta solo il
  /// giorno.
  final int? minuti;

  /// Se la sotto-attività creata va nel calendario.
  final bool nelCalendario;

  /// Posizione fra le sorelle.
  final int ordine;

  /// Ultima modifica, per la sincronizzazione (voce 003).
  final DateTime aggiornataIl;

  /// Se non è nulla la voce è stata tolta (voce 003).
  final DateTime? cancellataIl;
  const VoceModello({
    required this.id,
    required this.modelloId,
    this.genitoreId,
    required this.titolo,
    required this.descrizione,
    this.tipologiaId,
    this.giorni,
    this.minuti,
    required this.nelCalendario,
    required this.ordine,
    required this.aggiornataIl,
    this.cancellataIl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modello_id'] = Variable<String>(modelloId);
    if (!nullToAbsent || genitoreId != null) {
      map['genitore_id'] = Variable<String>(genitoreId);
    }
    map['titolo'] = Variable<String>(titolo);
    map['descrizione'] = Variable<String>(descrizione);
    if (!nullToAbsent || tipologiaId != null) {
      map['tipologia_id'] = Variable<String>(tipologiaId);
    }
    if (!nullToAbsent || giorni != null) {
      map['giorni'] = Variable<int>(giorni);
    }
    if (!nullToAbsent || minuti != null) {
      map['minuti'] = Variable<int>(minuti);
    }
    map['nel_calendario'] = Variable<bool>(nelCalendario);
    map['ordine'] = Variable<int>(ordine);
    map['aggiornata_il'] = Variable<DateTime>(aggiornataIl);
    if (!nullToAbsent || cancellataIl != null) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl);
    }
    return map;
  }

  VociModelloCompanion toCompanion(bool nullToAbsent) {
    return VociModelloCompanion(
      id: Value(id),
      modelloId: Value(modelloId),
      genitoreId: genitoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(genitoreId),
      titolo: Value(titolo),
      descrizione: Value(descrizione),
      tipologiaId: tipologiaId == null && nullToAbsent
          ? const Value.absent()
          : Value(tipologiaId),
      giorni: giorni == null && nullToAbsent
          ? const Value.absent()
          : Value(giorni),
      minuti: minuti == null && nullToAbsent
          ? const Value.absent()
          : Value(minuti),
      nelCalendario: Value(nelCalendario),
      ordine: Value(ordine),
      aggiornataIl: Value(aggiornataIl),
      cancellataIl: cancellataIl == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellataIl),
    );
  }

  factory VoceModello.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoceModello(
      id: serializer.fromJson<String>(json['id']),
      modelloId: serializer.fromJson<String>(json['modelloId']),
      genitoreId: serializer.fromJson<String?>(json['genitoreId']),
      titolo: serializer.fromJson<String>(json['titolo']),
      descrizione: serializer.fromJson<String>(json['descrizione']),
      tipologiaId: serializer.fromJson<String?>(json['tipologiaId']),
      giorni: serializer.fromJson<int?>(json['giorni']),
      minuti: serializer.fromJson<int?>(json['minuti']),
      nelCalendario: serializer.fromJson<bool>(json['nelCalendario']),
      ordine: serializer.fromJson<int>(json['ordine']),
      aggiornataIl: serializer.fromJson<DateTime>(json['aggiornataIl']),
      cancellataIl: serializer.fromJson<DateTime?>(json['cancellataIl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modelloId': serializer.toJson<String>(modelloId),
      'genitoreId': serializer.toJson<String?>(genitoreId),
      'titolo': serializer.toJson<String>(titolo),
      'descrizione': serializer.toJson<String>(descrizione),
      'tipologiaId': serializer.toJson<String?>(tipologiaId),
      'giorni': serializer.toJson<int?>(giorni),
      'minuti': serializer.toJson<int?>(minuti),
      'nelCalendario': serializer.toJson<bool>(nelCalendario),
      'ordine': serializer.toJson<int>(ordine),
      'aggiornataIl': serializer.toJson<DateTime>(aggiornataIl),
      'cancellataIl': serializer.toJson<DateTime?>(cancellataIl),
    };
  }

  VoceModello copyWith({
    String? id,
    String? modelloId,
    Value<String?> genitoreId = const Value.absent(),
    String? titolo,
    String? descrizione,
    Value<String?> tipologiaId = const Value.absent(),
    Value<int?> giorni = const Value.absent(),
    Value<int?> minuti = const Value.absent(),
    bool? nelCalendario,
    int? ordine,
    DateTime? aggiornataIl,
    Value<DateTime?> cancellataIl = const Value.absent(),
  }) => VoceModello(
    id: id ?? this.id,
    modelloId: modelloId ?? this.modelloId,
    genitoreId: genitoreId.present ? genitoreId.value : this.genitoreId,
    titolo: titolo ?? this.titolo,
    descrizione: descrizione ?? this.descrizione,
    tipologiaId: tipologiaId.present ? tipologiaId.value : this.tipologiaId,
    giorni: giorni.present ? giorni.value : this.giorni,
    minuti: minuti.present ? minuti.value : this.minuti,
    nelCalendario: nelCalendario ?? this.nelCalendario,
    ordine: ordine ?? this.ordine,
    aggiornataIl: aggiornataIl ?? this.aggiornataIl,
    cancellataIl: cancellataIl.present ? cancellataIl.value : this.cancellataIl,
  );
  VoceModello copyWithCompanion(VociModelloCompanion data) {
    return VoceModello(
      id: data.id.present ? data.id.value : this.id,
      modelloId: data.modelloId.present ? data.modelloId.value : this.modelloId,
      genitoreId: data.genitoreId.present
          ? data.genitoreId.value
          : this.genitoreId,
      titolo: data.titolo.present ? data.titolo.value : this.titolo,
      descrizione: data.descrizione.present
          ? data.descrizione.value
          : this.descrizione,
      tipologiaId: data.tipologiaId.present
          ? data.tipologiaId.value
          : this.tipologiaId,
      giorni: data.giorni.present ? data.giorni.value : this.giorni,
      minuti: data.minuti.present ? data.minuti.value : this.minuti,
      nelCalendario: data.nelCalendario.present
          ? data.nelCalendario.value
          : this.nelCalendario,
      ordine: data.ordine.present ? data.ordine.value : this.ordine,
      aggiornataIl: data.aggiornataIl.present
          ? data.aggiornataIl.value
          : this.aggiornataIl,
      cancellataIl: data.cancellataIl.present
          ? data.cancellataIl.value
          : this.cancellataIl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoceModello(')
          ..write('id: $id, ')
          ..write('modelloId: $modelloId, ')
          ..write('genitoreId: $genitoreId, ')
          ..write('titolo: $titolo, ')
          ..write('descrizione: $descrizione, ')
          ..write('tipologiaId: $tipologiaId, ')
          ..write('giorni: $giorni, ')
          ..write('minuti: $minuti, ')
          ..write('nelCalendario: $nelCalendario, ')
          ..write('ordine: $ordine, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelloId,
    genitoreId,
    titolo,
    descrizione,
    tipologiaId,
    giorni,
    minuti,
    nelCalendario,
    ordine,
    aggiornataIl,
    cancellataIl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoceModello &&
          other.id == this.id &&
          other.modelloId == this.modelloId &&
          other.genitoreId == this.genitoreId &&
          other.titolo == this.titolo &&
          other.descrizione == this.descrizione &&
          other.tipologiaId == this.tipologiaId &&
          other.giorni == this.giorni &&
          other.minuti == this.minuti &&
          other.nelCalendario == this.nelCalendario &&
          other.ordine == this.ordine &&
          other.aggiornataIl == this.aggiornataIl &&
          other.cancellataIl == this.cancellataIl);
}

class VociModelloCompanion extends UpdateCompanion<VoceModello> {
  final Value<String> id;
  final Value<String> modelloId;
  final Value<String?> genitoreId;
  final Value<String> titolo;
  final Value<String> descrizione;
  final Value<String?> tipologiaId;
  final Value<int?> giorni;
  final Value<int?> minuti;
  final Value<bool> nelCalendario;
  final Value<int> ordine;
  final Value<DateTime> aggiornataIl;
  final Value<DateTime?> cancellataIl;
  final Value<int> rowid;
  const VociModelloCompanion({
    this.id = const Value.absent(),
    this.modelloId = const Value.absent(),
    this.genitoreId = const Value.absent(),
    this.titolo = const Value.absent(),
    this.descrizione = const Value.absent(),
    this.tipologiaId = const Value.absent(),
    this.giorni = const Value.absent(),
    this.minuti = const Value.absent(),
    this.nelCalendario = const Value.absent(),
    this.ordine = const Value.absent(),
    this.aggiornataIl = const Value.absent(),
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VociModelloCompanion.insert({
    required String id,
    required String modelloId,
    this.genitoreId = const Value.absent(),
    required String titolo,
    this.descrizione = const Value.absent(),
    this.tipologiaId = const Value.absent(),
    this.giorni = const Value.absent(),
    this.minuti = const Value.absent(),
    this.nelCalendario = const Value.absent(),
    this.ordine = const Value.absent(),
    required DateTime aggiornataIl,
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       modelloId = Value(modelloId),
       titolo = Value(titolo),
       aggiornataIl = Value(aggiornataIl);
  static Insertable<VoceModello> custom({
    Expression<String>? id,
    Expression<String>? modelloId,
    Expression<String>? genitoreId,
    Expression<String>? titolo,
    Expression<String>? descrizione,
    Expression<String>? tipologiaId,
    Expression<int>? giorni,
    Expression<int>? minuti,
    Expression<bool>? nelCalendario,
    Expression<int>? ordine,
    Expression<DateTime>? aggiornataIl,
    Expression<DateTime>? cancellataIl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelloId != null) 'modello_id': modelloId,
      if (genitoreId != null) 'genitore_id': genitoreId,
      if (titolo != null) 'titolo': titolo,
      if (descrizione != null) 'descrizione': descrizione,
      if (tipologiaId != null) 'tipologia_id': tipologiaId,
      if (giorni != null) 'giorni': giorni,
      if (minuti != null) 'minuti': minuti,
      if (nelCalendario != null) 'nel_calendario': nelCalendario,
      if (ordine != null) 'ordine': ordine,
      if (aggiornataIl != null) 'aggiornata_il': aggiornataIl,
      if (cancellataIl != null) 'cancellata_il': cancellataIl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VociModelloCompanion copyWith({
    Value<String>? id,
    Value<String>? modelloId,
    Value<String?>? genitoreId,
    Value<String>? titolo,
    Value<String>? descrizione,
    Value<String?>? tipologiaId,
    Value<int?>? giorni,
    Value<int?>? minuti,
    Value<bool>? nelCalendario,
    Value<int>? ordine,
    Value<DateTime>? aggiornataIl,
    Value<DateTime?>? cancellataIl,
    Value<int>? rowid,
  }) {
    return VociModelloCompanion(
      id: id ?? this.id,
      modelloId: modelloId ?? this.modelloId,
      genitoreId: genitoreId ?? this.genitoreId,
      titolo: titolo ?? this.titolo,
      descrizione: descrizione ?? this.descrizione,
      tipologiaId: tipologiaId ?? this.tipologiaId,
      giorni: giorni ?? this.giorni,
      minuti: minuti ?? this.minuti,
      nelCalendario: nelCalendario ?? this.nelCalendario,
      ordine: ordine ?? this.ordine,
      aggiornataIl: aggiornataIl ?? this.aggiornataIl,
      cancellataIl: cancellataIl ?? this.cancellataIl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modelloId.present) {
      map['modello_id'] = Variable<String>(modelloId.value);
    }
    if (genitoreId.present) {
      map['genitore_id'] = Variable<String>(genitoreId.value);
    }
    if (titolo.present) {
      map['titolo'] = Variable<String>(titolo.value);
    }
    if (descrizione.present) {
      map['descrizione'] = Variable<String>(descrizione.value);
    }
    if (tipologiaId.present) {
      map['tipologia_id'] = Variable<String>(tipologiaId.value);
    }
    if (giorni.present) {
      map['giorni'] = Variable<int>(giorni.value);
    }
    if (minuti.present) {
      map['minuti'] = Variable<int>(minuti.value);
    }
    if (nelCalendario.present) {
      map['nel_calendario'] = Variable<bool>(nelCalendario.value);
    }
    if (ordine.present) {
      map['ordine'] = Variable<int>(ordine.value);
    }
    if (aggiornataIl.present) {
      map['aggiornata_il'] = Variable<DateTime>(aggiornataIl.value);
    }
    if (cancellataIl.present) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VociModelloCompanion(')
          ..write('id: $id, ')
          ..write('modelloId: $modelloId, ')
          ..write('genitoreId: $genitoreId, ')
          ..write('titolo: $titolo, ')
          ..write('descrizione: $descrizione, ')
          ..write('tipologiaId: $tipologiaId, ')
          ..write('giorni: $giorni, ')
          ..write('minuti: $minuti, ')
          ..write('nelCalendario: $nelCalendario, ')
          ..write('ordine: $ordine, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ElencoAttivitaTable extends ElencoAttivita
    with TableInfo<$ElencoAttivitaTable, Attivita> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ElencoAttivitaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titoloMeta = const VerificationMeta('titolo');
  @override
  late final GeneratedColumn<String> titolo = GeneratedColumn<String>(
    'titolo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descrizioneMeta = const VerificationMeta(
    'descrizione',
  );
  @override
  late final GeneratedColumn<String> descrizione = GeneratedColumn<String>(
    'descrizione',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creataIlMeta = const VerificationMeta(
    'creataIl',
  );
  @override
  late final GeneratedColumn<DateTime> creataIl = GeneratedColumn<DateTime>(
    'creata_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scadenzaMeta = const VerificationMeta(
    'scadenza',
  );
  @override
  late final GeneratedColumn<DateTime> scadenza = GeneratedColumn<DateTime>(
    'scadenza',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scadenzaConOraMeta = const VerificationMeta(
    'scadenzaConOra',
  );
  @override
  late final GeneratedColumn<bool> scadenzaConOra = GeneratedColumn<bool>(
    'scadenza_con_ora',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("scadenza_con_ora" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fattaIlMeta = const VerificationMeta(
    'fattaIl',
  );
  @override
  late final GeneratedColumn<DateTime> fattaIl = GeneratedColumn<DateTime>(
    'fatta_il',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _argomentoIdMeta = const VerificationMeta(
    'argomentoId',
  );
  @override
  late final GeneratedColumn<String> argomentoId = GeneratedColumn<String>(
    'argomento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES argomenti (id)',
    ),
  );
  static const VerificationMeta _tipologiaIdMeta = const VerificationMeta(
    'tipologiaId',
  );
  @override
  late final GeneratedColumn<String> tipologiaId = GeneratedColumn<String>(
    'tipologia_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tipologie (id)',
    ),
  );
  static const VerificationMeta _genitoreIdMeta = const VerificationMeta(
    'genitoreId',
  );
  @override
  late final GeneratedColumn<String> genitoreId = GeneratedColumn<String>(
    'genitore_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attivita (id)',
    ),
  );
  static const VerificationMeta _ordineMeta = const VerificationMeta('ordine');
  @override
  late final GeneratedColumn<int> ordine = GeneratedColumn<int>(
    'ordine',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modelloIdMeta = const VerificationMeta(
    'modelloId',
  );
  @override
  late final GeneratedColumn<String> modelloId = GeneratedColumn<String>(
    'modello_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES modelli (id)',
    ),
  );
  static const VerificationMeta _nelCalendarioMeta = const VerificationMeta(
    'nelCalendario',
  );
  @override
  late final GeneratedColumn<bool> nelCalendario = GeneratedColumn<bool>(
    'nel_calendario',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nel_calendario" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _aggiornataIlMeta = const VerificationMeta(
    'aggiornataIl',
  );
  @override
  late final GeneratedColumn<DateTime> aggiornataIl = GeneratedColumn<DateTime>(
    'aggiornata_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancellataIlMeta = const VerificationMeta(
    'cancellataIl',
  );
  @override
  late final GeneratedColumn<DateTime> cancellataIl = GeneratedColumn<DateTime>(
    'cancellata_il',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titolo,
    descrizione,
    creataIl,
    scadenza,
    scadenzaConOra,
    fattaIl,
    argomentoId,
    tipologiaId,
    genitoreId,
    ordine,
    modelloId,
    nelCalendario,
    aggiornataIl,
    cancellataIl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attivita';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attivita> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('titolo')) {
      context.handle(
        _titoloMeta,
        titolo.isAcceptableOrUnknown(data['titolo']!, _titoloMeta),
      );
    } else if (isInserting) {
      context.missing(_titoloMeta);
    }
    if (data.containsKey('descrizione')) {
      context.handle(
        _descrizioneMeta,
        descrizione.isAcceptableOrUnknown(
          data['descrizione']!,
          _descrizioneMeta,
        ),
      );
    }
    if (data.containsKey('creata_il')) {
      context.handle(
        _creataIlMeta,
        creataIl.isAcceptableOrUnknown(data['creata_il']!, _creataIlMeta),
      );
    } else if (isInserting) {
      context.missing(_creataIlMeta);
    }
    if (data.containsKey('scadenza')) {
      context.handle(
        _scadenzaMeta,
        scadenza.isAcceptableOrUnknown(data['scadenza']!, _scadenzaMeta),
      );
    }
    if (data.containsKey('scadenza_con_ora')) {
      context.handle(
        _scadenzaConOraMeta,
        scadenzaConOra.isAcceptableOrUnknown(
          data['scadenza_con_ora']!,
          _scadenzaConOraMeta,
        ),
      );
    }
    if (data.containsKey('fatta_il')) {
      context.handle(
        _fattaIlMeta,
        fattaIl.isAcceptableOrUnknown(data['fatta_il']!, _fattaIlMeta),
      );
    }
    if (data.containsKey('argomento_id')) {
      context.handle(
        _argomentoIdMeta,
        argomentoId.isAcceptableOrUnknown(
          data['argomento_id']!,
          _argomentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_argomentoIdMeta);
    }
    if (data.containsKey('tipologia_id')) {
      context.handle(
        _tipologiaIdMeta,
        tipologiaId.isAcceptableOrUnknown(
          data['tipologia_id']!,
          _tipologiaIdMeta,
        ),
      );
    }
    if (data.containsKey('genitore_id')) {
      context.handle(
        _genitoreIdMeta,
        genitoreId.isAcceptableOrUnknown(data['genitore_id']!, _genitoreIdMeta),
      );
    }
    if (data.containsKey('ordine')) {
      context.handle(
        _ordineMeta,
        ordine.isAcceptableOrUnknown(data['ordine']!, _ordineMeta),
      );
    }
    if (data.containsKey('modello_id')) {
      context.handle(
        _modelloIdMeta,
        modelloId.isAcceptableOrUnknown(data['modello_id']!, _modelloIdMeta),
      );
    }
    if (data.containsKey('nel_calendario')) {
      context.handle(
        _nelCalendarioMeta,
        nelCalendario.isAcceptableOrUnknown(
          data['nel_calendario']!,
          _nelCalendarioMeta,
        ),
      );
    }
    if (data.containsKey('aggiornata_il')) {
      context.handle(
        _aggiornataIlMeta,
        aggiornataIl.isAcceptableOrUnknown(
          data['aggiornata_il']!,
          _aggiornataIlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggiornataIlMeta);
    }
    if (data.containsKey('cancellata_il')) {
      context.handle(
        _cancellataIlMeta,
        cancellataIl.isAcceptableOrUnknown(
          data['cancellata_il']!,
          _cancellataIlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attivita map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attivita(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      titolo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titolo'],
      )!,
      descrizione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descrizione'],
      )!,
      creataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creata_il'],
      )!,
      scadenza: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scadenza'],
      ),
      scadenzaConOra: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}scadenza_con_ora'],
      )!,
      fattaIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fatta_il'],
      ),
      argomentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}argomento_id'],
      )!,
      tipologiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipologia_id'],
      ),
      genitoreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genitore_id'],
      ),
      ordine: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordine'],
      )!,
      modelloId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modello_id'],
      ),
      nelCalendario: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nel_calendario'],
      )!,
      aggiornataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}aggiornata_il'],
      )!,
      cancellataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancellata_il'],
      ),
    );
  }

  @override
  $ElencoAttivitaTable createAlias(String alias) {
    return $ElencoAttivitaTable(attachedDatabase, alias);
  }
}

class Attivita extends DataClass implements Insertable<Attivita> {
  /// UUID: deve restare unico anche fra dispositivi diversi (voce 003).
  final String id;

  /// Cosa fare.
  final String titolo;

  /// Testo libero, anche lungo.
  final String descrizione;

  /// Quando è stata creata, messo in automatico.
  final DateTime creataIl;

  /// Entro quando completarla. Senza ora vale la mezzanotte di quel giorno,
  /// e [scadenzaConOra] dice se l'ora conta.
  final DateTime? scadenza;

  /// Se l'ora di [scadenza] è stata scelta o è solo la mezzanotte di comodo.
  final bool scadenzaConOra;

  /// Quando è stata fatta; nullo finché è da fare.
  final DateTime? fattaIl;

  /// L'argomento. Nelle sotto-attività è sempre quello dell'attività
  /// principale: si ripete su ogni riga per poter filtrare senza risalire
  /// l'albero (voce 005).
  final String argomentoId;

  /// La tipologia, facoltativa. Ogni sotto-attività ha la sua.
  final String? tipologiaId;

  /// L'attività di cui questa è una sotto-attività; nullo per le principali.
  final String? genitoreId;

  /// Posizione fra le sorelle (stesso genitore).
  final int ordine;

  /// Il modello da cui è nata, se c'è. Si scrive solo sull'attività
  /// principale creata dal modello, non sulle sue sotto-attività.
  final String? modelloId;

  /// Se deve comparire su Google Calendar. Per ora si segna soltanto: gli
  /// eventi li creerà il server, nella fase 4 (voce 009).
  final bool nelCalendario;

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  final DateTime aggiornataIl;

  /// Se non è nulla l'attività è nel cestino. Un sottoalbero cestinato
  /// insieme ha su ogni riga lo stesso istante, ed è così che il ripristino
  /// sa cosa riportare indietro (voce 006).
  final DateTime? cancellataIl;
  const Attivita({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.creataIl,
    this.scadenza,
    required this.scadenzaConOra,
    this.fattaIl,
    required this.argomentoId,
    this.tipologiaId,
    this.genitoreId,
    required this.ordine,
    this.modelloId,
    required this.nelCalendario,
    required this.aggiornataIl,
    this.cancellataIl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['titolo'] = Variable<String>(titolo);
    map['descrizione'] = Variable<String>(descrizione);
    map['creata_il'] = Variable<DateTime>(creataIl);
    if (!nullToAbsent || scadenza != null) {
      map['scadenza'] = Variable<DateTime>(scadenza);
    }
    map['scadenza_con_ora'] = Variable<bool>(scadenzaConOra);
    if (!nullToAbsent || fattaIl != null) {
      map['fatta_il'] = Variable<DateTime>(fattaIl);
    }
    map['argomento_id'] = Variable<String>(argomentoId);
    if (!nullToAbsent || tipologiaId != null) {
      map['tipologia_id'] = Variable<String>(tipologiaId);
    }
    if (!nullToAbsent || genitoreId != null) {
      map['genitore_id'] = Variable<String>(genitoreId);
    }
    map['ordine'] = Variable<int>(ordine);
    if (!nullToAbsent || modelloId != null) {
      map['modello_id'] = Variable<String>(modelloId);
    }
    map['nel_calendario'] = Variable<bool>(nelCalendario);
    map['aggiornata_il'] = Variable<DateTime>(aggiornataIl);
    if (!nullToAbsent || cancellataIl != null) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl);
    }
    return map;
  }

  ElencoAttivitaCompanion toCompanion(bool nullToAbsent) {
    return ElencoAttivitaCompanion(
      id: Value(id),
      titolo: Value(titolo),
      descrizione: Value(descrizione),
      creataIl: Value(creataIl),
      scadenza: scadenza == null && nullToAbsent
          ? const Value.absent()
          : Value(scadenza),
      scadenzaConOra: Value(scadenzaConOra),
      fattaIl: fattaIl == null && nullToAbsent
          ? const Value.absent()
          : Value(fattaIl),
      argomentoId: Value(argomentoId),
      tipologiaId: tipologiaId == null && nullToAbsent
          ? const Value.absent()
          : Value(tipologiaId),
      genitoreId: genitoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(genitoreId),
      ordine: Value(ordine),
      modelloId: modelloId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelloId),
      nelCalendario: Value(nelCalendario),
      aggiornataIl: Value(aggiornataIl),
      cancellataIl: cancellataIl == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellataIl),
    );
  }

  factory Attivita.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attivita(
      id: serializer.fromJson<String>(json['id']),
      titolo: serializer.fromJson<String>(json['titolo']),
      descrizione: serializer.fromJson<String>(json['descrizione']),
      creataIl: serializer.fromJson<DateTime>(json['creataIl']),
      scadenza: serializer.fromJson<DateTime?>(json['scadenza']),
      scadenzaConOra: serializer.fromJson<bool>(json['scadenzaConOra']),
      fattaIl: serializer.fromJson<DateTime?>(json['fattaIl']),
      argomentoId: serializer.fromJson<String>(json['argomentoId']),
      tipologiaId: serializer.fromJson<String?>(json['tipologiaId']),
      genitoreId: serializer.fromJson<String?>(json['genitoreId']),
      ordine: serializer.fromJson<int>(json['ordine']),
      modelloId: serializer.fromJson<String?>(json['modelloId']),
      nelCalendario: serializer.fromJson<bool>(json['nelCalendario']),
      aggiornataIl: serializer.fromJson<DateTime>(json['aggiornataIl']),
      cancellataIl: serializer.fromJson<DateTime?>(json['cancellataIl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'titolo': serializer.toJson<String>(titolo),
      'descrizione': serializer.toJson<String>(descrizione),
      'creataIl': serializer.toJson<DateTime>(creataIl),
      'scadenza': serializer.toJson<DateTime?>(scadenza),
      'scadenzaConOra': serializer.toJson<bool>(scadenzaConOra),
      'fattaIl': serializer.toJson<DateTime?>(fattaIl),
      'argomentoId': serializer.toJson<String>(argomentoId),
      'tipologiaId': serializer.toJson<String?>(tipologiaId),
      'genitoreId': serializer.toJson<String?>(genitoreId),
      'ordine': serializer.toJson<int>(ordine),
      'modelloId': serializer.toJson<String?>(modelloId),
      'nelCalendario': serializer.toJson<bool>(nelCalendario),
      'aggiornataIl': serializer.toJson<DateTime>(aggiornataIl),
      'cancellataIl': serializer.toJson<DateTime?>(cancellataIl),
    };
  }

  Attivita copyWith({
    String? id,
    String? titolo,
    String? descrizione,
    DateTime? creataIl,
    Value<DateTime?> scadenza = const Value.absent(),
    bool? scadenzaConOra,
    Value<DateTime?> fattaIl = const Value.absent(),
    String? argomentoId,
    Value<String?> tipologiaId = const Value.absent(),
    Value<String?> genitoreId = const Value.absent(),
    int? ordine,
    Value<String?> modelloId = const Value.absent(),
    bool? nelCalendario,
    DateTime? aggiornataIl,
    Value<DateTime?> cancellataIl = const Value.absent(),
  }) => Attivita(
    id: id ?? this.id,
    titolo: titolo ?? this.titolo,
    descrizione: descrizione ?? this.descrizione,
    creataIl: creataIl ?? this.creataIl,
    scadenza: scadenza.present ? scadenza.value : this.scadenza,
    scadenzaConOra: scadenzaConOra ?? this.scadenzaConOra,
    fattaIl: fattaIl.present ? fattaIl.value : this.fattaIl,
    argomentoId: argomentoId ?? this.argomentoId,
    tipologiaId: tipologiaId.present ? tipologiaId.value : this.tipologiaId,
    genitoreId: genitoreId.present ? genitoreId.value : this.genitoreId,
    ordine: ordine ?? this.ordine,
    modelloId: modelloId.present ? modelloId.value : this.modelloId,
    nelCalendario: nelCalendario ?? this.nelCalendario,
    aggiornataIl: aggiornataIl ?? this.aggiornataIl,
    cancellataIl: cancellataIl.present ? cancellataIl.value : this.cancellataIl,
  );
  Attivita copyWithCompanion(ElencoAttivitaCompanion data) {
    return Attivita(
      id: data.id.present ? data.id.value : this.id,
      titolo: data.titolo.present ? data.titolo.value : this.titolo,
      descrizione: data.descrizione.present
          ? data.descrizione.value
          : this.descrizione,
      creataIl: data.creataIl.present ? data.creataIl.value : this.creataIl,
      scadenza: data.scadenza.present ? data.scadenza.value : this.scadenza,
      scadenzaConOra: data.scadenzaConOra.present
          ? data.scadenzaConOra.value
          : this.scadenzaConOra,
      fattaIl: data.fattaIl.present ? data.fattaIl.value : this.fattaIl,
      argomentoId: data.argomentoId.present
          ? data.argomentoId.value
          : this.argomentoId,
      tipologiaId: data.tipologiaId.present
          ? data.tipologiaId.value
          : this.tipologiaId,
      genitoreId: data.genitoreId.present
          ? data.genitoreId.value
          : this.genitoreId,
      ordine: data.ordine.present ? data.ordine.value : this.ordine,
      modelloId: data.modelloId.present ? data.modelloId.value : this.modelloId,
      nelCalendario: data.nelCalendario.present
          ? data.nelCalendario.value
          : this.nelCalendario,
      aggiornataIl: data.aggiornataIl.present
          ? data.aggiornataIl.value
          : this.aggiornataIl,
      cancellataIl: data.cancellataIl.present
          ? data.cancellataIl.value
          : this.cancellataIl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attivita(')
          ..write('id: $id, ')
          ..write('titolo: $titolo, ')
          ..write('descrizione: $descrizione, ')
          ..write('creataIl: $creataIl, ')
          ..write('scadenza: $scadenza, ')
          ..write('scadenzaConOra: $scadenzaConOra, ')
          ..write('fattaIl: $fattaIl, ')
          ..write('argomentoId: $argomentoId, ')
          ..write('tipologiaId: $tipologiaId, ')
          ..write('genitoreId: $genitoreId, ')
          ..write('ordine: $ordine, ')
          ..write('modelloId: $modelloId, ')
          ..write('nelCalendario: $nelCalendario, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titolo,
    descrizione,
    creataIl,
    scadenza,
    scadenzaConOra,
    fattaIl,
    argomentoId,
    tipologiaId,
    genitoreId,
    ordine,
    modelloId,
    nelCalendario,
    aggiornataIl,
    cancellataIl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attivita &&
          other.id == this.id &&
          other.titolo == this.titolo &&
          other.descrizione == this.descrizione &&
          other.creataIl == this.creataIl &&
          other.scadenza == this.scadenza &&
          other.scadenzaConOra == this.scadenzaConOra &&
          other.fattaIl == this.fattaIl &&
          other.argomentoId == this.argomentoId &&
          other.tipologiaId == this.tipologiaId &&
          other.genitoreId == this.genitoreId &&
          other.ordine == this.ordine &&
          other.modelloId == this.modelloId &&
          other.nelCalendario == this.nelCalendario &&
          other.aggiornataIl == this.aggiornataIl &&
          other.cancellataIl == this.cancellataIl);
}

class ElencoAttivitaCompanion extends UpdateCompanion<Attivita> {
  final Value<String> id;
  final Value<String> titolo;
  final Value<String> descrizione;
  final Value<DateTime> creataIl;
  final Value<DateTime?> scadenza;
  final Value<bool> scadenzaConOra;
  final Value<DateTime?> fattaIl;
  final Value<String> argomentoId;
  final Value<String?> tipologiaId;
  final Value<String?> genitoreId;
  final Value<int> ordine;
  final Value<String?> modelloId;
  final Value<bool> nelCalendario;
  final Value<DateTime> aggiornataIl;
  final Value<DateTime?> cancellataIl;
  final Value<int> rowid;
  const ElencoAttivitaCompanion({
    this.id = const Value.absent(),
    this.titolo = const Value.absent(),
    this.descrizione = const Value.absent(),
    this.creataIl = const Value.absent(),
    this.scadenza = const Value.absent(),
    this.scadenzaConOra = const Value.absent(),
    this.fattaIl = const Value.absent(),
    this.argomentoId = const Value.absent(),
    this.tipologiaId = const Value.absent(),
    this.genitoreId = const Value.absent(),
    this.ordine = const Value.absent(),
    this.modelloId = const Value.absent(),
    this.nelCalendario = const Value.absent(),
    this.aggiornataIl = const Value.absent(),
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ElencoAttivitaCompanion.insert({
    required String id,
    required String titolo,
    this.descrizione = const Value.absent(),
    required DateTime creataIl,
    this.scadenza = const Value.absent(),
    this.scadenzaConOra = const Value.absent(),
    this.fattaIl = const Value.absent(),
    required String argomentoId,
    this.tipologiaId = const Value.absent(),
    this.genitoreId = const Value.absent(),
    this.ordine = const Value.absent(),
    this.modelloId = const Value.absent(),
    this.nelCalendario = const Value.absent(),
    required DateTime aggiornataIl,
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       titolo = Value(titolo),
       creataIl = Value(creataIl),
       argomentoId = Value(argomentoId),
       aggiornataIl = Value(aggiornataIl);
  static Insertable<Attivita> custom({
    Expression<String>? id,
    Expression<String>? titolo,
    Expression<String>? descrizione,
    Expression<DateTime>? creataIl,
    Expression<DateTime>? scadenza,
    Expression<bool>? scadenzaConOra,
    Expression<DateTime>? fattaIl,
    Expression<String>? argomentoId,
    Expression<String>? tipologiaId,
    Expression<String>? genitoreId,
    Expression<int>? ordine,
    Expression<String>? modelloId,
    Expression<bool>? nelCalendario,
    Expression<DateTime>? aggiornataIl,
    Expression<DateTime>? cancellataIl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titolo != null) 'titolo': titolo,
      if (descrizione != null) 'descrizione': descrizione,
      if (creataIl != null) 'creata_il': creataIl,
      if (scadenza != null) 'scadenza': scadenza,
      if (scadenzaConOra != null) 'scadenza_con_ora': scadenzaConOra,
      if (fattaIl != null) 'fatta_il': fattaIl,
      if (argomentoId != null) 'argomento_id': argomentoId,
      if (tipologiaId != null) 'tipologia_id': tipologiaId,
      if (genitoreId != null) 'genitore_id': genitoreId,
      if (ordine != null) 'ordine': ordine,
      if (modelloId != null) 'modello_id': modelloId,
      if (nelCalendario != null) 'nel_calendario': nelCalendario,
      if (aggiornataIl != null) 'aggiornata_il': aggiornataIl,
      if (cancellataIl != null) 'cancellata_il': cancellataIl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ElencoAttivitaCompanion copyWith({
    Value<String>? id,
    Value<String>? titolo,
    Value<String>? descrizione,
    Value<DateTime>? creataIl,
    Value<DateTime?>? scadenza,
    Value<bool>? scadenzaConOra,
    Value<DateTime?>? fattaIl,
    Value<String>? argomentoId,
    Value<String?>? tipologiaId,
    Value<String?>? genitoreId,
    Value<int>? ordine,
    Value<String?>? modelloId,
    Value<bool>? nelCalendario,
    Value<DateTime>? aggiornataIl,
    Value<DateTime?>? cancellataIl,
    Value<int>? rowid,
  }) {
    return ElencoAttivitaCompanion(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      descrizione: descrizione ?? this.descrizione,
      creataIl: creataIl ?? this.creataIl,
      scadenza: scadenza ?? this.scadenza,
      scadenzaConOra: scadenzaConOra ?? this.scadenzaConOra,
      fattaIl: fattaIl ?? this.fattaIl,
      argomentoId: argomentoId ?? this.argomentoId,
      tipologiaId: tipologiaId ?? this.tipologiaId,
      genitoreId: genitoreId ?? this.genitoreId,
      ordine: ordine ?? this.ordine,
      modelloId: modelloId ?? this.modelloId,
      nelCalendario: nelCalendario ?? this.nelCalendario,
      aggiornataIl: aggiornataIl ?? this.aggiornataIl,
      cancellataIl: cancellataIl ?? this.cancellataIl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (titolo.present) {
      map['titolo'] = Variable<String>(titolo.value);
    }
    if (descrizione.present) {
      map['descrizione'] = Variable<String>(descrizione.value);
    }
    if (creataIl.present) {
      map['creata_il'] = Variable<DateTime>(creataIl.value);
    }
    if (scadenza.present) {
      map['scadenza'] = Variable<DateTime>(scadenza.value);
    }
    if (scadenzaConOra.present) {
      map['scadenza_con_ora'] = Variable<bool>(scadenzaConOra.value);
    }
    if (fattaIl.present) {
      map['fatta_il'] = Variable<DateTime>(fattaIl.value);
    }
    if (argomentoId.present) {
      map['argomento_id'] = Variable<String>(argomentoId.value);
    }
    if (tipologiaId.present) {
      map['tipologia_id'] = Variable<String>(tipologiaId.value);
    }
    if (genitoreId.present) {
      map['genitore_id'] = Variable<String>(genitoreId.value);
    }
    if (ordine.present) {
      map['ordine'] = Variable<int>(ordine.value);
    }
    if (modelloId.present) {
      map['modello_id'] = Variable<String>(modelloId.value);
    }
    if (nelCalendario.present) {
      map['nel_calendario'] = Variable<bool>(nelCalendario.value);
    }
    if (aggiornataIl.present) {
      map['aggiornata_il'] = Variable<DateTime>(aggiornataIl.value);
    }
    if (cancellataIl.present) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ElencoAttivitaCompanion(')
          ..write('id: $id, ')
          ..write('titolo: $titolo, ')
          ..write('descrizione: $descrizione, ')
          ..write('creataIl: $creataIl, ')
          ..write('scadenza: $scadenza, ')
          ..write('scadenzaConOra: $scadenzaConOra, ')
          ..write('fattaIl: $fattaIl, ')
          ..write('argomentoId: $argomentoId, ')
          ..write('tipologiaId: $tipologiaId, ')
          ..write('genitoreId: $genitoreId, ')
          ..write('ordine: $ordine, ')
          ..write('modelloId: $modelloId, ')
          ..write('nelCalendario: $nelCalendario, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ElencoFotoTable extends ElencoFoto
    with TableInfo<$ElencoFotoTable, Foto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ElencoFotoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attivitaIdMeta = const VerificationMeta(
    'attivitaId',
  );
  @override
  late final GeneratedColumn<String> attivitaId = GeneratedColumn<String>(
    'attivita_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attivita (id)',
    ),
  );
  static const VerificationMeta _nomeFileMeta = const VerificationMeta(
    'nomeFile',
  );
  @override
  late final GeneratedColumn<String> nomeFile = GeneratedColumn<String>(
    'nome_file',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creataIlMeta = const VerificationMeta(
    'creataIl',
  );
  @override
  late final GeneratedColumn<DateTime> creataIl = GeneratedColumn<DateTime>(
    'creata_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggiornataIlMeta = const VerificationMeta(
    'aggiornataIl',
  );
  @override
  late final GeneratedColumn<DateTime> aggiornataIl = GeneratedColumn<DateTime>(
    'aggiornata_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancellataIlMeta = const VerificationMeta(
    'cancellataIl',
  );
  @override
  late final GeneratedColumn<DateTime> cancellataIl = GeneratedColumn<DateTime>(
    'cancellata_il',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attivitaId,
    nomeFile,
    creataIl,
    aggiornataIl,
    cancellataIl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foto';
  @override
  VerificationContext validateIntegrity(
    Insertable<Foto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('attivita_id')) {
      context.handle(
        _attivitaIdMeta,
        attivitaId.isAcceptableOrUnknown(data['attivita_id']!, _attivitaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attivitaIdMeta);
    }
    if (data.containsKey('nome_file')) {
      context.handle(
        _nomeFileMeta,
        nomeFile.isAcceptableOrUnknown(data['nome_file']!, _nomeFileMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeFileMeta);
    }
    if (data.containsKey('creata_il')) {
      context.handle(
        _creataIlMeta,
        creataIl.isAcceptableOrUnknown(data['creata_il']!, _creataIlMeta),
      );
    } else if (isInserting) {
      context.missing(_creataIlMeta);
    }
    if (data.containsKey('aggiornata_il')) {
      context.handle(
        _aggiornataIlMeta,
        aggiornataIl.isAcceptableOrUnknown(
          data['aggiornata_il']!,
          _aggiornataIlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggiornataIlMeta);
    }
    if (data.containsKey('cancellata_il')) {
      context.handle(
        _cancellataIlMeta,
        cancellataIl.isAcceptableOrUnknown(
          data['cancellata_il']!,
          _cancellataIlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Foto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Foto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      attivitaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attivita_id'],
      )!,
      nomeFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_file'],
      )!,
      creataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creata_il'],
      )!,
      aggiornataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}aggiornata_il'],
      )!,
      cancellataIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancellata_il'],
      ),
    );
  }

  @override
  $ElencoFotoTable createAlias(String alias) {
    return $ElencoFotoTable(attachedDatabase, alias);
  }
}

class Foto extends DataClass implements Insertable<Foto> {
  /// UUID.
  final String id;

  /// L'attività a cui è allegata.
  final String attivitaId;

  /// Nome del file dentro la cartella delle foto.
  final String nomeFile;

  /// Quando è stata allegata.
  final DateTime creataIl;

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  final DateTime aggiornataIl;

  /// Se non è nulla la foto è stata tolta (voce 003).
  final DateTime? cancellataIl;
  const Foto({
    required this.id,
    required this.attivitaId,
    required this.nomeFile,
    required this.creataIl,
    required this.aggiornataIl,
    this.cancellataIl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['attivita_id'] = Variable<String>(attivitaId);
    map['nome_file'] = Variable<String>(nomeFile);
    map['creata_il'] = Variable<DateTime>(creataIl);
    map['aggiornata_il'] = Variable<DateTime>(aggiornataIl);
    if (!nullToAbsent || cancellataIl != null) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl);
    }
    return map;
  }

  ElencoFotoCompanion toCompanion(bool nullToAbsent) {
    return ElencoFotoCompanion(
      id: Value(id),
      attivitaId: Value(attivitaId),
      nomeFile: Value(nomeFile),
      creataIl: Value(creataIl),
      aggiornataIl: Value(aggiornataIl),
      cancellataIl: cancellataIl == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellataIl),
    );
  }

  factory Foto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Foto(
      id: serializer.fromJson<String>(json['id']),
      attivitaId: serializer.fromJson<String>(json['attivitaId']),
      nomeFile: serializer.fromJson<String>(json['nomeFile']),
      creataIl: serializer.fromJson<DateTime>(json['creataIl']),
      aggiornataIl: serializer.fromJson<DateTime>(json['aggiornataIl']),
      cancellataIl: serializer.fromJson<DateTime?>(json['cancellataIl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'attivitaId': serializer.toJson<String>(attivitaId),
      'nomeFile': serializer.toJson<String>(nomeFile),
      'creataIl': serializer.toJson<DateTime>(creataIl),
      'aggiornataIl': serializer.toJson<DateTime>(aggiornataIl),
      'cancellataIl': serializer.toJson<DateTime?>(cancellataIl),
    };
  }

  Foto copyWith({
    String? id,
    String? attivitaId,
    String? nomeFile,
    DateTime? creataIl,
    DateTime? aggiornataIl,
    Value<DateTime?> cancellataIl = const Value.absent(),
  }) => Foto(
    id: id ?? this.id,
    attivitaId: attivitaId ?? this.attivitaId,
    nomeFile: nomeFile ?? this.nomeFile,
    creataIl: creataIl ?? this.creataIl,
    aggiornataIl: aggiornataIl ?? this.aggiornataIl,
    cancellataIl: cancellataIl.present ? cancellataIl.value : this.cancellataIl,
  );
  Foto copyWithCompanion(ElencoFotoCompanion data) {
    return Foto(
      id: data.id.present ? data.id.value : this.id,
      attivitaId: data.attivitaId.present
          ? data.attivitaId.value
          : this.attivitaId,
      nomeFile: data.nomeFile.present ? data.nomeFile.value : this.nomeFile,
      creataIl: data.creataIl.present ? data.creataIl.value : this.creataIl,
      aggiornataIl: data.aggiornataIl.present
          ? data.aggiornataIl.value
          : this.aggiornataIl,
      cancellataIl: data.cancellataIl.present
          ? data.cancellataIl.value
          : this.cancellataIl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Foto(')
          ..write('id: $id, ')
          ..write('attivitaId: $attivitaId, ')
          ..write('nomeFile: $nomeFile, ')
          ..write('creataIl: $creataIl, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attivitaId,
    nomeFile,
    creataIl,
    aggiornataIl,
    cancellataIl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Foto &&
          other.id == this.id &&
          other.attivitaId == this.attivitaId &&
          other.nomeFile == this.nomeFile &&
          other.creataIl == this.creataIl &&
          other.aggiornataIl == this.aggiornataIl &&
          other.cancellataIl == this.cancellataIl);
}

class ElencoFotoCompanion extends UpdateCompanion<Foto> {
  final Value<String> id;
  final Value<String> attivitaId;
  final Value<String> nomeFile;
  final Value<DateTime> creataIl;
  final Value<DateTime> aggiornataIl;
  final Value<DateTime?> cancellataIl;
  final Value<int> rowid;
  const ElencoFotoCompanion({
    this.id = const Value.absent(),
    this.attivitaId = const Value.absent(),
    this.nomeFile = const Value.absent(),
    this.creataIl = const Value.absent(),
    this.aggiornataIl = const Value.absent(),
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ElencoFotoCompanion.insert({
    required String id,
    required String attivitaId,
    required String nomeFile,
    required DateTime creataIl,
    required DateTime aggiornataIl,
    this.cancellataIl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       attivitaId = Value(attivitaId),
       nomeFile = Value(nomeFile),
       creataIl = Value(creataIl),
       aggiornataIl = Value(aggiornataIl);
  static Insertable<Foto> custom({
    Expression<String>? id,
    Expression<String>? attivitaId,
    Expression<String>? nomeFile,
    Expression<DateTime>? creataIl,
    Expression<DateTime>? aggiornataIl,
    Expression<DateTime>? cancellataIl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attivitaId != null) 'attivita_id': attivitaId,
      if (nomeFile != null) 'nome_file': nomeFile,
      if (creataIl != null) 'creata_il': creataIl,
      if (aggiornataIl != null) 'aggiornata_il': aggiornataIl,
      if (cancellataIl != null) 'cancellata_il': cancellataIl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ElencoFotoCompanion copyWith({
    Value<String>? id,
    Value<String>? attivitaId,
    Value<String>? nomeFile,
    Value<DateTime>? creataIl,
    Value<DateTime>? aggiornataIl,
    Value<DateTime?>? cancellataIl,
    Value<int>? rowid,
  }) {
    return ElencoFotoCompanion(
      id: id ?? this.id,
      attivitaId: attivitaId ?? this.attivitaId,
      nomeFile: nomeFile ?? this.nomeFile,
      creataIl: creataIl ?? this.creataIl,
      aggiornataIl: aggiornataIl ?? this.aggiornataIl,
      cancellataIl: cancellataIl ?? this.cancellataIl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (attivitaId.present) {
      map['attivita_id'] = Variable<String>(attivitaId.value);
    }
    if (nomeFile.present) {
      map['nome_file'] = Variable<String>(nomeFile.value);
    }
    if (creataIl.present) {
      map['creata_il'] = Variable<DateTime>(creataIl.value);
    }
    if (aggiornataIl.present) {
      map['aggiornata_il'] = Variable<DateTime>(aggiornataIl.value);
    }
    if (cancellataIl.present) {
      map['cancellata_il'] = Variable<DateTime>(cancellataIl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ElencoFotoCompanion(')
          ..write('id: $id, ')
          ..write('attivitaId: $attivitaId, ')
          ..write('nomeFile: $nomeFile, ')
          ..write('creataIl: $creataIl, ')
          ..write('aggiornataIl: $aggiornataIl, ')
          ..write('cancellataIl: $cancellataIl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteSyncTable extends NoteSync with TableInfo<$NoteSyncTable, NotaSync> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tabellaMeta = const VerificationMeta(
    'tabella',
  );
  @override
  late final GeneratedColumn<String> tabella = GeneratedColumn<String>(
    'tabella',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _improntaMeta = const VerificationMeta(
    'impronta',
  );
  @override
  late final GeneratedColumn<String> impronta = GeneratedColumn<String>(
    'impronta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tabella, id, impronta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_note';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotaSync> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tabella')) {
      context.handle(
        _tabellaMeta,
        tabella.isAcceptableOrUnknown(data['tabella']!, _tabellaMeta),
      );
    } else if (isInserting) {
      context.missing(_tabellaMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('impronta')) {
      context.handle(
        _improntaMeta,
        impronta.isAcceptableOrUnknown(data['impronta']!, _improntaMeta),
      );
    } else if (isInserting) {
      context.missing(_improntaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tabella, id};
  @override
  NotaSync map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotaSync(
      tabella: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabella'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      impronta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impronta'],
      )!,
    );
  }

  @override
  $NoteSyncTable createAlias(String alias) {
    return $NoteSyncTable(attachedDatabase, alias);
  }
}

class NotaSync extends DataClass implements Insertable<NotaSync> {
  /// Il nome della tabella della riga, come lo conosce il server.
  final String tabella;

  /// L'id della riga.
  final String id;

  /// L'impronta del contenuto (`impronta()`).
  final String impronta;
  const NotaSync({
    required this.tabella,
    required this.id,
    required this.impronta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tabella'] = Variable<String>(tabella);
    map['id'] = Variable<String>(id);
    map['impronta'] = Variable<String>(impronta);
    return map;
  }

  NoteSyncCompanion toCompanion(bool nullToAbsent) {
    return NoteSyncCompanion(
      tabella: Value(tabella),
      id: Value(id),
      impronta: Value(impronta),
    );
  }

  factory NotaSync.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotaSync(
      tabella: serializer.fromJson<String>(json['tabella']),
      id: serializer.fromJson<String>(json['id']),
      impronta: serializer.fromJson<String>(json['impronta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tabella': serializer.toJson<String>(tabella),
      'id': serializer.toJson<String>(id),
      'impronta': serializer.toJson<String>(impronta),
    };
  }

  NotaSync copyWith({String? tabella, String? id, String? impronta}) =>
      NotaSync(
        tabella: tabella ?? this.tabella,
        id: id ?? this.id,
        impronta: impronta ?? this.impronta,
      );
  NotaSync copyWithCompanion(NoteSyncCompanion data) {
    return NotaSync(
      tabella: data.tabella.present ? data.tabella.value : this.tabella,
      id: data.id.present ? data.id.value : this.id,
      impronta: data.impronta.present ? data.impronta.value : this.impronta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotaSync(')
          ..write('tabella: $tabella, ')
          ..write('id: $id, ')
          ..write('impronta: $impronta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tabella, id, impronta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotaSync &&
          other.tabella == this.tabella &&
          other.id == this.id &&
          other.impronta == this.impronta);
}

class NoteSyncCompanion extends UpdateCompanion<NotaSync> {
  final Value<String> tabella;
  final Value<String> id;
  final Value<String> impronta;
  final Value<int> rowid;
  const NoteSyncCompanion({
    this.tabella = const Value.absent(),
    this.id = const Value.absent(),
    this.impronta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteSyncCompanion.insert({
    required String tabella,
    required String id,
    required String impronta,
    this.rowid = const Value.absent(),
  }) : tabella = Value(tabella),
       id = Value(id),
       impronta = Value(impronta);
  static Insertable<NotaSync> custom({
    Expression<String>? tabella,
    Expression<String>? id,
    Expression<String>? impronta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tabella != null) 'tabella': tabella,
      if (id != null) 'id': id,
      if (impronta != null) 'impronta': impronta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteSyncCompanion copyWith({
    Value<String>? tabella,
    Value<String>? id,
    Value<String>? impronta,
    Value<int>? rowid,
  }) {
    return NoteSyncCompanion(
      tabella: tabella ?? this.tabella,
      id: id ?? this.id,
      impronta: impronta ?? this.impronta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tabella.present) {
      map['tabella'] = Variable<String>(tabella.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (impronta.present) {
      map['impronta'] = Variable<String>(impronta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteSyncCompanion(')
          ..write('tabella: $tabella, ')
          ..write('id: $id, ')
          ..write('impronta: $impronta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenzeTable extends Preferenze
    with TableInfo<$PreferenzeTable, Preferenza> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenzeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chiaveMeta = const VerificationMeta('chiave');
  @override
  late final GeneratedColumn<String> chiave = GeneratedColumn<String>(
    'chiave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valoreMeta = const VerificationMeta('valore');
  @override
  late final GeneratedColumn<String> valore = GeneratedColumn<String>(
    'valore',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chiave, valore];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferenze';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preferenza> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chiave')) {
      context.handle(
        _chiaveMeta,
        chiave.isAcceptableOrUnknown(data['chiave']!, _chiaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chiaveMeta);
    }
    if (data.containsKey('valore')) {
      context.handle(
        _valoreMeta,
        valore.isAcceptableOrUnknown(data['valore']!, _valoreMeta),
      );
    } else if (isInserting) {
      context.missing(_valoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chiave};
  @override
  Preferenza map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preferenza(
      chiave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chiave'],
      )!,
      valore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valore'],
      )!,
    );
  }

  @override
  $PreferenzeTable createAlias(String alias) {
    return $PreferenzeTable(attachedDatabase, alias);
  }
}

class Preferenza extends DataClass implements Insertable<Preferenza> {
  final String chiave;
  final String valore;
  const Preferenza({required this.chiave, required this.valore});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chiave'] = Variable<String>(chiave);
    map['valore'] = Variable<String>(valore);
    return map;
  }

  PreferenzeCompanion toCompanion(bool nullToAbsent) {
    return PreferenzeCompanion(chiave: Value(chiave), valore: Value(valore));
  }

  factory Preferenza.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preferenza(
      chiave: serializer.fromJson<String>(json['chiave']),
      valore: serializer.fromJson<String>(json['valore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chiave': serializer.toJson<String>(chiave),
      'valore': serializer.toJson<String>(valore),
    };
  }

  Preferenza copyWith({String? chiave, String? valore}) =>
      Preferenza(chiave: chiave ?? this.chiave, valore: valore ?? this.valore);
  Preferenza copyWithCompanion(PreferenzeCompanion data) {
    return Preferenza(
      chiave: data.chiave.present ? data.chiave.value : this.chiave,
      valore: data.valore.present ? data.valore.value : this.valore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preferenza(')
          ..write('chiave: $chiave, ')
          ..write('valore: $valore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chiave, valore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preferenza &&
          other.chiave == this.chiave &&
          other.valore == this.valore);
}

class PreferenzeCompanion extends UpdateCompanion<Preferenza> {
  final Value<String> chiave;
  final Value<String> valore;
  final Value<int> rowid;
  const PreferenzeCompanion({
    this.chiave = const Value.absent(),
    this.valore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenzeCompanion.insert({
    required String chiave,
    required String valore,
    this.rowid = const Value.absent(),
  }) : chiave = Value(chiave),
       valore = Value(valore);
  static Insertable<Preferenza> custom({
    Expression<String>? chiave,
    Expression<String>? valore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chiave != null) 'chiave': chiave,
      if (valore != null) 'valore': valore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenzeCompanion copyWith({
    Value<String>? chiave,
    Value<String>? valore,
    Value<int>? rowid,
  }) {
    return PreferenzeCompanion(
      chiave: chiave ?? this.chiave,
      valore: valore ?? this.valore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chiave.present) {
      map['chiave'] = Variable<String>(chiave.value);
    }
    if (valore.present) {
      map['valore'] = Variable<String>(valore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenzeCompanion(')
          ..write('chiave: $chiave, ')
          ..write('valore: $valore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventiCalendarioTable extends EventiCalendario
    with TableInfo<$EventiCalendarioTable, EventoCalendario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventiCalendarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attivitaIdMeta = const VerificationMeta(
    'attivitaId',
  );
  @override
  late final GeneratedColumn<String> attivitaId = GeneratedColumn<String>(
    'attivita_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventoIdMeta = const VerificationMeta(
    'eventoId',
  );
  @override
  late final GeneratedColumn<int> eventoId = GeneratedColumn<int>(
    'evento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calendarioIdMeta = const VerificationMeta(
    'calendarioId',
  );
  @override
  late final GeneratedColumn<int> calendarioId = GeneratedColumn<int>(
    'calendario_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _improntaMeta = const VerificationMeta(
    'impronta',
  );
  @override
  late final GeneratedColumn<String> impronta = GeneratedColumn<String>(
    'impronta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attivitaId,
    eventoId,
    calendarioId,
    impronta,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventi_calendario';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventoCalendario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attivita_id')) {
      context.handle(
        _attivitaIdMeta,
        attivitaId.isAcceptableOrUnknown(data['attivita_id']!, _attivitaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attivitaIdMeta);
    }
    if (data.containsKey('evento_id')) {
      context.handle(
        _eventoIdMeta,
        eventoId.isAcceptableOrUnknown(data['evento_id']!, _eventoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventoIdMeta);
    }
    if (data.containsKey('calendario_id')) {
      context.handle(
        _calendarioIdMeta,
        calendarioId.isAcceptableOrUnknown(
          data['calendario_id']!,
          _calendarioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarioIdMeta);
    }
    if (data.containsKey('impronta')) {
      context.handle(
        _improntaMeta,
        impronta.isAcceptableOrUnknown(data['impronta']!, _improntaMeta),
      );
    } else if (isInserting) {
      context.missing(_improntaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attivitaId};
  @override
  EventoCalendario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventoCalendario(
      attivitaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attivita_id'],
      )!,
      eventoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evento_id'],
      )!,
      calendarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calendario_id'],
      )!,
      impronta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impronta'],
      )!,
    );
  }

  @override
  $EventiCalendarioTable createAlias(String alias) {
    return $EventiCalendarioTable(attachedDatabase, alias);
  }
}

class EventoCalendario extends DataClass
    implements Insertable<EventoCalendario> {
  /// L'attività da cui nasce l'evento.
  final String attivitaId;

  /// L'id dell'evento nel calendario del telefono.
  final int eventoId;

  /// Il calendario in cui sta l'evento.
  final int calendarioId;

  /// L'impronta di titolo, date e colore dell'ultima versione scritta: se
  /// cambia, l'evento va aggiornato.
  final String impronta;
  const EventoCalendario({
    required this.attivitaId,
    required this.eventoId,
    required this.calendarioId,
    required this.impronta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attivita_id'] = Variable<String>(attivitaId);
    map['evento_id'] = Variable<int>(eventoId);
    map['calendario_id'] = Variable<int>(calendarioId);
    map['impronta'] = Variable<String>(impronta);
    return map;
  }

  EventiCalendarioCompanion toCompanion(bool nullToAbsent) {
    return EventiCalendarioCompanion(
      attivitaId: Value(attivitaId),
      eventoId: Value(eventoId),
      calendarioId: Value(calendarioId),
      impronta: Value(impronta),
    );
  }

  factory EventoCalendario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventoCalendario(
      attivitaId: serializer.fromJson<String>(json['attivitaId']),
      eventoId: serializer.fromJson<int>(json['eventoId']),
      calendarioId: serializer.fromJson<int>(json['calendarioId']),
      impronta: serializer.fromJson<String>(json['impronta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attivitaId': serializer.toJson<String>(attivitaId),
      'eventoId': serializer.toJson<int>(eventoId),
      'calendarioId': serializer.toJson<int>(calendarioId),
      'impronta': serializer.toJson<String>(impronta),
    };
  }

  EventoCalendario copyWith({
    String? attivitaId,
    int? eventoId,
    int? calendarioId,
    String? impronta,
  }) => EventoCalendario(
    attivitaId: attivitaId ?? this.attivitaId,
    eventoId: eventoId ?? this.eventoId,
    calendarioId: calendarioId ?? this.calendarioId,
    impronta: impronta ?? this.impronta,
  );
  EventoCalendario copyWithCompanion(EventiCalendarioCompanion data) {
    return EventoCalendario(
      attivitaId: data.attivitaId.present
          ? data.attivitaId.value
          : this.attivitaId,
      eventoId: data.eventoId.present ? data.eventoId.value : this.eventoId,
      calendarioId: data.calendarioId.present
          ? data.calendarioId.value
          : this.calendarioId,
      impronta: data.impronta.present ? data.impronta.value : this.impronta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventoCalendario(')
          ..write('attivitaId: $attivitaId, ')
          ..write('eventoId: $eventoId, ')
          ..write('calendarioId: $calendarioId, ')
          ..write('impronta: $impronta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(attivitaId, eventoId, calendarioId, impronta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventoCalendario &&
          other.attivitaId == this.attivitaId &&
          other.eventoId == this.eventoId &&
          other.calendarioId == this.calendarioId &&
          other.impronta == this.impronta);
}

class EventiCalendarioCompanion extends UpdateCompanion<EventoCalendario> {
  final Value<String> attivitaId;
  final Value<int> eventoId;
  final Value<int> calendarioId;
  final Value<String> impronta;
  final Value<int> rowid;
  const EventiCalendarioCompanion({
    this.attivitaId = const Value.absent(),
    this.eventoId = const Value.absent(),
    this.calendarioId = const Value.absent(),
    this.impronta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventiCalendarioCompanion.insert({
    required String attivitaId,
    required int eventoId,
    required int calendarioId,
    required String impronta,
    this.rowid = const Value.absent(),
  }) : attivitaId = Value(attivitaId),
       eventoId = Value(eventoId),
       calendarioId = Value(calendarioId),
       impronta = Value(impronta);
  static Insertable<EventoCalendario> custom({
    Expression<String>? attivitaId,
    Expression<int>? eventoId,
    Expression<int>? calendarioId,
    Expression<String>? impronta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attivitaId != null) 'attivita_id': attivitaId,
      if (eventoId != null) 'evento_id': eventoId,
      if (calendarioId != null) 'calendario_id': calendarioId,
      if (impronta != null) 'impronta': impronta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventiCalendarioCompanion copyWith({
    Value<String>? attivitaId,
    Value<int>? eventoId,
    Value<int>? calendarioId,
    Value<String>? impronta,
    Value<int>? rowid,
  }) {
    return EventiCalendarioCompanion(
      attivitaId: attivitaId ?? this.attivitaId,
      eventoId: eventoId ?? this.eventoId,
      calendarioId: calendarioId ?? this.calendarioId,
      impronta: impronta ?? this.impronta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attivitaId.present) {
      map['attivita_id'] = Variable<String>(attivitaId.value);
    }
    if (eventoId.present) {
      map['evento_id'] = Variable<int>(eventoId.value);
    }
    if (calendarioId.present) {
      map['calendario_id'] = Variable<int>(calendarioId.value);
    }
    if (impronta.present) {
      map['impronta'] = Variable<String>(impronta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventiCalendarioCompanion(')
          ..write('attivitaId: $attivitaId, ')
          ..write('eventoId: $eventoId, ')
          ..write('calendarioId: $calendarioId, ')
          ..write('impronta: $impronta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArgomentiTable argomenti = $ArgomentiTable(this);
  late final $TipologieTable tipologie = $TipologieTable(this);
  late final $ModelliTable modelli = $ModelliTable(this);
  late final $VociModelloTable vociModello = $VociModelloTable(this);
  late final $ElencoAttivitaTable elencoAttivita = $ElencoAttivitaTable(this);
  late final $ElencoFotoTable elencoFoto = $ElencoFotoTable(this);
  late final $NoteSyncTable noteSync = $NoteSyncTable(this);
  late final $PreferenzeTable preferenze = $PreferenzeTable(this);
  late final $EventiCalendarioTable eventiCalendario = $EventiCalendarioTable(
    this,
  );
  late final CategorieDao categorieDao = CategorieDao(this as AppDatabase);
  late final AttivitaDao attivitaDao = AttivitaDao(this as AppDatabase);
  late final ModelliDao modelliDao = ModelliDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final CalendarioDao calendarioDao = CalendarioDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    argomenti,
    tipologie,
    modelli,
    vociModello,
    elencoAttivita,
    elencoFoto,
    noteSync,
    preferenze,
    eventiCalendario,
  ];
}

typedef $$ArgomentiTableCreateCompanionBuilder = ArgomentiCompanion Function({
  required String id,
  required String nome,
  Value<int> colore,
  Value<String> icona,
  Value<int> ordine,
  Value<bool> predefinito,
  required DateTime aggiornatoIl,
  Value<DateTime?> cancellatoIl,
  Value<int> rowid,
});
typedef $$ArgomentiTableUpdateCompanionBuilder = ArgomentiCompanion Function({
  Value<String> id,
  Value<String> nome,
  Value<int> colore,
  Value<String> icona,
  Value<int> ordine,
  Value<bool> predefinito,
  Value<DateTime> aggiornatoIl,
  Value<DateTime?> cancellatoIl,
  Value<int> rowid,
});

final class $$ArgomentiTableReferences
    extends BaseReferences<_$AppDatabase, $ArgomentiTable, Argomento> {
  $$ArgomentiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ModelliTable, List<Modello>> _modelliRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.modelli,
    aliasName: 'argomenti__id__modelli__argomento_id',
  );

  $$ModelliTableProcessedTableManager get modelliRefs {
    final manager = $$ModelliTableTableManager(
      $_db,
      $_db.modelli,
    ).filter((f) => f.argomentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_modelliRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ElencoAttivitaTable, List<Attivita>>
  _elencoAttivitaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.elencoAttivita,
    aliasName: 'argomenti__id__attivita__argomento_id',
  );

  $$ElencoAttivitaTableProcessedTableManager get elencoAttivitaRefs {
    final manager = $$ElencoAttivitaTableTableManager(
      $_db,
      $_db.elencoAttivita,
    ).filter((f) => f.argomentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_elencoAttivitaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArgomentiTableFilterComposer
    extends Composer<_$AppDatabase, $ArgomentiTable> {
  $$ArgomentiTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colore => $composableBuilder(
    column: $table.colore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icona => $composableBuilder(
    column: $table.icona,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordine => $composableBuilder(
    column: $table.ordine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get predefinito => $composableBuilder(
    column: $table.predefinito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get aggiornatoIl => $composableBuilder(
    column: $table.aggiornatoIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancellatoIl => $composableBuilder(
    column: $table.cancellatoIl,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> modelliRefs(
    Expression<bool> Function($$ModelliTableFilterComposer f) f,
  ) {
    final $$ModelliTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.argomentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableFilterComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> elencoAttivitaRefs(
    Expression<bool> Function($$ElencoAttivitaTableFilterComposer f) f,
  ) {
    final $$ElencoAttivitaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.argomentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableFilterComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArgomentiTableOrderingComposer
    extends Composer<_$AppDatabase, $ArgomentiTable> {
  $$ArgomentiTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colore => $composableBuilder(
    column: $table.colore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icona => $composableBuilder(
    column: $table.icona,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordine => $composableBuilder(
    column: $table.ordine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get predefinito => $composableBuilder(
    column: $table.predefinito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get aggiornatoIl => $composableBuilder(
    column: $table.aggiornatoIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancellatoIl => $composableBuilder(
    column: $table.cancellatoIl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArgomentiTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArgomentiTable> {
  $$ArgomentiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get colore =>
      $composableBuilder(column: $table.colore, builder: (column) => column);

  GeneratedColumn<String> get icona =>
      $composableBuilder(column: $table.icona, builder: (column) => column);

  GeneratedColumn<int> get ordine =>
      $composableBuilder(column: $table.ordine, builder: (column) => column);

  GeneratedColumn<bool> get predefinito => $composableBuilder(
    column: $table.predefinito,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get aggiornatoIl => $composableBuilder(
    column: $table.aggiornatoIl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancellatoIl => $composableBuilder(
    column: $table.cancellatoIl,
    builder: (column) => column,
  );

  Expression<T> modelliRefs<T extends Object>(
    Expression<T> Function($$ModelliTableAnnotationComposer a) f,
  ) {
    final $$ModelliTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.argomentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableAnnotationComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> elencoAttivitaRefs<T extends Object>(
    Expression<T> Function($$ElencoAttivitaTableAnnotationComposer a) f,
  ) {
    final $$ElencoAttivitaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.argomentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableAnnotationComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArgomentiTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArgomentiTable,
          Argomento,
          $$ArgomentiTableFilterComposer,
          $$ArgomentiTableOrderingComposer,
          $$ArgomentiTableAnnotationComposer,
          $$ArgomentiTableCreateCompanionBuilder,
          $$ArgomentiTableUpdateCompanionBuilder,
          (Argomento, $$ArgomentiTableReferences),
          Argomento,
          PrefetchHooks Function({bool modelliRefs, bool elencoAttivitaRefs})
        > {
  $$ArgomentiTableTableManager(_$AppDatabase db, $ArgomentiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArgomentiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArgomentiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArgomentiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> colore = const Value.absent(),
                Value<String> icona = const Value.absent(),
                Value<int> ordine = const Value.absent(),
                Value<bool> predefinito = const Value.absent(),
                Value<DateTime> aggiornatoIl = const Value.absent(),
                Value<DateTime?> cancellatoIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArgomentiCompanion(
                id: id,
                nome: nome,
                colore: colore,
                icona: icona,
                ordine: ordine,
                predefinito: predefinito,
                aggiornatoIl: aggiornatoIl,
                cancellatoIl: cancellatoIl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                Value<int> colore = const Value.absent(),
                Value<String> icona = const Value.absent(),
                Value<int> ordine = const Value.absent(),
                Value<bool> predefinito = const Value.absent(),
                required DateTime aggiornatoIl,
                Value<DateTime?> cancellatoIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArgomentiCompanion.insert(
                id: id,
                nome: nome,
                colore: colore,
                icona: icona,
                ordine: ordine,
                predefinito: predefinito,
                aggiornatoIl: aggiornatoIl,
                cancellatoIl: cancellatoIl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArgomentiTable, Argomento>(table),
                  $$ArgomentiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({modelliRefs = false, elencoAttivitaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (modelliRefs) db.modelli,
                    if (elencoAttivitaRefs) db.elencoAttivita,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (modelliRefs)
                        await $_getPrefetchedDataByColumns<
                          Argomento,
                          $ArgomentiTable,
                          Modello,
                          $ModelliTable
                        >(
                          currentTable: table,
                          referencedTable: $$ArgomentiTableReferences
                              ._modelliRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArgomentiTableReferences(
                                db,
                                table,
                                p0,
                              ).modelliRefs,
                          currentColumn: 'id',
                          referencedColumn: 'argomento_id',
                          typedResults: items,
                        ),
                      if (elencoAttivitaRefs)
                        await $_getPrefetchedDataByColumns<
                          Argomento,
                          $ArgomentiTable,
                          Attivita,
                          $ElencoAttivitaTable
                        >(
                          currentTable: table,
                          referencedTable: $$ArgomentiTableReferences
                              ._elencoAttivitaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArgomentiTableReferences(
                                db,
                                table,
                                p0,
                              ).elencoAttivitaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'argomento_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ArgomentiTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArgomentiTable,
      Argomento,
      $$ArgomentiTableFilterComposer,
      $$ArgomentiTableOrderingComposer,
      $$ArgomentiTableAnnotationComposer,
      $$ArgomentiTableCreateCompanionBuilder,
      $$ArgomentiTableUpdateCompanionBuilder,
      (Argomento, $$ArgomentiTableReferences),
      Argomento,
      PrefetchHooks Function({bool modelliRefs, bool elencoAttivitaRefs})
    >;
typedef $$TipologieTableCreateCompanionBuilder = TipologieCompanion Function({
  required String id,
  required String nome,
  Value<String> icona,
  required DateTime aggiornataIl,
  Value<DateTime?> cancellataIl,
  Value<int> rowid,
});
typedef $$TipologieTableUpdateCompanionBuilder = TipologieCompanion Function({
  Value<String> id,
  Value<String> nome,
  Value<String> icona,
  Value<DateTime> aggiornataIl,
  Value<DateTime?> cancellataIl,
  Value<int> rowid,
});

final class $$TipologieTableReferences
    extends BaseReferences<_$AppDatabase, $TipologieTable, Tipologia> {
  $$TipologieTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ModelliTable, List<Modello>> _modelliRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.modelli,
    aliasName: 'tipologie__id__modelli__tipologia_id',
  );

  $$ModelliTableProcessedTableManager get modelliRefs {
    final manager = $$ModelliTableTableManager(
      $_db,
      $_db.modelli,
    ).filter((f) => f.tipologiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_modelliRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VociModelloTable, List<VoceModello>>
  _vociModelloRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vociModello,
    aliasName: 'tipologie__id__voci_modello__tipologia_id',
  );

  $$VociModelloTableProcessedTableManager get vociModelloRefs {
    final manager = $$VociModelloTableTableManager(
      $_db,
      $_db.vociModello,
    ).filter((f) => f.tipologiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vociModelloRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ElencoAttivitaTable, List<Attivita>>
  _elencoAttivitaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.elencoAttivita,
    aliasName: 'tipologie__id__attivita__tipologia_id',
  );

  $$ElencoAttivitaTableProcessedTableManager get elencoAttivitaRefs {
    final manager = $$ElencoAttivitaTableTableManager(
      $_db,
      $_db.elencoAttivita,
    ).filter((f) => f.tipologiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_elencoAttivitaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TipologieTableFilterComposer
    extends Composer<_$AppDatabase, $TipologieTable> {
  $$TipologieTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icona => $composableBuilder(
    column: $table.icona,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> modelliRefs(
    Expression<bool> Function($$ModelliTableFilterComposer f) f,
  ) {
    final $$ModelliTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.tipologiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableFilterComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vociModelloRefs(
    Expression<bool> Function($$VociModelloTableFilterComposer f) f,
  ) {
    final $$VociModelloTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vociModello,
      getReferencedColumn: (t) => t.tipologiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VociModelloTableFilterComposer(
            $db: $db,
            $table: $db.vociModello,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> elencoAttivitaRefs(
    Expression<bool> Function($$ElencoAttivitaTableFilterComposer f) f,
  ) {
    final $$ElencoAttivitaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.tipologiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableFilterComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TipologieTableOrderingComposer
    extends Composer<_$AppDatabase, $TipologieTable> {
  $$TipologieTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icona => $composableBuilder(
    column: $table.icona,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipologieTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipologieTable> {
  $$TipologieTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get icona =>
      $composableBuilder(column: $table.icona, builder: (column) => column);

  GeneratedColumn<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => column,
  );

  Expression<T> modelliRefs<T extends Object>(
    Expression<T> Function($$ModelliTableAnnotationComposer a) f,
  ) {
    final $$ModelliTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.tipologiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableAnnotationComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vociModelloRefs<T extends Object>(
    Expression<T> Function($$VociModelloTableAnnotationComposer a) f,
  ) {
    final $$VociModelloTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vociModello,
      getReferencedColumn: (t) => t.tipologiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VociModelloTableAnnotationComposer(
            $db: $db,
            $table: $db.vociModello,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> elencoAttivitaRefs<T extends Object>(
    Expression<T> Function($$ElencoAttivitaTableAnnotationComposer a) f,
  ) {
    final $$ElencoAttivitaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.tipologiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableAnnotationComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TipologieTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipologieTable,
          Tipologia,
          $$TipologieTableFilterComposer,
          $$TipologieTableOrderingComposer,
          $$TipologieTableAnnotationComposer,
          $$TipologieTableCreateCompanionBuilder,
          $$TipologieTableUpdateCompanionBuilder,
          (Tipologia, $$TipologieTableReferences),
          Tipologia,
          PrefetchHooks Function({
            bool modelliRefs,
            bool vociModelloRefs,
            bool elencoAttivitaRefs,
          })
        > {
  $$TipologieTableTableManager(_$AppDatabase db, $TipologieTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TipologieTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TipologieTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TipologieTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> icona = const Value.absent(),
                Value<DateTime> aggiornataIl = const Value.absent(),
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipologieCompanion(
                id: id,
                nome: nome,
                icona: icona,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                Value<String> icona = const Value.absent(),
                required DateTime aggiornataIl,
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipologieCompanion.insert(
                id: id,
                nome: nome,
                icona: icona,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TipologieTable, Tipologia>(table),
                  $$TipologieTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                modelliRefs = false,
                vociModelloRefs = false,
                elencoAttivitaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (modelliRefs) db.modelli,
                    if (vociModelloRefs) db.vociModello,
                    if (elencoAttivitaRefs) db.elencoAttivita,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (modelliRefs)
                        await $_getPrefetchedDataByColumns<
                          Tipologia,
                          $TipologieTable,
                          Modello,
                          $ModelliTable
                        >(
                          currentTable: table,
                          referencedTable: $$TipologieTableReferences
                              ._modelliRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TipologieTableReferences(
                                db,
                                table,
                                p0,
                              ).modelliRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tipologia_id',
                          typedResults: items,
                        ),
                      if (vociModelloRefs)
                        await $_getPrefetchedDataByColumns<
                          Tipologia,
                          $TipologieTable,
                          VoceModello,
                          $VociModelloTable
                        >(
                          currentTable: table,
                          referencedTable: $$TipologieTableReferences
                              ._vociModelloRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TipologieTableReferences(
                                db,
                                table,
                                p0,
                              ).vociModelloRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tipologia_id',
                          typedResults: items,
                        ),
                      if (elencoAttivitaRefs)
                        await $_getPrefetchedDataByColumns<
                          Tipologia,
                          $TipologieTable,
                          Attivita,
                          $ElencoAttivitaTable
                        >(
                          currentTable: table,
                          referencedTable: $$TipologieTableReferences
                              ._elencoAttivitaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TipologieTableReferences(
                                db,
                                table,
                                p0,
                              ).elencoAttivitaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tipologia_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TipologieTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipologieTable,
      Tipologia,
      $$TipologieTableFilterComposer,
      $$TipologieTableOrderingComposer,
      $$TipologieTableAnnotationComposer,
      $$TipologieTableCreateCompanionBuilder,
      $$TipologieTableUpdateCompanionBuilder,
      (Tipologia, $$TipologieTableReferences),
      Tipologia,
      PrefetchHooks Function({
        bool modelliRefs,
        bool vociModelloRefs,
        bool elencoAttivitaRefs,
      })
    >;
typedef $$ModelliTableCreateCompanionBuilder = ModelliCompanion Function({
  required String id,
  required String nome,
  Value<String> descrizione,
  Value<String?> argomentoId,
  Value<String?> tipologiaId,
  Value<int?> giorni,
  Value<int?> minuti,
  Value<bool> nelCalendario,
  required DateTime aggiornatoIl,
  Value<DateTime?> cancellatoIl,
  Value<int> rowid,
});
typedef $$ModelliTableUpdateCompanionBuilder = ModelliCompanion Function({
  Value<String> id,
  Value<String> nome,
  Value<String> descrizione,
  Value<String?> argomentoId,
  Value<String?> tipologiaId,
  Value<int?> giorni,
  Value<int?> minuti,
  Value<bool> nelCalendario,
  Value<DateTime> aggiornatoIl,
  Value<DateTime?> cancellatoIl,
  Value<int> rowid,
});

final class $$ModelliTableReferences
    extends BaseReferences<_$AppDatabase, $ModelliTable, Modello> {
  $$ModelliTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArgomentiTable _argomentoIdTable(_$AppDatabase db) =>
      db.argomenti.createAlias('modelli__argomento_id__argomenti__id');

  $$ArgomentiTableProcessedTableManager? get argomentoId {
    final $_column = $_itemColumn<String>('argomento_id');
    if ($_column == null) return null;
    final manager = $$ArgomentiTableTableManager(
      $_db,
      $_db.argomenti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_argomentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TipologieTable _tipologiaIdTable(_$AppDatabase db) =>
      db.tipologie.createAlias('modelli__tipologia_id__tipologie__id');

  $$TipologieTableProcessedTableManager? get tipologiaId {
    final $_column = $_itemColumn<String>('tipologia_id');
    if ($_column == null) return null;
    final manager = $$TipologieTableTableManager(
      $_db,
      $_db.tipologie,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tipologiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VociModelloTable, List<VoceModello>>
  _vociModelloRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vociModello,
    aliasName: 'modelli__id__voci_modello__modello_id',
  );

  $$VociModelloTableProcessedTableManager get vociModelloRefs {
    final manager = $$VociModelloTableTableManager(
      $_db,
      $_db.vociModello,
    ).filter((f) => f.modelloId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vociModelloRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ElencoAttivitaTable, List<Attivita>>
  _elencoAttivitaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.elencoAttivita,
    aliasName: 'modelli__id__attivita__modello_id',
  );

  $$ElencoAttivitaTableProcessedTableManager get elencoAttivitaRefs {
    final manager = $$ElencoAttivitaTableTableManager(
      $_db,
      $_db.elencoAttivita,
    ).filter((f) => f.modelloId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_elencoAttivitaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ModelliTableFilterComposer
    extends Composer<_$AppDatabase, $ModelliTable> {
  $$ModelliTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get giorni => $composableBuilder(
    column: $table.giorni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minuti => $composableBuilder(
    column: $table.minuti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get aggiornatoIl => $composableBuilder(
    column: $table.aggiornatoIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancellatoIl => $composableBuilder(
    column: $table.cancellatoIl,
    builder: (column) => ColumnFilters(column),
  );

  $$ArgomentiTableFilterComposer get argomentoId {
    final $$ArgomentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.argomentoId,
      referencedTable: $db.argomenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArgomentiTableFilterComposer(
            $db: $db,
            $table: $db.argomenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableFilterComposer get tipologiaId {
    final $$TipologieTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableFilterComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> vociModelloRefs(
    Expression<bool> Function($$VociModelloTableFilterComposer f) f,
  ) {
    final $$VociModelloTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vociModello,
      getReferencedColumn: (t) => t.modelloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VociModelloTableFilterComposer(
            $db: $db,
            $table: $db.vociModello,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> elencoAttivitaRefs(
    Expression<bool> Function($$ElencoAttivitaTableFilterComposer f) f,
  ) {
    final $$ElencoAttivitaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.modelloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableFilterComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ModelliTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelliTable> {
  $$ModelliTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get giorni => $composableBuilder(
    column: $table.giorni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minuti => $composableBuilder(
    column: $table.minuti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get aggiornatoIl => $composableBuilder(
    column: $table.aggiornatoIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancellatoIl => $composableBuilder(
    column: $table.cancellatoIl,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArgomentiTableOrderingComposer get argomentoId {
    final $$ArgomentiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.argomentoId,
      referencedTable: $db.argomenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArgomentiTableOrderingComposer(
            $db: $db,
            $table: $db.argomenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableOrderingComposer get tipologiaId {
    final $$TipologieTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableOrderingComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ModelliTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelliTable> {
  $$ModelliTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => column,
  );

  GeneratedColumn<int> get giorni =>
      $composableBuilder(column: $table.giorni, builder: (column) => column);

  GeneratedColumn<int> get minuti =>
      $composableBuilder(column: $table.minuti, builder: (column) => column);

  GeneratedColumn<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get aggiornatoIl => $composableBuilder(
    column: $table.aggiornatoIl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancellatoIl => $composableBuilder(
    column: $table.cancellatoIl,
    builder: (column) => column,
  );

  $$ArgomentiTableAnnotationComposer get argomentoId {
    final $$ArgomentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.argomentoId,
      referencedTable: $db.argomenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArgomentiTableAnnotationComposer(
            $db: $db,
            $table: $db.argomenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableAnnotationComposer get tipologiaId {
    final $$TipologieTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableAnnotationComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> vociModelloRefs<T extends Object>(
    Expression<T> Function($$VociModelloTableAnnotationComposer a) f,
  ) {
    final $$VociModelloTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vociModello,
      getReferencedColumn: (t) => t.modelloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VociModelloTableAnnotationComposer(
            $db: $db,
            $table: $db.vociModello,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> elencoAttivitaRefs<T extends Object>(
    Expression<T> Function($$ElencoAttivitaTableAnnotationComposer a) f,
  ) {
    final $$ElencoAttivitaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.modelloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableAnnotationComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ModelliTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModelliTable,
          Modello,
          $$ModelliTableFilterComposer,
          $$ModelliTableOrderingComposer,
          $$ModelliTableAnnotationComposer,
          $$ModelliTableCreateCompanionBuilder,
          $$ModelliTableUpdateCompanionBuilder,
          (Modello, $$ModelliTableReferences),
          Modello,
          PrefetchHooks Function({
            bool argomentoId,
            bool tipologiaId,
            bool vociModelloRefs,
            bool elencoAttivitaRefs,
          })
        > {
  $$ModelliTableTableManager(_$AppDatabase db, $ModelliTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelliTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelliTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelliTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> descrizione = const Value.absent(),
                Value<String?> argomentoId = const Value.absent(),
                Value<String?> tipologiaId = const Value.absent(),
                Value<int?> giorni = const Value.absent(),
                Value<int?> minuti = const Value.absent(),
                Value<bool> nelCalendario = const Value.absent(),
                Value<DateTime> aggiornatoIl = const Value.absent(),
                Value<DateTime?> cancellatoIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelliCompanion(
                id: id,
                nome: nome,
                descrizione: descrizione,
                argomentoId: argomentoId,
                tipologiaId: tipologiaId,
                giorni: giorni,
                minuti: minuti,
                nelCalendario: nelCalendario,
                aggiornatoIl: aggiornatoIl,
                cancellatoIl: cancellatoIl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                Value<String> descrizione = const Value.absent(),
                Value<String?> argomentoId = const Value.absent(),
                Value<String?> tipologiaId = const Value.absent(),
                Value<int?> giorni = const Value.absent(),
                Value<int?> minuti = const Value.absent(),
                Value<bool> nelCalendario = const Value.absent(),
                required DateTime aggiornatoIl,
                Value<DateTime?> cancellatoIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelliCompanion.insert(
                id: id,
                nome: nome,
                descrizione: descrizione,
                argomentoId: argomentoId,
                tipologiaId: tipologiaId,
                giorni: giorni,
                minuti: minuti,
                nelCalendario: nelCalendario,
                aggiornatoIl: aggiornatoIl,
                cancellatoIl: cancellatoIl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModelliTable, Modello>(table),
                  $$ModelliTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                argomentoId = false,
                tipologiaId = false,
                vociModelloRefs = false,
                elencoAttivitaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (vociModelloRefs) db.vociModello,
                    if (elencoAttivitaRefs) db.elencoAttivita,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (argomentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.argomentoId,
                            referencedTable: $$ModelliTableReferences
                                ._argomentoIdTable(db),
                            referencedColumn: $$ModelliTableReferences
                                ._argomentoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (tipologiaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tipologiaId,
                            referencedTable: $$ModelliTableReferences
                                ._tipologiaIdTable(db),
                            referencedColumn: $$ModelliTableReferences
                                ._tipologiaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vociModelloRefs)
                        await $_getPrefetchedDataByColumns<
                          Modello,
                          $ModelliTable,
                          VoceModello,
                          $VociModelloTable
                        >(
                          currentTable: table,
                          referencedTable: $$ModelliTableReferences
                              ._vociModelloRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ModelliTableReferences(
                                db,
                                table,
                                p0,
                              ).vociModelloRefs,
                          currentColumn: 'id',
                          referencedColumn: 'modello_id',
                          typedResults: items,
                        ),
                      if (elencoAttivitaRefs)
                        await $_getPrefetchedDataByColumns<
                          Modello,
                          $ModelliTable,
                          Attivita,
                          $ElencoAttivitaTable
                        >(
                          currentTable: table,
                          referencedTable: $$ModelliTableReferences
                              ._elencoAttivitaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ModelliTableReferences(
                                db,
                                table,
                                p0,
                              ).elencoAttivitaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'modello_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ModelliTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModelliTable,
      Modello,
      $$ModelliTableFilterComposer,
      $$ModelliTableOrderingComposer,
      $$ModelliTableAnnotationComposer,
      $$ModelliTableCreateCompanionBuilder,
      $$ModelliTableUpdateCompanionBuilder,
      (Modello, $$ModelliTableReferences),
      Modello,
      PrefetchHooks Function({
        bool argomentoId,
        bool tipologiaId,
        bool vociModelloRefs,
        bool elencoAttivitaRefs,
      })
    >;
typedef $$VociModelloTableCreateCompanionBuilder =
    VociModelloCompanion Function({
      required String id,
      required String modelloId,
      Value<String?> genitoreId,
      required String titolo,
      Value<String> descrizione,
      Value<String?> tipologiaId,
      Value<int?> giorni,
      Value<int?> minuti,
      Value<bool> nelCalendario,
      Value<int> ordine,
      required DateTime aggiornataIl,
      Value<DateTime?> cancellataIl,
      Value<int> rowid,
    });
typedef $$VociModelloTableUpdateCompanionBuilder =
    VociModelloCompanion Function({
      Value<String> id,
      Value<String> modelloId,
      Value<String?> genitoreId,
      Value<String> titolo,
      Value<String> descrizione,
      Value<String?> tipologiaId,
      Value<int?> giorni,
      Value<int?> minuti,
      Value<bool> nelCalendario,
      Value<int> ordine,
      Value<DateTime> aggiornataIl,
      Value<DateTime?> cancellataIl,
      Value<int> rowid,
    });

final class $$VociModelloTableReferences
    extends BaseReferences<_$AppDatabase, $VociModelloTable, VoceModello> {
  $$VociModelloTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ModelliTable _modelloIdTable(_$AppDatabase db) =>
      db.modelli.createAlias('voci_modello__modello_id__modelli__id');

  $$ModelliTableProcessedTableManager get modelloId {
    final $_column = $_itemColumn<String>('modello_id')!;

    final manager = $$ModelliTableTableManager(
      $_db,
      $_db.modelli,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelloIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VociModelloTable _genitoreIdTable(_$AppDatabase db) =>
      db.vociModello.createAlias('voci_modello__genitore_id__voci_modello__id');

  $$VociModelloTableProcessedTableManager? get genitoreId {
    final $_column = $_itemColumn<String>('genitore_id');
    if ($_column == null) return null;
    final manager = $$VociModelloTableTableManager(
      $_db,
      $_db.vociModello,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_genitoreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TipologieTable _tipologiaIdTable(_$AppDatabase db) =>
      db.tipologie.createAlias('voci_modello__tipologia_id__tipologie__id');

  $$TipologieTableProcessedTableManager? get tipologiaId {
    final $_column = $_itemColumn<String>('tipologia_id');
    if ($_column == null) return null;
    final manager = $$TipologieTableTableManager(
      $_db,
      $_db.tipologie,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tipologiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VociModelloTableFilterComposer
    extends Composer<_$AppDatabase, $VociModelloTable> {
  $$VociModelloTableFilterComposer({
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

  ColumnFilters<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get giorni => $composableBuilder(
    column: $table.giorni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minuti => $composableBuilder(
    column: $table.minuti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordine => $composableBuilder(
    column: $table.ordine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnFilters(column),
  );

  $$ModelliTableFilterComposer get modelloId {
    final $$ModelliTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelloId,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableFilterComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VociModelloTableFilterComposer get genitoreId {
    final $$VociModelloTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genitoreId,
      referencedTable: $db.vociModello,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VociModelloTableFilterComposer(
            $db: $db,
            $table: $db.vociModello,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableFilterComposer get tipologiaId {
    final $$TipologieTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableFilterComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VociModelloTableOrderingComposer
    extends Composer<_$AppDatabase, $VociModelloTable> {
  $$VociModelloTableOrderingComposer({
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

  ColumnOrderings<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get giorni => $composableBuilder(
    column: $table.giorni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minuti => $composableBuilder(
    column: $table.minuti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordine => $composableBuilder(
    column: $table.ordine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnOrderings(column),
  );

  $$ModelliTableOrderingComposer get modelloId {
    final $$ModelliTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelloId,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableOrderingComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VociModelloTableOrderingComposer get genitoreId {
    final $$VociModelloTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genitoreId,
      referencedTable: $db.vociModello,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VociModelloTableOrderingComposer(
            $db: $db,
            $table: $db.vociModello,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableOrderingComposer get tipologiaId {
    final $$TipologieTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableOrderingComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VociModelloTableAnnotationComposer
    extends Composer<_$AppDatabase, $VociModelloTable> {
  $$VociModelloTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titolo =>
      $composableBuilder(column: $table.titolo, builder: (column) => column);

  GeneratedColumn<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => column,
  );

  GeneratedColumn<int> get giorni =>
      $composableBuilder(column: $table.giorni, builder: (column) => column);

  GeneratedColumn<int> get minuti =>
      $composableBuilder(column: $table.minuti, builder: (column) => column);

  GeneratedColumn<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordine =>
      $composableBuilder(column: $table.ordine, builder: (column) => column);

  GeneratedColumn<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => column,
  );

  $$ModelliTableAnnotationComposer get modelloId {
    final $$ModelliTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelloId,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableAnnotationComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VociModelloTableAnnotationComposer get genitoreId {
    final $$VociModelloTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genitoreId,
      referencedTable: $db.vociModello,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VociModelloTableAnnotationComposer(
            $db: $db,
            $table: $db.vociModello,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableAnnotationComposer get tipologiaId {
    final $$TipologieTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableAnnotationComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VociModelloTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VociModelloTable,
          VoceModello,
          $$VociModelloTableFilterComposer,
          $$VociModelloTableOrderingComposer,
          $$VociModelloTableAnnotationComposer,
          $$VociModelloTableCreateCompanionBuilder,
          $$VociModelloTableUpdateCompanionBuilder,
          (VoceModello, $$VociModelloTableReferences),
          VoceModello,
          PrefetchHooks Function({
            bool modelloId,
            bool genitoreId,
            bool tipologiaId,
          })
        > {
  $$VociModelloTableTableManager(_$AppDatabase db, $VociModelloTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VociModelloTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VociModelloTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VociModelloTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> modelloId = const Value.absent(),
                Value<String?> genitoreId = const Value.absent(),
                Value<String> titolo = const Value.absent(),
                Value<String> descrizione = const Value.absent(),
                Value<String?> tipologiaId = const Value.absent(),
                Value<int?> giorni = const Value.absent(),
                Value<int?> minuti = const Value.absent(),
                Value<bool> nelCalendario = const Value.absent(),
                Value<int> ordine = const Value.absent(),
                Value<DateTime> aggiornataIl = const Value.absent(),
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VociModelloCompanion(
                id: id,
                modelloId: modelloId,
                genitoreId: genitoreId,
                titolo: titolo,
                descrizione: descrizione,
                tipologiaId: tipologiaId,
                giorni: giorni,
                minuti: minuti,
                nelCalendario: nelCalendario,
                ordine: ordine,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String modelloId,
                Value<String?> genitoreId = const Value.absent(),
                required String titolo,
                Value<String> descrizione = const Value.absent(),
                Value<String?> tipologiaId = const Value.absent(),
                Value<int?> giorni = const Value.absent(),
                Value<int?> minuti = const Value.absent(),
                Value<bool> nelCalendario = const Value.absent(),
                Value<int> ordine = const Value.absent(),
                required DateTime aggiornataIl,
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VociModelloCompanion.insert(
                id: id,
                modelloId: modelloId,
                genitoreId: genitoreId,
                titolo: titolo,
                descrizione: descrizione,
                tipologiaId: tipologiaId,
                giorni: giorni,
                minuti: minuti,
                nelCalendario: nelCalendario,
                ordine: ordine,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VociModelloTable, VoceModello>(table),
                  $$VociModelloTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({modelloId = false, genitoreId = false, tipologiaId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (modelloId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.modelloId,
                            referencedTable: $$VociModelloTableReferences
                                ._modelloIdTable(db),
                            referencedColumn: $$VociModelloTableReferences
                                ._modelloIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (genitoreId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.genitoreId,
                            referencedTable: $$VociModelloTableReferences
                                ._genitoreIdTable(db),
                            referencedColumn: $$VociModelloTableReferences
                                ._genitoreIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (tipologiaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tipologiaId,
                            referencedTable: $$VociModelloTableReferences
                                ._tipologiaIdTable(db),
                            referencedColumn: $$VociModelloTableReferences
                                ._tipologiaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$VociModelloTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VociModelloTable,
      VoceModello,
      $$VociModelloTableFilterComposer,
      $$VociModelloTableOrderingComposer,
      $$VociModelloTableAnnotationComposer,
      $$VociModelloTableCreateCompanionBuilder,
      $$VociModelloTableUpdateCompanionBuilder,
      (VoceModello, $$VociModelloTableReferences),
      VoceModello,
      PrefetchHooks Function({
        bool modelloId,
        bool genitoreId,
        bool tipologiaId,
      })
    >;
typedef $$ElencoAttivitaTableCreateCompanionBuilder =
    ElencoAttivitaCompanion Function({
      required String id,
      required String titolo,
      Value<String> descrizione,
      required DateTime creataIl,
      Value<DateTime?> scadenza,
      Value<bool> scadenzaConOra,
      Value<DateTime?> fattaIl,
      required String argomentoId,
      Value<String?> tipologiaId,
      Value<String?> genitoreId,
      Value<int> ordine,
      Value<String?> modelloId,
      Value<bool> nelCalendario,
      required DateTime aggiornataIl,
      Value<DateTime?> cancellataIl,
      Value<int> rowid,
    });
typedef $$ElencoAttivitaTableUpdateCompanionBuilder =
    ElencoAttivitaCompanion Function({
      Value<String> id,
      Value<String> titolo,
      Value<String> descrizione,
      Value<DateTime> creataIl,
      Value<DateTime?> scadenza,
      Value<bool> scadenzaConOra,
      Value<DateTime?> fattaIl,
      Value<String> argomentoId,
      Value<String?> tipologiaId,
      Value<String?> genitoreId,
      Value<int> ordine,
      Value<String?> modelloId,
      Value<bool> nelCalendario,
      Value<DateTime> aggiornataIl,
      Value<DateTime?> cancellataIl,
      Value<int> rowid,
    });

final class $$ElencoAttivitaTableReferences
    extends BaseReferences<_$AppDatabase, $ElencoAttivitaTable, Attivita> {
  $$ElencoAttivitaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ArgomentiTable _argomentoIdTable(_$AppDatabase db) =>
      db.argomenti.createAlias('attivita__argomento_id__argomenti__id');

  $$ArgomentiTableProcessedTableManager get argomentoId {
    final $_column = $_itemColumn<String>('argomento_id')!;

    final manager = $$ArgomentiTableTableManager(
      $_db,
      $_db.argomenti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_argomentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TipologieTable _tipologiaIdTable(_$AppDatabase db) =>
      db.tipologie.createAlias('attivita__tipologia_id__tipologie__id');

  $$TipologieTableProcessedTableManager? get tipologiaId {
    final $_column = $_itemColumn<String>('tipologia_id');
    if ($_column == null) return null;
    final manager = $$TipologieTableTableManager(
      $_db,
      $_db.tipologie,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tipologiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ElencoAttivitaTable _genitoreIdTable(_$AppDatabase db) =>
      db.elencoAttivita.createAlias('attivita__genitore_id__attivita__id');

  $$ElencoAttivitaTableProcessedTableManager? get genitoreId {
    final $_column = $_itemColumn<String>('genitore_id');
    if ($_column == null) return null;
    final manager = $$ElencoAttivitaTableTableManager(
      $_db,
      $_db.elencoAttivita,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_genitoreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ModelliTable _modelloIdTable(_$AppDatabase db) =>
      db.modelli.createAlias('attivita__modello_id__modelli__id');

  $$ModelliTableProcessedTableManager? get modelloId {
    final $_column = $_itemColumn<String>('modello_id');
    if ($_column == null) return null;
    final manager = $$ModelliTableTableManager(
      $_db,
      $_db.modelli,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelloIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ElencoFotoTable, List<Foto>> _elencoFotoRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.elencoFoto,
    aliasName: 'attivita__id__foto__attivita_id',
  );

  $$ElencoFotoTableProcessedTableManager get elencoFotoRefs {
    final manager = $$ElencoFotoTableTableManager(
      $_db,
      $_db.elencoFoto,
    ).filter((f) => f.attivitaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_elencoFotoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ElencoAttivitaTableFilterComposer
    extends Composer<_$AppDatabase, $ElencoAttivitaTable> {
  $$ElencoAttivitaTableFilterComposer({
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

  ColumnFilters<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creataIl => $composableBuilder(
    column: $table.creataIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scadenza => $composableBuilder(
    column: $table.scadenza,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scadenzaConOra => $composableBuilder(
    column: $table.scadenzaConOra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fattaIl => $composableBuilder(
    column: $table.fattaIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordine => $composableBuilder(
    column: $table.ordine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnFilters(column),
  );

  $$ArgomentiTableFilterComposer get argomentoId {
    final $$ArgomentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.argomentoId,
      referencedTable: $db.argomenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArgomentiTableFilterComposer(
            $db: $db,
            $table: $db.argomenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableFilterComposer get tipologiaId {
    final $$TipologieTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableFilterComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ElencoAttivitaTableFilterComposer get genitoreId {
    final $$ElencoAttivitaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genitoreId,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableFilterComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ModelliTableFilterComposer get modelloId {
    final $$ModelliTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelloId,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableFilterComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> elencoFotoRefs(
    Expression<bool> Function($$ElencoFotoTableFilterComposer f) f,
  ) {
    final $$ElencoFotoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoFoto,
      getReferencedColumn: (t) => t.attivitaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoFotoTableFilterComposer(
            $db: $db,
            $table: $db.elencoFoto,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ElencoAttivitaTableOrderingComposer
    extends Composer<_$AppDatabase, $ElencoAttivitaTable> {
  $$ElencoAttivitaTableOrderingComposer({
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

  ColumnOrderings<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creataIl => $composableBuilder(
    column: $table.creataIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scadenza => $composableBuilder(
    column: $table.scadenza,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scadenzaConOra => $composableBuilder(
    column: $table.scadenzaConOra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fattaIl => $composableBuilder(
    column: $table.fattaIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordine => $composableBuilder(
    column: $table.ordine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArgomentiTableOrderingComposer get argomentoId {
    final $$ArgomentiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.argomentoId,
      referencedTable: $db.argomenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArgomentiTableOrderingComposer(
            $db: $db,
            $table: $db.argomenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableOrderingComposer get tipologiaId {
    final $$TipologieTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableOrderingComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ElencoAttivitaTableOrderingComposer get genitoreId {
    final $$ElencoAttivitaTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genitoreId,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableOrderingComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ModelliTableOrderingComposer get modelloId {
    final $$ModelliTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelloId,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableOrderingComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ElencoAttivitaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ElencoAttivitaTable> {
  $$ElencoAttivitaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titolo =>
      $composableBuilder(column: $table.titolo, builder: (column) => column);

  GeneratedColumn<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creataIl =>
      $composableBuilder(column: $table.creataIl, builder: (column) => column);

  GeneratedColumn<DateTime> get scadenza =>
      $composableBuilder(column: $table.scadenza, builder: (column) => column);

  GeneratedColumn<bool> get scadenzaConOra => $composableBuilder(
    column: $table.scadenzaConOra,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fattaIl =>
      $composableBuilder(column: $table.fattaIl, builder: (column) => column);

  GeneratedColumn<int> get ordine =>
      $composableBuilder(column: $table.ordine, builder: (column) => column);

  GeneratedColumn<bool> get nelCalendario => $composableBuilder(
    column: $table.nelCalendario,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => column,
  );

  $$ArgomentiTableAnnotationComposer get argomentoId {
    final $$ArgomentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.argomentoId,
      referencedTable: $db.argomenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArgomentiTableAnnotationComposer(
            $db: $db,
            $table: $db.argomenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TipologieTableAnnotationComposer get tipologiaId {
    final $$TipologieTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tipologiaId,
      referencedTable: $db.tipologie,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TipologieTableAnnotationComposer(
            $db: $db,
            $table: $db.tipologie,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ElencoAttivitaTableAnnotationComposer get genitoreId {
    final $$ElencoAttivitaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genitoreId,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableAnnotationComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ModelliTableAnnotationComposer get modelloId {
    final $$ModelliTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelloId,
      referencedTable: $db.modelli,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelliTableAnnotationComposer(
            $db: $db,
            $table: $db.modelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> elencoFotoRefs<T extends Object>(
    Expression<T> Function($$ElencoFotoTableAnnotationComposer a) f,
  ) {
    final $$ElencoFotoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.elencoFoto,
      getReferencedColumn: (t) => t.attivitaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoFotoTableAnnotationComposer(
            $db: $db,
            $table: $db.elencoFoto,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ElencoAttivitaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ElencoAttivitaTable,
          Attivita,
          $$ElencoAttivitaTableFilterComposer,
          $$ElencoAttivitaTableOrderingComposer,
          $$ElencoAttivitaTableAnnotationComposer,
          $$ElencoAttivitaTableCreateCompanionBuilder,
          $$ElencoAttivitaTableUpdateCompanionBuilder,
          (Attivita, $$ElencoAttivitaTableReferences),
          Attivita,
          PrefetchHooks Function({
            bool argomentoId,
            bool tipologiaId,
            bool genitoreId,
            bool modelloId,
            bool elencoFotoRefs,
          })
        > {
  $$ElencoAttivitaTableTableManager(
    _$AppDatabase db,
    $ElencoAttivitaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ElencoAttivitaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ElencoAttivitaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ElencoAttivitaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> titolo = const Value.absent(),
                Value<String> descrizione = const Value.absent(),
                Value<DateTime> creataIl = const Value.absent(),
                Value<DateTime?> scadenza = const Value.absent(),
                Value<bool> scadenzaConOra = const Value.absent(),
                Value<DateTime?> fattaIl = const Value.absent(),
                Value<String> argomentoId = const Value.absent(),
                Value<String?> tipologiaId = const Value.absent(),
                Value<String?> genitoreId = const Value.absent(),
                Value<int> ordine = const Value.absent(),
                Value<String?> modelloId = const Value.absent(),
                Value<bool> nelCalendario = const Value.absent(),
                Value<DateTime> aggiornataIl = const Value.absent(),
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ElencoAttivitaCompanion(
                id: id,
                titolo: titolo,
                descrizione: descrizione,
                creataIl: creataIl,
                scadenza: scadenza,
                scadenzaConOra: scadenzaConOra,
                fattaIl: fattaIl,
                argomentoId: argomentoId,
                tipologiaId: tipologiaId,
                genitoreId: genitoreId,
                ordine: ordine,
                modelloId: modelloId,
                nelCalendario: nelCalendario,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String titolo,
                Value<String> descrizione = const Value.absent(),
                required DateTime creataIl,
                Value<DateTime?> scadenza = const Value.absent(),
                Value<bool> scadenzaConOra = const Value.absent(),
                Value<DateTime?> fattaIl = const Value.absent(),
                required String argomentoId,
                Value<String?> tipologiaId = const Value.absent(),
                Value<String?> genitoreId = const Value.absent(),
                Value<int> ordine = const Value.absent(),
                Value<String?> modelloId = const Value.absent(),
                Value<bool> nelCalendario = const Value.absent(),
                required DateTime aggiornataIl,
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ElencoAttivitaCompanion.insert(
                id: id,
                titolo: titolo,
                descrizione: descrizione,
                creataIl: creataIl,
                scadenza: scadenza,
                scadenzaConOra: scadenzaConOra,
                fattaIl: fattaIl,
                argomentoId: argomentoId,
                tipologiaId: tipologiaId,
                genitoreId: genitoreId,
                ordine: ordine,
                modelloId: modelloId,
                nelCalendario: nelCalendario,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ElencoAttivitaTable, Attivita>(table),
                  $$ElencoAttivitaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                argomentoId = false,
                tipologiaId = false,
                genitoreId = false,
                modelloId = false,
                elencoFotoRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (elencoFotoRefs) db.elencoFoto],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (argomentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.argomentoId,
                            referencedTable: $$ElencoAttivitaTableReferences
                                ._argomentoIdTable(db),
                            referencedColumn: $$ElencoAttivitaTableReferences
                                ._argomentoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (tipologiaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tipologiaId,
                            referencedTable: $$ElencoAttivitaTableReferences
                                ._tipologiaIdTable(db),
                            referencedColumn: $$ElencoAttivitaTableReferences
                                ._tipologiaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (genitoreId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.genitoreId,
                            referencedTable: $$ElencoAttivitaTableReferences
                                ._genitoreIdTable(db),
                            referencedColumn: $$ElencoAttivitaTableReferences
                                ._genitoreIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (modelloId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.modelloId,
                            referencedTable: $$ElencoAttivitaTableReferences
                                ._modelloIdTable(db),
                            referencedColumn: $$ElencoAttivitaTableReferences
                                ._modelloIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (elencoFotoRefs)
                        await $_getPrefetchedDataByColumns<
                          Attivita,
                          $ElencoAttivitaTable,
                          Foto,
                          $ElencoFotoTable
                        >(
                          currentTable: table,
                          referencedTable: $$ElencoAttivitaTableReferences
                              ._elencoFotoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ElencoAttivitaTableReferences(
                                db,
                                table,
                                p0,
                              ).elencoFotoRefs,
                          currentColumn: 'id',
                          referencedColumn: 'attivita_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ElencoAttivitaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ElencoAttivitaTable,
      Attivita,
      $$ElencoAttivitaTableFilterComposer,
      $$ElencoAttivitaTableOrderingComposer,
      $$ElencoAttivitaTableAnnotationComposer,
      $$ElencoAttivitaTableCreateCompanionBuilder,
      $$ElencoAttivitaTableUpdateCompanionBuilder,
      (Attivita, $$ElencoAttivitaTableReferences),
      Attivita,
      PrefetchHooks Function({
        bool argomentoId,
        bool tipologiaId,
        bool genitoreId,
        bool modelloId,
        bool elencoFotoRefs,
      })
    >;
typedef $$ElencoFotoTableCreateCompanionBuilder = ElencoFotoCompanion Function({
  required String id,
  required String attivitaId,
  required String nomeFile,
  required DateTime creataIl,
  required DateTime aggiornataIl,
  Value<DateTime?> cancellataIl,
  Value<int> rowid,
});
typedef $$ElencoFotoTableUpdateCompanionBuilder = ElencoFotoCompanion Function({
  Value<String> id,
  Value<String> attivitaId,
  Value<String> nomeFile,
  Value<DateTime> creataIl,
  Value<DateTime> aggiornataIl,
  Value<DateTime?> cancellataIl,
  Value<int> rowid,
});

final class $$ElencoFotoTableReferences
    extends BaseReferences<_$AppDatabase, $ElencoFotoTable, Foto> {
  $$ElencoFotoTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ElencoAttivitaTable _attivitaIdTable(_$AppDatabase db) =>
      db.elencoAttivita.createAlias('foto__attivita_id__attivita__id');

  $$ElencoAttivitaTableProcessedTableManager get attivitaId {
    final $_column = $_itemColumn<String>('attivita_id')!;

    final manager = $$ElencoAttivitaTableTableManager(
      $_db,
      $_db.elencoAttivita,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attivitaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ElencoFotoTableFilterComposer
    extends Composer<_$AppDatabase, $ElencoFotoTable> {
  $$ElencoFotoTableFilterComposer({
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

  ColumnFilters<String> get nomeFile => $composableBuilder(
    column: $table.nomeFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creataIl => $composableBuilder(
    column: $table.creataIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnFilters(column),
  );

  $$ElencoAttivitaTableFilterComposer get attivitaId {
    final $$ElencoAttivitaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attivitaId,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableFilterComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ElencoFotoTableOrderingComposer
    extends Composer<_$AppDatabase, $ElencoFotoTable> {
  $$ElencoFotoTableOrderingComposer({
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

  ColumnOrderings<String> get nomeFile => $composableBuilder(
    column: $table.nomeFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creataIl => $composableBuilder(
    column: $table.creataIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => ColumnOrderings(column),
  );

  $$ElencoAttivitaTableOrderingComposer get attivitaId {
    final $$ElencoAttivitaTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attivitaId,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableOrderingComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ElencoFotoTableAnnotationComposer
    extends Composer<_$AppDatabase, $ElencoFotoTable> {
  $$ElencoFotoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nomeFile =>
      $composableBuilder(column: $table.nomeFile, builder: (column) => column);

  GeneratedColumn<DateTime> get creataIl =>
      $composableBuilder(column: $table.creataIl, builder: (column) => column);

  GeneratedColumn<DateTime> get aggiornataIl => $composableBuilder(
    column: $table.aggiornataIl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancellataIl => $composableBuilder(
    column: $table.cancellataIl,
    builder: (column) => column,
  );

  $$ElencoAttivitaTableAnnotationComposer get attivitaId {
    final $$ElencoAttivitaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attivitaId,
      referencedTable: $db.elencoAttivita,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ElencoAttivitaTableAnnotationComposer(
            $db: $db,
            $table: $db.elencoAttivita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ElencoFotoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ElencoFotoTable,
          Foto,
          $$ElencoFotoTableFilterComposer,
          $$ElencoFotoTableOrderingComposer,
          $$ElencoFotoTableAnnotationComposer,
          $$ElencoFotoTableCreateCompanionBuilder,
          $$ElencoFotoTableUpdateCompanionBuilder,
          (Foto, $$ElencoFotoTableReferences),
          Foto,
          PrefetchHooks Function({bool attivitaId})
        > {
  $$ElencoFotoTableTableManager(_$AppDatabase db, $ElencoFotoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ElencoFotoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ElencoFotoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ElencoFotoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> attivitaId = const Value.absent(),
                Value<String> nomeFile = const Value.absent(),
                Value<DateTime> creataIl = const Value.absent(),
                Value<DateTime> aggiornataIl = const Value.absent(),
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ElencoFotoCompanion(
                id: id,
                attivitaId: attivitaId,
                nomeFile: nomeFile,
                creataIl: creataIl,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String attivitaId,
                required String nomeFile,
                required DateTime creataIl,
                required DateTime aggiornataIl,
                Value<DateTime?> cancellataIl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ElencoFotoCompanion.insert(
                id: id,
                attivitaId: attivitaId,
                nomeFile: nomeFile,
                creataIl: creataIl,
                aggiornataIl: aggiornataIl,
                cancellataIl: cancellataIl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ElencoFotoTable, Foto>(table),
                  $$ElencoFotoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attivitaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attivitaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.attivitaId,
                        referencedTable: $$ElencoFotoTableReferences
                            ._attivitaIdTable(db),
                        referencedColumn: $$ElencoFotoTableReferences
                            ._attivitaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ElencoFotoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ElencoFotoTable,
      Foto,
      $$ElencoFotoTableFilterComposer,
      $$ElencoFotoTableOrderingComposer,
      $$ElencoFotoTableAnnotationComposer,
      $$ElencoFotoTableCreateCompanionBuilder,
      $$ElencoFotoTableUpdateCompanionBuilder,
      (Foto, $$ElencoFotoTableReferences),
      Foto,
      PrefetchHooks Function({bool attivitaId})
    >;
typedef $$NoteSyncTableCreateCompanionBuilder = NoteSyncCompanion Function({
  required String tabella,
  required String id,
  required String impronta,
  Value<int> rowid,
});
typedef $$NoteSyncTableUpdateCompanionBuilder = NoteSyncCompanion Function({
  Value<String> tabella,
  Value<String> id,
  Value<String> impronta,
  Value<int> rowid,
});

class $$NoteSyncTableFilterComposer
    extends Composer<_$AppDatabase, $NoteSyncTable> {
  $$NoteSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tabella => $composableBuilder(
    column: $table.tabella,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impronta => $composableBuilder(
    column: $table.impronta,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteSyncTable> {
  $$NoteSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tabella => $composableBuilder(
    column: $table.tabella,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impronta => $composableBuilder(
    column: $table.impronta,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteSyncTable> {
  $$NoteSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tabella =>
      $composableBuilder(column: $table.tabella, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get impronta =>
      $composableBuilder(column: $table.impronta, builder: (column) => column);
}

class $$NoteSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteSyncTable,
          NotaSync,
          $$NoteSyncTableFilterComposer,
          $$NoteSyncTableOrderingComposer,
          $$NoteSyncTableAnnotationComposer,
          $$NoteSyncTableCreateCompanionBuilder,
          $$NoteSyncTableUpdateCompanionBuilder,
          (NotaSync, BaseReferences<_$AppDatabase, $NoteSyncTable, NotaSync>),
          NotaSync,
          PrefetchHooks Function()
        > {
  $$NoteSyncTableTableManager(_$AppDatabase db, $NoteSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tabella = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> impronta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteSyncCompanion(
                tabella: tabella,
                id: id,
                impronta: impronta,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tabella,
                required String id,
                required String impronta,
                Value<int> rowid = const Value.absent(),
              }) => NoteSyncCompanion.insert(
                tabella: tabella,
                id: id,
                impronta: impronta,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteSyncTable, NotaSync>(table),
                  BaseReferences<_$AppDatabase, $NoteSyncTable, NotaSync>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteSyncTable,
      NotaSync,
      $$NoteSyncTableFilterComposer,
      $$NoteSyncTableOrderingComposer,
      $$NoteSyncTableAnnotationComposer,
      $$NoteSyncTableCreateCompanionBuilder,
      $$NoteSyncTableUpdateCompanionBuilder,
      (NotaSync, BaseReferences<_$AppDatabase, $NoteSyncTable, NotaSync>),
      NotaSync,
      PrefetchHooks Function()
    >;
typedef $$PreferenzeTableCreateCompanionBuilder = PreferenzeCompanion Function({
  required String chiave,
  required String valore,
  Value<int> rowid,
});
typedef $$PreferenzeTableUpdateCompanionBuilder = PreferenzeCompanion Function({
  Value<String> chiave,
  Value<String> valore,
  Value<int> rowid,
});

class $$PreferenzeTableFilterComposer
    extends Composer<_$AppDatabase, $PreferenzeTable> {
  $$PreferenzeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chiave => $composableBuilder(
    column: $table.chiave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valore => $composableBuilder(
    column: $table.valore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenzeTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferenzeTable> {
  $$PreferenzeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chiave => $composableBuilder(
    column: $table.chiave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valore => $composableBuilder(
    column: $table.valore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenzeTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferenzeTable> {
  $$PreferenzeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chiave =>
      $composableBuilder(column: $table.chiave, builder: (column) => column);

  GeneratedColumn<String> get valore =>
      $composableBuilder(column: $table.valore, builder: (column) => column);
}

class $$PreferenzeTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferenzeTable,
          Preferenza,
          $$PreferenzeTableFilterComposer,
          $$PreferenzeTableOrderingComposer,
          $$PreferenzeTableAnnotationComposer,
          $$PreferenzeTableCreateCompanionBuilder,
          $$PreferenzeTableUpdateCompanionBuilder,
          (
            Preferenza,
            BaseReferences<_$AppDatabase, $PreferenzeTable, Preferenza>,
          ),
          Preferenza,
          PrefetchHooks Function()
        > {
  $$PreferenzeTableTableManager(_$AppDatabase db, $PreferenzeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenzeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenzeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenzeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chiave = const Value.absent(),
                Value<String> valore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferenzeCompanion(
                chiave: chiave,
                valore: valore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chiave,
                required String valore,
                Value<int> rowid = const Value.absent(),
              }) => PreferenzeCompanion.insert(
                chiave: chiave,
                valore: valore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferenzeTable, Preferenza>(table),
                  BaseReferences<_$AppDatabase, $PreferenzeTable, Preferenza>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenzeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferenzeTable,
      Preferenza,
      $$PreferenzeTableFilterComposer,
      $$PreferenzeTableOrderingComposer,
      $$PreferenzeTableAnnotationComposer,
      $$PreferenzeTableCreateCompanionBuilder,
      $$PreferenzeTableUpdateCompanionBuilder,
      (Preferenza, BaseReferences<_$AppDatabase, $PreferenzeTable, Preferenza>),
      Preferenza,
      PrefetchHooks Function()
    >;
typedef $$EventiCalendarioTableCreateCompanionBuilder =
    EventiCalendarioCompanion Function({
      required String attivitaId,
      required int eventoId,
      required int calendarioId,
      required String impronta,
      Value<int> rowid,
    });
typedef $$EventiCalendarioTableUpdateCompanionBuilder =
    EventiCalendarioCompanion Function({
      Value<String> attivitaId,
      Value<int> eventoId,
      Value<int> calendarioId,
      Value<String> impronta,
      Value<int> rowid,
    });

class $$EventiCalendarioTableFilterComposer
    extends Composer<_$AppDatabase, $EventiCalendarioTable> {
  $$EventiCalendarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attivitaId => $composableBuilder(
    column: $table.attivitaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventoId => $composableBuilder(
    column: $table.eventoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calendarioId => $composableBuilder(
    column: $table.calendarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impronta => $composableBuilder(
    column: $table.impronta,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventiCalendarioTableOrderingComposer
    extends Composer<_$AppDatabase, $EventiCalendarioTable> {
  $$EventiCalendarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attivitaId => $composableBuilder(
    column: $table.attivitaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventoId => $composableBuilder(
    column: $table.eventoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calendarioId => $composableBuilder(
    column: $table.calendarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impronta => $composableBuilder(
    column: $table.impronta,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventiCalendarioTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventiCalendarioTable> {
  $$EventiCalendarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attivitaId => $composableBuilder(
    column: $table.attivitaId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventoId =>
      $composableBuilder(column: $table.eventoId, builder: (column) => column);

  GeneratedColumn<int> get calendarioId => $composableBuilder(
    column: $table.calendarioId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get impronta =>
      $composableBuilder(column: $table.impronta, builder: (column) => column);
}

class $$EventiCalendarioTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventiCalendarioTable,
          EventoCalendario,
          $$EventiCalendarioTableFilterComposer,
          $$EventiCalendarioTableOrderingComposer,
          $$EventiCalendarioTableAnnotationComposer,
          $$EventiCalendarioTableCreateCompanionBuilder,
          $$EventiCalendarioTableUpdateCompanionBuilder,
          (
            EventoCalendario,
            BaseReferences<
              _$AppDatabase,
              $EventiCalendarioTable,
              EventoCalendario
            >,
          ),
          EventoCalendario,
          PrefetchHooks Function()
        > {
  $$EventiCalendarioTableTableManager(
    _$AppDatabase db,
    $EventiCalendarioTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventiCalendarioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventiCalendarioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventiCalendarioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attivitaId = const Value.absent(),
                Value<int> eventoId = const Value.absent(),
                Value<int> calendarioId = const Value.absent(),
                Value<String> impronta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventiCalendarioCompanion(
                attivitaId: attivitaId,
                eventoId: eventoId,
                calendarioId: calendarioId,
                impronta: impronta,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attivitaId,
                required int eventoId,
                required int calendarioId,
                required String impronta,
                Value<int> rowid = const Value.absent(),
              }) => EventiCalendarioCompanion.insert(
                attivitaId: attivitaId,
                eventoId: eventoId,
                calendarioId: calendarioId,
                impronta: impronta,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventiCalendarioTable, EventoCalendario>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EventiCalendarioTable,
                    EventoCalendario
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventiCalendarioTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventiCalendarioTable,
      EventoCalendario,
      $$EventiCalendarioTableFilterComposer,
      $$EventiCalendarioTableOrderingComposer,
      $$EventiCalendarioTableAnnotationComposer,
      $$EventiCalendarioTableCreateCompanionBuilder,
      $$EventiCalendarioTableUpdateCompanionBuilder,
      (
        EventoCalendario,
        BaseReferences<_$AppDatabase, $EventiCalendarioTable, EventoCalendario>,
      ),
      EventoCalendario,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArgomentiTableTableManager get argomenti =>
      $$ArgomentiTableTableManager(_db, _db.argomenti);
  $$TipologieTableTableManager get tipologie =>
      $$TipologieTableTableManager(_db, _db.tipologie);
  $$ModelliTableTableManager get modelli =>
      $$ModelliTableTableManager(_db, _db.modelli);
  $$VociModelloTableTableManager get vociModello =>
      $$VociModelloTableTableManager(_db, _db.vociModello);
  $$ElencoAttivitaTableTableManager get elencoAttivita =>
      $$ElencoAttivitaTableTableManager(_db, _db.elencoAttivita);
  $$ElencoFotoTableTableManager get elencoFoto =>
      $$ElencoFotoTableTableManager(_db, _db.elencoFoto);
  $$NoteSyncTableTableManager get noteSync =>
      $$NoteSyncTableTableManager(_db, _db.noteSync);
  $$PreferenzeTableTableManager get preferenze =>
      $$PreferenzeTableTableManager(_db, _db.preferenze);
  $$EventiCalendarioTableTableManager get eventiCalendario =>
      $$EventiCalendarioTableTableManager(_db, _db.eventiCalendario);
}
