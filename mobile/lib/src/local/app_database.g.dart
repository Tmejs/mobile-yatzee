// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActiveGamesTable extends ActiveGames
    with TableInfo<$ActiveGamesTable, ActiveGame> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveGamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, snapshotJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveGame> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  ActiveGame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveGame(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActiveGamesTable createAlias(String alias) {
    return $ActiveGamesTable(attachedDatabase, alias);
  }
}

class ActiveGame extends DataClass implements Insertable<ActiveGame> {
  final String gameId;
  final String snapshotJson;
  final DateTime updatedAt;
  const ActiveGame({
    required this.gameId,
    required this.snapshotJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ActiveGamesCompanion toCompanion(bool nullToAbsent) {
    return ActiveGamesCompanion(
      gameId: Value(gameId),
      snapshotJson: Value(snapshotJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActiveGame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveGame(
      gameId: serializer.fromJson<String>(json['gameId']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ActiveGame copyWith({
    String? gameId,
    String? snapshotJson,
    DateTime? updatedAt,
  }) => ActiveGame(
    gameId: gameId ?? this.gameId,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActiveGame copyWithCompanion(ActiveGamesCompanion data) {
    return ActiveGame(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveGame(')
          ..write('gameId: $gameId, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, snapshotJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveGame &&
          other.gameId == this.gameId &&
          other.snapshotJson == this.snapshotJson &&
          other.updatedAt == this.updatedAt);
}

class ActiveGamesCompanion extends UpdateCompanion<ActiveGame> {
  final Value<String> gameId;
  final Value<String> snapshotJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActiveGamesCompanion({
    this.gameId = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActiveGamesCompanion.insert({
    required String gameId,
    required String snapshotJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       snapshotJson = Value(snapshotJson),
       updatedAt = Value(updatedAt);
  static Insertable<ActiveGame> custom({
    Expression<String>? gameId,
    Expression<String>? snapshotJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActiveGamesCompanion copyWith({
    Value<String>? gameId,
    Value<String>? snapshotJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActiveGamesCompanion(
      gameId: gameId ?? this.gameId,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveGamesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletedGamesTable extends CompletedGames
    with TableInfo<$CompletedGamesTable, CompletedGameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedGamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesetIdMeta = const VerificationMeta(
    'rulesetId',
  );
  @override
  late final GeneratedColumn<String> rulesetId = GeneratedColumn<String>(
    'ruleset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesetVersionMeta = const VerificationMeta(
    'rulesetVersion',
  );
  @override
  late final GeneratedColumn<int> rulesetVersion = GeneratedColumn<int>(
    'ruleset_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankedIntentMeta = const VerificationMeta(
    'rankedIntent',
  );
  @override
  late final GeneratedColumn<bool> rankedIntent = GeneratedColumn<bool>(
    'ranked_intent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ranked_intent" IN (0, 1))',
    ),
  );
  static const VerificationMeta _completedAtMicrosMeta = const VerificationMeta(
    'completedAtMicros',
  );
  @override
  late final GeneratedColumn<int> completedAtMicros = GeneratedColumn<int>(
    'completed_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playersJsonMeta = const VerificationMeta(
    'playersJson',
  );
  @override
  late final GeneratedColumn<String> playersJson = GeneratedColumn<String>(
    'players_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    mode,
    rulesetId,
    rulesetVersion,
    rankedIntent,
    completedAtMicros,
    playersJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedGameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('ruleset_id')) {
      context.handle(
        _rulesetIdMeta,
        rulesetId.isAcceptableOrUnknown(data['ruleset_id']!, _rulesetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rulesetIdMeta);
    }
    if (data.containsKey('ruleset_version')) {
      context.handle(
        _rulesetVersionMeta,
        rulesetVersion.isAcceptableOrUnknown(
          data['ruleset_version']!,
          _rulesetVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rulesetVersionMeta);
    }
    if (data.containsKey('ranked_intent')) {
      context.handle(
        _rankedIntentMeta,
        rankedIntent.isAcceptableOrUnknown(
          data['ranked_intent']!,
          _rankedIntentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rankedIntentMeta);
    }
    if (data.containsKey('completed_at_micros')) {
      context.handle(
        _completedAtMicrosMeta,
        completedAtMicros.isAcceptableOrUnknown(
          data['completed_at_micros']!,
          _completedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMicrosMeta);
    }
    if (data.containsKey('players_json')) {
      context.handle(
        _playersJsonMeta,
        playersJson.isAcceptableOrUnknown(
          data['players_json']!,
          _playersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playersJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  CompletedGameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedGameRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      rulesetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruleset_id'],
      )!,
      rulesetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ruleset_version'],
      )!,
      rankedIntent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ranked_intent'],
      )!,
      completedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_micros'],
      )!,
      playersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}players_json'],
      )!,
    );
  }

  @override
  $CompletedGamesTable createAlias(String alias) {
    return $CompletedGamesTable(attachedDatabase, alias);
  }
}

class CompletedGameRow extends DataClass
    implements Insertable<CompletedGameRow> {
  final String gameId;
  final String mode;
  final String rulesetId;
  final int rulesetVersion;
  final bool rankedIntent;
  final int completedAtMicros;
  final String playersJson;
  const CompletedGameRow({
    required this.gameId,
    required this.mode,
    required this.rulesetId,
    required this.rulesetVersion,
    required this.rankedIntent,
    required this.completedAtMicros,
    required this.playersJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['mode'] = Variable<String>(mode);
    map['ruleset_id'] = Variable<String>(rulesetId);
    map['ruleset_version'] = Variable<int>(rulesetVersion);
    map['ranked_intent'] = Variable<bool>(rankedIntent);
    map['completed_at_micros'] = Variable<int>(completedAtMicros);
    map['players_json'] = Variable<String>(playersJson);
    return map;
  }

  CompletedGamesCompanion toCompanion(bool nullToAbsent) {
    return CompletedGamesCompanion(
      gameId: Value(gameId),
      mode: Value(mode),
      rulesetId: Value(rulesetId),
      rulesetVersion: Value(rulesetVersion),
      rankedIntent: Value(rankedIntent),
      completedAtMicros: Value(completedAtMicros),
      playersJson: Value(playersJson),
    );
  }

  factory CompletedGameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedGameRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      mode: serializer.fromJson<String>(json['mode']),
      rulesetId: serializer.fromJson<String>(json['rulesetId']),
      rulesetVersion: serializer.fromJson<int>(json['rulesetVersion']),
      rankedIntent: serializer.fromJson<bool>(json['rankedIntent']),
      completedAtMicros: serializer.fromJson<int>(json['completedAtMicros']),
      playersJson: serializer.fromJson<String>(json['playersJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'mode': serializer.toJson<String>(mode),
      'rulesetId': serializer.toJson<String>(rulesetId),
      'rulesetVersion': serializer.toJson<int>(rulesetVersion),
      'rankedIntent': serializer.toJson<bool>(rankedIntent),
      'completedAtMicros': serializer.toJson<int>(completedAtMicros),
      'playersJson': serializer.toJson<String>(playersJson),
    };
  }

  CompletedGameRow copyWith({
    String? gameId,
    String? mode,
    String? rulesetId,
    int? rulesetVersion,
    bool? rankedIntent,
    int? completedAtMicros,
    String? playersJson,
  }) => CompletedGameRow(
    gameId: gameId ?? this.gameId,
    mode: mode ?? this.mode,
    rulesetId: rulesetId ?? this.rulesetId,
    rulesetVersion: rulesetVersion ?? this.rulesetVersion,
    rankedIntent: rankedIntent ?? this.rankedIntent,
    completedAtMicros: completedAtMicros ?? this.completedAtMicros,
    playersJson: playersJson ?? this.playersJson,
  );
  CompletedGameRow copyWithCompanion(CompletedGamesCompanion data) {
    return CompletedGameRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      mode: data.mode.present ? data.mode.value : this.mode,
      rulesetId: data.rulesetId.present ? data.rulesetId.value : this.rulesetId,
      rulesetVersion: data.rulesetVersion.present
          ? data.rulesetVersion.value
          : this.rulesetVersion,
      rankedIntent: data.rankedIntent.present
          ? data.rankedIntent.value
          : this.rankedIntent,
      completedAtMicros: data.completedAtMicros.present
          ? data.completedAtMicros.value
          : this.completedAtMicros,
      playersJson: data.playersJson.present
          ? data.playersJson.value
          : this.playersJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletedGameRow(')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('rulesetId: $rulesetId, ')
          ..write('rulesetVersion: $rulesetVersion, ')
          ..write('rankedIntent: $rankedIntent, ')
          ..write('completedAtMicros: $completedAtMicros, ')
          ..write('playersJson: $playersJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    mode,
    rulesetId,
    rulesetVersion,
    rankedIntent,
    completedAtMicros,
    playersJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedGameRow &&
          other.gameId == this.gameId &&
          other.mode == this.mode &&
          other.rulesetId == this.rulesetId &&
          other.rulesetVersion == this.rulesetVersion &&
          other.rankedIntent == this.rankedIntent &&
          other.completedAtMicros == this.completedAtMicros &&
          other.playersJson == this.playersJson);
}

class CompletedGamesCompanion extends UpdateCompanion<CompletedGameRow> {
  final Value<String> gameId;
  final Value<String> mode;
  final Value<String> rulesetId;
  final Value<int> rulesetVersion;
  final Value<bool> rankedIntent;
  final Value<int> completedAtMicros;
  final Value<String> playersJson;
  final Value<int> rowid;
  const CompletedGamesCompanion({
    this.gameId = const Value.absent(),
    this.mode = const Value.absent(),
    this.rulesetId = const Value.absent(),
    this.rulesetVersion = const Value.absent(),
    this.rankedIntent = const Value.absent(),
    this.completedAtMicros = const Value.absent(),
    this.playersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletedGamesCompanion.insert({
    required String gameId,
    required String mode,
    required String rulesetId,
    required int rulesetVersion,
    required bool rankedIntent,
    required int completedAtMicros,
    required String playersJson,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       mode = Value(mode),
       rulesetId = Value(rulesetId),
       rulesetVersion = Value(rulesetVersion),
       rankedIntent = Value(rankedIntent),
       completedAtMicros = Value(completedAtMicros),
       playersJson = Value(playersJson);
  static Insertable<CompletedGameRow> custom({
    Expression<String>? gameId,
    Expression<String>? mode,
    Expression<String>? rulesetId,
    Expression<int>? rulesetVersion,
    Expression<bool>? rankedIntent,
    Expression<int>? completedAtMicros,
    Expression<String>? playersJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (mode != null) 'mode': mode,
      if (rulesetId != null) 'ruleset_id': rulesetId,
      if (rulesetVersion != null) 'ruleset_version': rulesetVersion,
      if (rankedIntent != null) 'ranked_intent': rankedIntent,
      if (completedAtMicros != null) 'completed_at_micros': completedAtMicros,
      if (playersJson != null) 'players_json': playersJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletedGamesCompanion copyWith({
    Value<String>? gameId,
    Value<String>? mode,
    Value<String>? rulesetId,
    Value<int>? rulesetVersion,
    Value<bool>? rankedIntent,
    Value<int>? completedAtMicros,
    Value<String>? playersJson,
    Value<int>? rowid,
  }) {
    return CompletedGamesCompanion(
      gameId: gameId ?? this.gameId,
      mode: mode ?? this.mode,
      rulesetId: rulesetId ?? this.rulesetId,
      rulesetVersion: rulesetVersion ?? this.rulesetVersion,
      rankedIntent: rankedIntent ?? this.rankedIntent,
      completedAtMicros: completedAtMicros ?? this.completedAtMicros,
      playersJson: playersJson ?? this.playersJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (rulesetId.present) {
      map['ruleset_id'] = Variable<String>(rulesetId.value);
    }
    if (rulesetVersion.present) {
      map['ruleset_version'] = Variable<int>(rulesetVersion.value);
    }
    if (rankedIntent.present) {
      map['ranked_intent'] = Variable<bool>(rankedIntent.value);
    }
    if (completedAtMicros.present) {
      map['completed_at_micros'] = Variable<int>(completedAtMicros.value);
    }
    if (playersJson.present) {
      map['players_json'] = Variable<String>(playersJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedGamesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('rulesetId: $rulesetId, ')
          ..write('rulesetVersion: $rulesetVersion, ')
          ..write('rankedIntent: $rankedIntent, ')
          ..write('completedAtMicros: $completedAtMicros, ')
          ..write('playersJson: $playersJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String key;
  final String value;
  const Preference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory Preference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Preference copyWith({String? key, String? value}) =>
      Preference(key: key ?? this.key, value: value ?? this.value);
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference &&
          other.key == this.key &&
          other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Preference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActiveGamesTable activeGames = $ActiveGamesTable(this);
  late final $CompletedGamesTable completedGames = $CompletedGamesTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activeGames,
    completedGames,
    preferences,
  ];
}

typedef $$ActiveGamesTableCreateCompanionBuilder =
    ActiveGamesCompanion Function({
      required String gameId,
      required String snapshotJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ActiveGamesTableUpdateCompanionBuilder =
    ActiveGamesCompanion Function({
      Value<String> gameId,
      Value<String> snapshotJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ActiveGamesTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveGamesTable> {
  $$ActiveGamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActiveGamesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveGamesTable> {
  $$ActiveGamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActiveGamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveGamesTable> {
  $$ActiveGamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ActiveGamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveGamesTable,
          ActiveGame,
          $$ActiveGamesTableFilterComposer,
          $$ActiveGamesTableOrderingComposer,
          $$ActiveGamesTableAnnotationComposer,
          $$ActiveGamesTableCreateCompanionBuilder,
          $$ActiveGamesTableUpdateCompanionBuilder,
          (
            ActiveGame,
            BaseReferences<_$AppDatabase, $ActiveGamesTable, ActiveGame>,
          ),
          ActiveGame,
          PrefetchHooks Function()
        > {
  $$ActiveGamesTableTableManager(_$AppDatabase db, $ActiveGamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveGamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveGamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveGamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveGamesCompanion(
                gameId: gameId,
                snapshotJson: snapshotJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required String snapshotJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActiveGamesCompanion.insert(
                gameId: gameId,
                snapshotJson: snapshotJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActiveGamesTable, ActiveGame>(table),
                  BaseReferences<_$AppDatabase, $ActiveGamesTable, ActiveGame>(
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

typedef $$ActiveGamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveGamesTable,
      ActiveGame,
      $$ActiveGamesTableFilterComposer,
      $$ActiveGamesTableOrderingComposer,
      $$ActiveGamesTableAnnotationComposer,
      $$ActiveGamesTableCreateCompanionBuilder,
      $$ActiveGamesTableUpdateCompanionBuilder,
      (
        ActiveGame,
        BaseReferences<_$AppDatabase, $ActiveGamesTable, ActiveGame>,
      ),
      ActiveGame,
      PrefetchHooks Function()
    >;
typedef $$CompletedGamesTableCreateCompanionBuilder =
    CompletedGamesCompanion Function({
      required String gameId,
      required String mode,
      required String rulesetId,
      required int rulesetVersion,
      required bool rankedIntent,
      required int completedAtMicros,
      required String playersJson,
      Value<int> rowid,
    });
typedef $$CompletedGamesTableUpdateCompanionBuilder =
    CompletedGamesCompanion Function({
      Value<String> gameId,
      Value<String> mode,
      Value<String> rulesetId,
      Value<int> rulesetVersion,
      Value<bool> rankedIntent,
      Value<int> completedAtMicros,
      Value<String> playersJson,
      Value<int> rowid,
    });

class $$CompletedGamesTableFilterComposer
    extends Composer<_$AppDatabase, $CompletedGamesTable> {
  $$CompletedGamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesetId => $composableBuilder(
    column: $table.rulesetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rulesetVersion => $composableBuilder(
    column: $table.rulesetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rankedIntent => $composableBuilder(
    column: $table.rankedIntent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playersJson => $composableBuilder(
    column: $table.playersJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedGamesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletedGamesTable> {
  $$CompletedGamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesetId => $composableBuilder(
    column: $table.rulesetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rulesetVersion => $composableBuilder(
    column: $table.rulesetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rankedIntent => $composableBuilder(
    column: $table.rankedIntent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playersJson => $composableBuilder(
    column: $table.playersJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedGamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletedGamesTable> {
  $$CompletedGamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get rulesetId =>
      $composableBuilder(column: $table.rulesetId, builder: (column) => column);

  GeneratedColumn<int> get rulesetVersion => $composableBuilder(
    column: $table.rulesetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rankedIntent => $composableBuilder(
    column: $table.rankedIntent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playersJson => $composableBuilder(
    column: $table.playersJson,
    builder: (column) => column,
  );
}

class $$CompletedGamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletedGamesTable,
          CompletedGameRow,
          $$CompletedGamesTableFilterComposer,
          $$CompletedGamesTableOrderingComposer,
          $$CompletedGamesTableAnnotationComposer,
          $$CompletedGamesTableCreateCompanionBuilder,
          $$CompletedGamesTableUpdateCompanionBuilder,
          (
            CompletedGameRow,
            BaseReferences<
              _$AppDatabase,
              $CompletedGamesTable,
              CompletedGameRow
            >,
          ),
          CompletedGameRow,
          PrefetchHooks Function()
        > {
  $$CompletedGamesTableTableManager(
    _$AppDatabase db,
    $CompletedGamesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletedGamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletedGamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletedGamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> rulesetId = const Value.absent(),
                Value<int> rulesetVersion = const Value.absent(),
                Value<bool> rankedIntent = const Value.absent(),
                Value<int> completedAtMicros = const Value.absent(),
                Value<String> playersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletedGamesCompanion(
                gameId: gameId,
                mode: mode,
                rulesetId: rulesetId,
                rulesetVersion: rulesetVersion,
                rankedIntent: rankedIntent,
                completedAtMicros: completedAtMicros,
                playersJson: playersJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required String mode,
                required String rulesetId,
                required int rulesetVersion,
                required bool rankedIntent,
                required int completedAtMicros,
                required String playersJson,
                Value<int> rowid = const Value.absent(),
              }) => CompletedGamesCompanion.insert(
                gameId: gameId,
                mode: mode,
                rulesetId: rulesetId,
                rulesetVersion: rulesetVersion,
                rankedIntent: rankedIntent,
                completedAtMicros: completedAtMicros,
                playersJson: playersJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletedGamesTable, CompletedGameRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletedGamesTable,
                    CompletedGameRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedGamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletedGamesTable,
      CompletedGameRow,
      $$CompletedGamesTableFilterComposer,
      $$CompletedGamesTableOrderingComposer,
      $$CompletedGamesTableAnnotationComposer,
      $$CompletedGamesTableCreateCompanionBuilder,
      $$CompletedGamesTableUpdateCompanionBuilder,
      (
        CompletedGameRow,
        BaseReferences<_$AppDatabase, $CompletedGamesTable, CompletedGameRow>,
      ),
      CompletedGameRow,
      PrefetchHooks Function()
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTable,
          Preference,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            Preference,
            BaseReferences<_$AppDatabase, $PreferencesTable, Preference>,
          ),
          Preference,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$AppDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferencesTable, Preference>(table),
                  BaseReferences<_$AppDatabase, $PreferencesTable, Preference>(
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

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTable,
      Preference,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        Preference,
        BaseReferences<_$AppDatabase, $PreferencesTable, Preference>,
      ),
      Preference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActiveGamesTableTableManager get activeGames =>
      $$ActiveGamesTableTableManager(_db, _db.activeGames);
  $$CompletedGamesTableTableManager get completedGames =>
      $$CompletedGamesTableTableManager(_db, _db.completedGames);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
