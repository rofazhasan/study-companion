// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battle_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBattleHistoryCollection on Isar {
  IsarCollection<BattleHistory> get battleHistorys => this.collection();
}

const BattleHistorySchema = CollectionSchema(
  name: r'BattleHistory',
  id: 1857595052346510497,
  properties: {
    r'battleId': PropertySchema(
      id: 0,
      name: r'battleId',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'isWinner': PropertySchema(
      id: 2,
      name: r'isWinner',
      type: IsarType.bool,
    ),
    r'rank': PropertySchema(
      id: 3,
      name: r'rank',
      type: IsarType.long,
    ),
    r'score': PropertySchema(
      id: 4,
      name: r'score',
      type: IsarType.long,
    ),
    r'sessionJson': PropertySchema(
      id: 5,
      name: r'sessionJson',
      type: IsarType.string,
    ),
    r'topic': PropertySchema(
      id: 6,
      name: r'topic',
      type: IsarType.string,
    ),
    r'totalPlayers': PropertySchema(
      id: 7,
      name: r'totalPlayers',
      type: IsarType.long,
    )
  },
  estimateSize: _battleHistoryEstimateSize,
  serialize: _battleHistorySerialize,
  deserialize: _battleHistoryDeserialize,
  deserializeProp: _battleHistoryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _battleHistoryGetId,
  getLinks: _battleHistoryGetLinks,
  attach: _battleHistoryAttach,
  version: '3.1.0+1',
);

int _battleHistoryEstimateSize(
  BattleHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.battleId.length * 3;
  bytesCount += 3 + object.sessionJson.length * 3;
  bytesCount += 3 + object.topic.length * 3;
  return bytesCount;
}

void _battleHistorySerialize(
  BattleHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.battleId);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeBool(offsets[2], object.isWinner);
  writer.writeLong(offsets[3], object.rank);
  writer.writeLong(offsets[4], object.score);
  writer.writeString(offsets[5], object.sessionJson);
  writer.writeString(offsets[6], object.topic);
  writer.writeLong(offsets[7], object.totalPlayers);
}

BattleHistory _battleHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BattleHistory();
  object.battleId = reader.readString(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isWinner = reader.readBool(offsets[2]);
  object.rank = reader.readLong(offsets[3]);
  object.score = reader.readLong(offsets[4]);
  object.sessionJson = reader.readString(offsets[5]);
  object.topic = reader.readString(offsets[6]);
  object.totalPlayers = reader.readLong(offsets[7]);
  return object;
}

P _battleHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _battleHistoryGetId(BattleHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _battleHistoryGetLinks(BattleHistory object) {
  return [];
}

void _battleHistoryAttach(
    IsarCollection<dynamic> col, Id id, BattleHistory object) {
  object.id = id;
}

extension BattleHistoryQueryWhereSort
    on QueryBuilder<BattleHistory, BattleHistory, QWhere> {
  QueryBuilder<BattleHistory, BattleHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BattleHistoryQueryWhere
    on QueryBuilder<BattleHistory, BattleHistory, QWhereClause> {
  QueryBuilder<BattleHistory, BattleHistory, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BattleHistoryQueryFilter
    on QueryBuilder<BattleHistory, BattleHistory, QFilterCondition> {
  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'battleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'battleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'battleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'battleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'battleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'battleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'battleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'battleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'battleId',
        value: '',
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      battleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'battleId',
        value: '',
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      isWinnerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isWinner',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition> rankEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rank',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      rankGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rank',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      rankLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rank',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition> rankBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      scoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      scoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      scoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      scoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      sessionJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      topicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      totalPlayersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPlayers',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      totalPlayersGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPlayers',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      totalPlayersLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPlayers',
        value: value,
      ));
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterFilterCondition>
      totalPlayersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPlayers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BattleHistoryQueryObject
    on QueryBuilder<BattleHistory, BattleHistory, QFilterCondition> {}

extension BattleHistoryQueryLinks
    on QueryBuilder<BattleHistory, BattleHistory, QFilterCondition> {}

extension BattleHistoryQuerySortBy
    on QueryBuilder<BattleHistory, BattleHistory, QSortBy> {
  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByBattleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'battleId', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      sortByBattleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'battleId', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByIsWinner() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWinner', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      sortByIsWinnerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWinner', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortBySessionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionJson', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      sortBySessionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionJson', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> sortByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      sortByTotalPlayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayers', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      sortByTotalPlayersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayers', Sort.desc);
    });
  }
}

extension BattleHistoryQuerySortThenBy
    on QueryBuilder<BattleHistory, BattleHistory, QSortThenBy> {
  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByBattleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'battleId', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      thenByBattleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'battleId', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByIsWinner() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWinner', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      thenByIsWinnerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWinner', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenBySessionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionJson', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      thenBySessionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionJson', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy> thenByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      thenByTotalPlayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayers', Sort.asc);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QAfterSortBy>
      thenByTotalPlayersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayers', Sort.desc);
    });
  }
}

extension BattleHistoryQueryWhereDistinct
    on QueryBuilder<BattleHistory, BattleHistory, QDistinct> {
  QueryBuilder<BattleHistory, BattleHistory, QDistinct> distinctByBattleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'battleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QDistinct> distinctByIsWinner() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isWinner');
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QDistinct> distinctByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rank');
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QDistinct> distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QDistinct> distinctBySessionJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QDistinct> distinctByTopic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BattleHistory, BattleHistory, QDistinct>
      distinctByTotalPlayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPlayers');
    });
  }
}

extension BattleHistoryQueryProperty
    on QueryBuilder<BattleHistory, BattleHistory, QQueryProperty> {
  QueryBuilder<BattleHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BattleHistory, String, QQueryOperations> battleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'battleId');
    });
  }

  QueryBuilder<BattleHistory, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<BattleHistory, bool, QQueryOperations> isWinnerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isWinner');
    });
  }

  QueryBuilder<BattleHistory, int, QQueryOperations> rankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rank');
    });
  }

  QueryBuilder<BattleHistory, int, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<BattleHistory, String, QQueryOperations> sessionJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionJson');
    });
  }

  QueryBuilder<BattleHistory, String, QQueryOperations> topicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topic');
    });
  }

  QueryBuilder<BattleHistory, int, QQueryOperations> totalPlayersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPlayers');
    });
  }
}
