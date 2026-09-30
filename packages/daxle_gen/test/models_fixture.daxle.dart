// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'models_fixture.dart';

const _statusEnumMap = {
  Status.pending: 'pending',
  Status.active: 'active',
  Status.completed: 'completed',
};
dynamic statusToValue(Status instance) => _statusEnumMap[instance]!;
Status statusFromValue(Object? value) => switch (value) {
  'pending' => Status.pending,
  'active' => Status.active,
  'completed' => Status.completed,
  _ => throw ArgumentError('Unknown Status value: $value'),
};

extension StatusDaxleEnumExtension on Status {
  dynamic toValue() => statusToValue(this);
}

mixin _$StatusStringify on Enum {
  @override
  String toString() => switch (this as Status) {
    Status.pending => 'Status.pending',
    Status.active => 'Status.active',
    Status.completed => 'Status.completed',
  };
}

const _priorityEnumMap = {
  Priority.low: 10,
  Priority.medium: 20,
  Priority.high: 30,
};
dynamic priorityToValue(Priority instance) => _priorityEnumMap[instance]!;
Priority priorityFromValue(Object? value) => switch (value) {
  10 => Priority.low,
  20 => Priority.medium,
  30 => Priority.high,
  _ => throw ArgumentError('Unknown Priority value: $value'),
};

extension PriorityDaxleEnumExtension on Priority {
  dynamic toValue() => priorityToValue(this);
}

const _multiParamEnumEnumMap = {
  MultiParamEnum.first: 101,
  MultiParamEnum.second: 202,
};
dynamic multiParamEnumToValue(MultiParamEnum instance) =>
    _multiParamEnumEnumMap[instance]!;
MultiParamEnum multiParamEnumFromValue(Object? value) => switch (value) {
  101 => MultiParamEnum.first,
  202 => MultiParamEnum.second,
  _ => throw ArgumentError('Unknown MultiParamEnum value: $value'),
};

extension MultiParamEnumDaxleEnumExtension on MultiParamEnum {
  dynamic toValue() => multiParamEnumToValue(this);
}

const _themeModeEnumMap = {
  ThemeMode.lightTheme: 'light-theme',
  ThemeMode.darkTheme: 'dark-theme',
  ThemeMode.systemDefault: 'system-default',
};
dynamic themeModeToValue(ThemeMode instance) => _themeModeEnumMap[instance]!;
ThemeMode themeModeFromValue(Object? value) => switch (value) {
  'light-theme' => ThemeMode.lightTheme,
  'dark-theme' => ThemeMode.darkTheme,
  'system-default' => ThemeMode.systemDefault,
  _ => throw ArgumentError('Unknown ThemeMode value: $value'),
};

extension ThemeModeDaxleEnumExtension on ThemeMode {
  dynamic toValue() => themeModeToValue(this);
}

const _annotatedEnumEnumMap = {
  AnnotatedEnum.inProgress: 'in_progress',
  AnnotatedEnum.archived: 'archived_val',
};
dynamic annotatedEnumToValue(AnnotatedEnum instance) =>
    _annotatedEnumEnumMap[instance]!;
AnnotatedEnum annotatedEnumFromValue(Object? value) => switch (value) {
  'in_progress' => AnnotatedEnum.inProgress,
  'archived_val' => AnnotatedEnum.archived,
  _ => throw ArgumentError('Unknown AnnotatedEnum value: $value'),
};

extension AnnotatedEnumDaxleEnumExtension on AnnotatedEnum {
  dynamic toValue() => annotatedEnumToValue(this);
}

const _accountTypeEnumMap = {
  AccountType.standard: 'std',
  AccountType.premium: 'prem',
};
dynamic accountTypeToValue(AccountType instance) =>
    _accountTypeEnumMap[instance]!;
AccountType accountTypeFromValue(Object? value) => switch (value) {
  'std' => AccountType.standard,
  'prem' => AccountType.premium,
  _ => AccountType.standard,
};

extension AccountTypeDaxleEnumExtension on AccountType {
  dynamic toValue() => accountTypeToValue(this);
}

mixin _$AccountTypeStringify on Enum {
  @override
  String toString() => switch (this as AccountType) {
    AccountType.standard => 'AccountType.standard',
    AccountType.premium => 'AccountType.premium',
    AccountType.internalTest => 'AccountType.internalTest',
  };
}

const _paymentStatusEnumMap = {
  PaymentStatus.pending: 'pay_pending',
  PaymentStatus.success: 'pay_success',
  PaymentStatus.failed: 'pay_failed',
};
dynamic paymentStatusToValue(PaymentStatus instance) =>
    _paymentStatusEnumMap[instance]!;
PaymentStatus paymentStatusFromValue(Object? value) => switch (value) {
  'pay_pending' ||
  'pending' ||
  'PAY_PENDING' ||
  'in_progress' => PaymentStatus.pending,
  'pay_success' || 'success' || 'completed' => PaymentStatus.success,
  'pay_failed' || 'failed' || 'error' => PaymentStatus.failed,
  _ => throw ArgumentError('Unknown PaymentStatus value: $value'),
};

extension PaymentStatusDaxleEnumExtension on PaymentStatus {
  dynamic toValue() => paymentStatusToValue(this);
}

mixin _$PaymentStatusStringify on Enum {
  @override
  String toString() => switch (this as PaymentStatus) {
    PaymentStatus.pending => 'PaymentStatus.pending',
    PaymentStatus.success => 'PaymentStatus.success',
    PaymentStatus.failed => 'PaymentStatus.failed',
  };
}

dynamic userIdToMap(UserId instance) => instance.id;

extension UserIdToMapExtension on UserId {
  dynamic toMap() => userIdToMap(this);
}

UserId userIdFromMap(Object? json) => UserId((json as String));
dynamic scoreToMap(Score instance) => instance.value;

extension ScoreToMapExtension on Score {
  dynamic toMap() => scoreToMap(this);
}

Score scoreFromMap(Object? json) => Score(((json as num).toInt()));
Map<String, dynamic> userInfoRecordToMap(UserInfoRecord instance) => {
  'name': instance.name,
  'age': instance.age,
};

extension UserInfoRecordToMapExtension on UserInfoRecord {
  Map<String, dynamic> toMap() => userInfoRecordToMap(this);
}

UserInfoRecord userInfoRecordFromMap(Map<String, dynamic> map) =>
    (name: (map['name'] as String), age: ((map['age'] as num).toInt()));

extension UserInfoRecordMapExtension on Map<String, dynamic> {
  UserInfoRecord toUserInfoRecord() => userInfoRecordFromMap(this);
}

List<dynamic> geoCoordsRecordToList(GeoCoordsRecord instance) => [
  instance.$1,
  instance.$2,
];

extension GeoCoordsRecordToListExtension on GeoCoordsRecord {
  List<dynamic> toList() => geoCoordsRecordToList(this);
}

GeoCoordsRecord geoCoordsRecordFromList(List<dynamic> list) =>
    (((list[0] as num).toDouble()), ((list[1] as num).toDouble()));

extension GeoCoordsRecordListExtension on List<dynamic> {
  GeoCoordsRecord toGeoCoordsRecord() => geoCoordsRecordFromList(this);
}

ComplexModel complexModelFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {
      'id': final String idRaw,
      'count': final num countRaw,
      'rating': final num ratingRaw,
      'isActive': final bool isActiveRaw,
      'createdAt': final String createdAtRaw,
      'website': final String websiteRaw,
      'score': final String scoreRaw,
      'timeout': final num timeoutRaw,
      'metadata': final Map metadataRaw,
      'tags': final List tagsRaw,
      'numbers': final List numbersRaw,
      'scores': final Map scoresRaw,
      'status': final Object statusRaw,
      'priority': final Object priorityRaw,
    } =>
      ComplexModel(
        idRaw,
        countRaw.toInt(),
        ratingRaw.toDouble(),
        isActiveRaw,
        DateTime.parse(createdAtRaw),
        Uri.parse(websiteRaw),
        BigInt.parse(scoreRaw),
        Duration(microseconds: timeoutRaw.toInt()),
        (json['optionalTag'] as String?),
        QueryMap(metadataRaw.cast<Object?, Object?>()),
        tagsRaw.cast<dynamic>().map((e) => (e as String)).toList(),
        numbersRaw.cast<dynamic>().map((e) => ((e as num).toInt())).toSet(),
        scoresRaw.cast<String, dynamic>().map(
          (k, v) => MapEntry(k, ((v as num).toInt())),
        ),
        statusFromValue(statusRaw),
        priorityFromValue(priorityRaw),
        role: json['role'] == null ? 'guest' : (json['role'] as String),
        customEpoch: json['customEpoch'] == null
            ? null
            : const EpochDateTimeConverter().fromJson(json['customEpoch']),
      ),
    _ => () {
      if (!json.containsKey('id')) {
        throw FormatException(
          "Missing required field 'id' for ComplexModel",
          json,
        );
      }
      if (json['id'] is! String) {
        throw FormatException(
          "Invalid type for field 'id' on ComplexModel: expected String, got ${json['id'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('count')) {
        throw FormatException(
          "Missing required field 'count' for ComplexModel",
          json,
        );
      }
      if (json['count'] is! num) {
        throw FormatException(
          "Invalid type for field 'count' on ComplexModel: expected num, got ${json['count'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('rating')) {
        throw FormatException(
          "Missing required field 'rating' for ComplexModel",
          json,
        );
      }
      if (json['rating'] is! num) {
        throw FormatException(
          "Invalid type for field 'rating' on ComplexModel: expected num, got ${json['rating'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('isActive')) {
        throw FormatException(
          "Missing required field 'isActive' for ComplexModel",
          json,
        );
      }
      if (json['isActive'] is! bool) {
        throw FormatException(
          "Invalid type for field 'isActive' on ComplexModel: expected bool, got ${json['isActive'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('createdAt')) {
        throw FormatException(
          "Missing required field 'createdAt' for ComplexModel",
          json,
        );
      }
      if (json['createdAt'] is! String) {
        throw FormatException(
          "Invalid type for field 'createdAt' on ComplexModel: expected String, got ${json['createdAt'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('website')) {
        throw FormatException(
          "Missing required field 'website' for ComplexModel",
          json,
        );
      }
      if (json['website'] is! String) {
        throw FormatException(
          "Invalid type for field 'website' on ComplexModel: expected String, got ${json['website'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('score')) {
        throw FormatException(
          "Missing required field 'score' for ComplexModel",
          json,
        );
      }
      if (json['score'] is! String) {
        throw FormatException(
          "Invalid type for field 'score' on ComplexModel: expected String, got ${json['score'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('timeout')) {
        throw FormatException(
          "Missing required field 'timeout' for ComplexModel",
          json,
        );
      }
      if (json['timeout'] is! num) {
        throw FormatException(
          "Invalid type for field 'timeout' on ComplexModel: expected num, got ${json['timeout'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('metadata')) {
        throw FormatException(
          "Missing required field 'metadata' for ComplexModel",
          json,
        );
      }
      if (json['metadata'] is! Map) {
        throw FormatException(
          "Invalid type for field 'metadata' on ComplexModel: expected Map, got ${json['metadata'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('tags')) {
        throw FormatException(
          "Missing required field 'tags' for ComplexModel",
          json,
        );
      }
      if (json['tags'] is! List) {
        throw FormatException(
          "Invalid type for field 'tags' on ComplexModel: expected List, got ${json['tags'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('numbers')) {
        throw FormatException(
          "Missing required field 'numbers' for ComplexModel",
          json,
        );
      }
      if (json['numbers'] is! List) {
        throw FormatException(
          "Invalid type for field 'numbers' on ComplexModel: expected List, got ${json['numbers'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('scores')) {
        throw FormatException(
          "Missing required field 'scores' for ComplexModel",
          json,
        );
      }
      if (json['scores'] is! Map) {
        throw FormatException(
          "Invalid type for field 'scores' on ComplexModel: expected Map, got ${json['scores'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('status')) {
        throw FormatException(
          "Missing required field 'status' for ComplexModel",
          json,
        );
      }
      if (json['status'] == null) {
        throw FormatException(
          "Invalid type for field 'status' on ComplexModel: expected non-null value, got Null",
          json,
        );
      }
      if (!json.containsKey('priority')) {
        throw FormatException(
          "Missing required field 'priority' for ComplexModel",
          json,
        );
      }
      if (json['priority'] == null) {
        throw FormatException(
          "Invalid type for field 'priority' on ComplexModel: expected non-null value, got Null",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for ComplexModel: missing or invalid required keys (expected: id, count, rating, isActive, createdAt, website, score, timeout, metadata, tags, numbers, scores, status, priority)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> complexModelToMap(
  ComplexModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'id': instance.id,
  'count': instance.count,
  'rating': instance.rating,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'website': instance.website.toString(),
  'score': instance.score.toString(),
  'timeout': instance.timeout.inMicroseconds,
  if (!excludeNull || instance.optionalTag != null)
    'optionalTag': instance.optionalTag == null ? null : instance.optionalTag,
  'metadata': instance.metadata.map,
  'tags': instance.tags,
  'numbers': instance.numbers.toList(),
  'scores': instance.scores,
  'status': statusToValue(instance.status),
  'priority': priorityToValue(instance.priority),
  'role': instance.role,
  if (!excludeNull || instance.customEpoch != null)
    'customEpoch': instance.customEpoch == null
        ? null
        : const EpochDateTimeConverter().toJson(instance.customEpoch!),
};
Map<String, dynamic> complexModelToDebugMap(
  ComplexModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'id': instance.id,
  'count': instance.count,
  'rating': instance.rating,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'website': instance.website.toString(),
  'score': instance.score.toString(),
  'timeout': instance.timeout.inMicroseconds,
  if (!excludeNull || instance.optionalTag != null)
    'optionalTag': instance.optionalTag == null ? null : instance.optionalTag,
  'metadata': instance.metadata.map,
  'tags': instance.tags,
  'numbers': instance.numbers.toList(),
  'scores': instance.scores,
  'status': statusToValue(instance.status),
  'priority': priorityToValue(instance.priority),
  'role': instance.role,
  if (!excludeNull || instance.customEpoch != null)
    'customEpoch': instance.customEpoch == null
        ? null
        : const EpochDateTimeConverter().toJson(instance.customEpoch!),
};
Map<String, dynamic> complexModelDiff(
  ComplexModel current,
  ComplexModel other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.id != other.id) {
    delta['id'] = other.id;
  }
  if (current.count != other.count) {
    delta['count'] = other.count;
  }
  if (current.rating != other.rating) {
    delta['rating'] = other.rating;
  }
  if (current.isActive != other.isActive) {
    delta['isActive'] = other.isActive;
  }
  if (current.createdAt != other.createdAt) {
    delta['createdAt'] = other.createdAt.toIso8601String();
  }
  if (current.website != other.website) {
    delta['website'] = other.website.toString();
  }
  if (current.score != other.score) {
    delta['score'] = other.score.toString();
  }
  if (current.timeout != other.timeout) {
    delta['timeout'] = other.timeout.inMicroseconds;
  }
  if (current.optionalTag != other.optionalTag) {
    delta['optionalTag'] = other.optionalTag;
  }
  if (!$mapEquals(current.metadata.map, other.metadata.map)) {
    delta['metadata'] = other.metadata.map;
  }
  if (!$listEquals(current.tags, other.tags)) {
    delta['tags'] = other.tags;
  }
  if (!$setEquals(current.numbers, other.numbers)) {
    delta['numbers'] = other.numbers.toList();
  }
  if (!$mapEquals(current.scores, other.scores)) {
    delta['scores'] = other.scores;
  }
  if (current.status != other.status) {
    delta['status'] = statusToValue(other.status);
  }
  if (current.priority != other.priority) {
    delta['priority'] = priorityToValue(other.priority);
  }
  if (current.role != other.role) {
    delta['role'] = other.role;
  }
  if (current.customEpoch != other.customEpoch) {
    delta['customEpoch'] = other.customEpoch == null
        ? null
        : const EpochDateTimeConverter().toJson(other.customEpoch!);
  }
  return delta;
}

extension ComplexModelToMapExtension on ComplexModel {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      complexModelToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      complexModelToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(ComplexModel other, {bool deep = true}) =>
      complexModelDiff(this, other, deep: deep);
}

mixin _$ComplexModelEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ComplexModel || runtimeType != other.runtimeType)
      return false;
    final self = this as ComplexModel;
    return self.id == other.id &&
        self.count == other.count &&
        self.rating == other.rating &&
        self.isActive == other.isActive &&
        self.optionalTag == other.optionalTag &&
        self.status == other.status &&
        self.priority == other.priority &&
        self.role == other.role &&
        self.createdAt == other.createdAt &&
        self.website == other.website &&
        self.score == other.score &&
        self.timeout == other.timeout &&
        self.customEpoch == other.customEpoch &&
        $mapEquals(self.metadata.map, other.metadata.map) &&
        $listEquals(self.tags, other.tags) &&
        $setEquals(self.numbers, other.numbers) &&
        $mapEquals(self.scores, other.scores);
  }

  @override
  int get hashCode {
    final self = this as ComplexModel;
    return Object.hash(
      self.id,
      self.count,
      self.rating,
      self.isActive,
      self.createdAt,
      self.website,
      self.score,
      self.timeout,
      self.optionalTag,
      $mapHashCode(self.metadata.map),
      $listHashCode(self.tags),
      $setHashCode(self.numbers),
      $mapHashCode(self.scores),
      self.status,
      self.priority,
      self.role,
      self.customEpoch,
    );
  }
}

mixin _$ComplexModelStringify {
  @override
  String toString() {
    final self = this as ComplexModel;
    return 'ComplexModel(id: ${self.id}, count: ${self.count}, rating: ${self.rating}, isActive: ${self.isActive}, createdAt: ${self.createdAt}, website: ${self.website}, score: ${self.score}, timeout: ${self.timeout}, optionalTag: ${self.optionalTag}, metadata: ${self.metadata}, tags: ${self.tags}, numbers: ${self.numbers}, scores: ${self.scores}, status: ${self.status}, priority: ${self.priority}, role: ${self.role}, customEpoch: ${self.customEpoch})';
  }
}

mixin _$ComplexModel
    implements _$ComplexModelEqualsAndHashCode, _$ComplexModelStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ComplexModel || runtimeType != other.runtimeType)
      return false;
    final self = this as ComplexModel;
    return self.id == other.id &&
        self.count == other.count &&
        self.rating == other.rating &&
        self.isActive == other.isActive &&
        self.optionalTag == other.optionalTag &&
        self.status == other.status &&
        self.priority == other.priority &&
        self.role == other.role &&
        self.createdAt == other.createdAt &&
        self.website == other.website &&
        self.score == other.score &&
        self.timeout == other.timeout &&
        self.customEpoch == other.customEpoch &&
        $mapEquals(self.metadata.map, other.metadata.map) &&
        $listEquals(self.tags, other.tags) &&
        $setEquals(self.numbers, other.numbers) &&
        $mapEquals(self.scores, other.scores);
  }

  @override
  int get hashCode {
    final self = this as ComplexModel;
    return Object.hash(
      self.id,
      self.count,
      self.rating,
      self.isActive,
      self.createdAt,
      self.website,
      self.score,
      self.timeout,
      self.optionalTag,
      $mapHashCode(self.metadata.map),
      $listHashCode(self.tags),
      $setHashCode(self.numbers),
      $mapHashCode(self.scores),
      self.status,
      self.priority,
      self.role,
      self.customEpoch,
    );
  }

  @override
  String toString() {
    final self = this as ComplexModel;
    return 'ComplexModel(id: ${self.id}, count: ${self.count}, rating: ${self.rating}, isActive: ${self.isActive}, createdAt: ${self.createdAt}, website: ${self.website}, score: ${self.score}, timeout: ${self.timeout}, optionalTag: ${self.optionalTag}, metadata: ${self.metadata}, tags: ${self.tags}, numbers: ${self.numbers}, scores: ${self.scores}, status: ${self.status}, priority: ${self.priority}, role: ${self.role}, customEpoch: ${self.customEpoch})';
  }
}

class $ComplexModelCopyWithProxy<$Res> {
  $ComplexModelCopyWithProxy(this._value, this._then);

  final ComplexModel _value;

  final $Res Function(ComplexModel) _then;

  $Res call({
    String? id,
    int? count,
    double? rating,
    bool? isActive,
    DateTime? createdAt,
    Uri? website,
    BigInt? score,
    Duration? timeout,
    String? optionalTag,
    QueryMap? metadata,
    List<String>? tags,
    Set<int>? numbers,
    Map<String, int>? scores,
    Status? status,
    Priority? priority,
    String? role,
    DateTime? customEpoch,
  }) {
    if ((id == null || identical(id, _value.id)) &&
        (count == null || identical(count, _value.count)) &&
        (rating == null || identical(rating, _value.rating)) &&
        (isActive == null || identical(isActive, _value.isActive)) &&
        (createdAt == null || identical(createdAt, _value.createdAt)) &&
        (website == null || identical(website, _value.website)) &&
        (score == null || identical(score, _value.score)) &&
        (timeout == null || identical(timeout, _value.timeout)) &&
        (optionalTag == null || identical(optionalTag, _value.optionalTag)) &&
        (metadata == null || identical(metadata, _value.metadata)) &&
        (tags == null || identical(tags, _value.tags)) &&
        (numbers == null || identical(numbers, _value.numbers)) &&
        (scores == null || identical(scores, _value.scores)) &&
        (status == null || identical(status, _value.status)) &&
        (priority == null || identical(priority, _value.priority)) &&
        (role == null || identical(role, _value.role)) &&
        (customEpoch == null || identical(customEpoch, _value.customEpoch))) {
      return _then(_value);
    }

    return _then(
      ComplexModel(
        id ?? _value.id,
        count ?? _value.count,
        rating ?? _value.rating,
        isActive ?? _value.isActive,
        createdAt ?? _value.createdAt,
        website ?? _value.website,
        score ?? _value.score,
        timeout ?? _value.timeout,
        optionalTag ?? _value.optionalTag,
        metadata ?? _value.metadata,
        tags ?? _value.tags,
        numbers ?? _value.numbers,
        scores ?? _value.scores,
        status ?? _value.status,
        priority ?? _value.priority,
        role: role ?? _value.role,
        secretToken: _value.secretToken,
        customEpoch: customEpoch ?? _value.customEpoch,
      ),
    );
  }
}

extension ComplexModelCopyWithExtension on ComplexModel {
  $ComplexModelCopyWithProxy<ComplexModel> get copyWith =>
      $ComplexModelCopyWithProxy(this, (v) => v);

  ComplexModel copyWithNull({
    bool optionalTag = false,
    bool customEpoch = false,
  }) {
    if (!optionalTag && !customEpoch) {
      return this;
    }

    return ComplexModel(
      this.id,
      this.count,
      this.rating,
      this.isActive,
      this.createdAt,
      this.website,
      this.score,
      this.timeout,
      optionalTag ? null : this.optionalTag,
      this.metadata,
      this.tags,
      this.numbers,
      this.scores,
      this.status,
      this.priority,
      role: this.role,
      secretToken: this.secretToken,
      customEpoch: customEpoch ? null : this.customEpoch,
    );
  }
}

NestedContainer nestedContainerFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'containerId': final String containerIdRaw, 'model': final Map modelRaw} =>
      NestedContainer(
        containerId: containerIdRaw,
        model: complexModelFromMap(modelRaw.cast<String, dynamic>()),
        optionalModel: (json['optionalModel'] == null
            ? null
            : complexModelFromMap(
                json['optionalModel'] as Map<String, dynamic>,
              )),
      ),
    _ => () {
      if (!json.containsKey('containerId')) {
        throw FormatException(
          "Missing required field 'containerId' for NestedContainer",
          json,
        );
      }
      if (json['containerId'] is! String) {
        throw FormatException(
          "Invalid type for field 'containerId' on NestedContainer: expected String, got ${json['containerId'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('model')) {
        throw FormatException(
          "Missing required field 'model' for NestedContainer",
          json,
        );
      }
      if (json['model'] is! Map) {
        throw FormatException(
          "Invalid type for field 'model' on NestedContainer: expected Map, got ${json['model'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for NestedContainer: missing or invalid required keys (expected: containerId, model)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> nestedContainerToMap(
  NestedContainer instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'containerId': instance.containerId,
  'model': complexModelToMap(instance.model),
  if (!excludeNull || instance.optionalModel != null)
    'optionalModel': instance.optionalModel == null
        ? null
        : complexModelToMap(instance.optionalModel!),
};
Map<String, dynamic> nestedContainerToDebugMap(
  NestedContainer instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'containerId': instance.containerId,
  'model': complexModelToDebugMap(instance.model, excludeNull: excludeNull),
  if (!excludeNull || instance.optionalModel != null)
    'optionalModel': instance.optionalModel == null
        ? null
        : complexModelToDebugMap(
            instance.optionalModel!,
            excludeNull: excludeNull,
          ),
};
Map<String, dynamic> nestedContainerDiff(
  NestedContainer current,
  NestedContainer other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.containerId != other.containerId) {
    delta['containerId'] = other.containerId;
  }
  if (deep) {
    final childDiff = complexModelDiff(current.model, other.model, deep: true);
    if (childDiff.isNotEmpty) {
      delta['model'] = childDiff;
    }
  } else {
    final childDiff = complexModelDiff(current.model, other.model, deep: false);
    if (childDiff.isNotEmpty) {
      delta['model'] = complexModelToMap(other.model);
    }
  }
  if (current.optionalModel == null && other.optionalModel != null) {
    delta['optionalModel'] = (other.optionalModel == null
        ? null
        : complexModelToMap(other.optionalModel!));
  } else if (current.optionalModel != null && other.optionalModel == null) {
    delta['optionalModel'] = null;
  } else if (current.optionalModel != null && other.optionalModel != null) {
    if (deep) {
      final childDiff = complexModelDiff(
        current.optionalModel!,
        other.optionalModel!,
        deep: true,
      );
      if (childDiff.isNotEmpty) {
        delta['optionalModel'] = childDiff;
      }
    } else {
      final childDiff = complexModelDiff(
        current.optionalModel!,
        other.optionalModel!,
        deep: false,
      );
      if (childDiff.isNotEmpty) {
        delta['optionalModel'] = (other.optionalModel == null
            ? null
            : complexModelToMap(other.optionalModel!));
      }
    }
  }
  return delta;
}

extension NestedContainerToMapExtension on NestedContainer {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      nestedContainerToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      nestedContainerToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(NestedContainer other, {bool deep = true}) =>
      nestedContainerDiff(this, other, deep: deep);
}

mixin _$NestedContainerEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NestedContainer || runtimeType != other.runtimeType)
      return false;
    final self = this as NestedContainer;
    return self.containerId == other.containerId &&
        self.model == other.model &&
        self.optionalModel == other.optionalModel;
  }

  @override
  int get hashCode {
    final self = this as NestedContainer;
    return Object.hash(self.containerId, self.model, self.optionalModel);
  }
}

mixin _$NestedContainerStringify {
  @override
  String toString() {
    final self = this as NestedContainer;
    return 'NestedContainer(containerId: ${self.containerId}, model: ${self.model}, optionalModel: ${self.optionalModel})';
  }
}

mixin _$NestedContainer
    implements _$NestedContainerEqualsAndHashCode, _$NestedContainerStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NestedContainer || runtimeType != other.runtimeType)
      return false;
    final self = this as NestedContainer;
    return self.containerId == other.containerId &&
        self.model == other.model &&
        self.optionalModel == other.optionalModel;
  }

  @override
  int get hashCode {
    final self = this as NestedContainer;
    return Object.hash(self.containerId, self.model, self.optionalModel);
  }

  @override
  String toString() {
    final self = this as NestedContainer;
    return 'NestedContainer(containerId: ${self.containerId}, model: ${self.model}, optionalModel: ${self.optionalModel})';
  }
}

class $NestedContainerCopyWithProxy<$Res> {
  $NestedContainerCopyWithProxy(this._value, this._then);

  final NestedContainer _value;

  final $Res Function(NestedContainer) _then;

  $Res call({
    String? containerId,
    ComplexModel? model,
    ComplexModel? optionalModel,
  }) {
    if ((containerId == null || identical(containerId, _value.containerId)) &&
        (model == null || identical(model, _value.model)) &&
        (optionalModel == null ||
            identical(optionalModel, _value.optionalModel))) {
      return _then(_value);
    }

    return _then(
      NestedContainer(
        containerId: containerId ?? _value.containerId,
        model: model ?? _value.model,
        optionalModel: optionalModel ?? _value.optionalModel,
      ),
    );
  }

  $ComplexModelCopyWithProxy<$Res> get model =>
      $ComplexModelCopyWithProxy(_value.model, (val) => call(model: val));

  $ComplexModelCopyWithProxy<$Res>? get optionalModel {
    if (_value.optionalModel == null) return null;
    return $ComplexModelCopyWithProxy(
      _value.optionalModel!,
      (val) => call(optionalModel: val),
    );
  }
}

extension NestedContainerCopyWithExtension on NestedContainer {
  $NestedContainerCopyWithProxy<NestedContainer> get copyWith =>
      $NestedContainerCopyWithProxy(this, (v) => v);

  NestedContainer copyWithNull({bool optionalModel = false}) {
    if (!optionalModel) {
      return this;
    }

    return NestedContainer(
      containerId: this.containerId,
      model: this.model,
      optionalModel: optionalModel ? null : this.optionalModel,
    );
  }
}

Circle circleFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'radius': final num radiusRaw} => Circle(radiusRaw.toDouble()),
    _ => () {
      if (!json.containsKey('radius')) {
        throw FormatException(
          "Missing required field 'radius' for Circle",
          json,
        );
      }
      if (json['radius'] is! num) {
        throw FormatException(
          "Invalid type for field 'radius' on Circle: expected num, got ${json['radius'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for Circle: missing or invalid required keys (expected: radius)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> circleToMap(Circle instance, {bool excludeNull = false}) =>
    <String, dynamic>{'radius': instance.radius};
Map<String, dynamic> circleToDebugMap(
  Circle instance, {
  bool excludeNull = false,
}) => <String, dynamic>{'radius': instance.radius};
Map<String, dynamic> circleDiff(
  Circle current,
  Circle other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.radius != other.radius) {
    delta['radius'] = other.radius;
  }
  return delta;
}

extension CircleToMapExtension on Circle {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      circleToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      circleToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Circle other, {bool deep = true}) =>
      circleDiff(this, other, deep: deep);
}

Square squareFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'side': final num sideRaw} => Square(sideRaw.toDouble()),
    _ => () {
      if (!json.containsKey('side')) {
        throw FormatException("Missing required field 'side' for Square", json);
      }
      if (json['side'] is! num) {
        throw FormatException(
          "Invalid type for field 'side' on Square: expected num, got ${json['side'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for Square: missing or invalid required keys (expected: side)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> squareToMap(Square instance, {bool excludeNull = false}) =>
    <String, dynamic>{'side': instance.side};
Map<String, dynamic> squareToDebugMap(
  Square instance, {
  bool excludeNull = false,
}) => <String, dynamic>{'side': instance.side};
Map<String, dynamic> squareDiff(
  Square current,
  Square other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.side != other.side) {
    delta['side'] = other.side;
  }
  return delta;
}

extension SquareToMapExtension on Square {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      squareToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      squareToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Square other, {bool deep = true}) =>
      squareDiff(this, other, deep: deep);
}

Car carFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'seats': final num seatsRaw} => Car(seatsRaw.toInt()),
    _ => () {
      if (!json.containsKey('seats')) {
        throw FormatException("Missing required field 'seats' for Car", json);
      }
      if (json['seats'] is! num) {
        throw FormatException(
          "Invalid type for field 'seats' on Car: expected num, got ${json['seats'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for Car: missing or invalid required keys (expected: seats)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> carToMap(Car instance, {bool excludeNull = false}) =>
    <String, dynamic>{'seats': instance.seats};
Map<String, dynamic> carToDebugMap(Car instance, {bool excludeNull = false}) =>
    <String, dynamic>{'seats': instance.seats};
Map<String, dynamic> carDiff(Car current, Car other, {bool deep = true}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.seats != other.seats) {
    delta['seats'] = other.seats;
  }
  return delta;
}

extension CarToMapExtension on Car {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      carToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      carToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Car other, {bool deep = true}) =>
      carDiff(this, other, deep: deep);
}

Bike bikeFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'hasPedals': final bool hasPedalsRaw} => Bike(hasPedalsRaw),
    _ => () {
      if (!json.containsKey('hasPedals')) {
        throw FormatException(
          "Missing required field 'hasPedals' for Bike",
          json,
        );
      }
      if (json['hasPedals'] is! bool) {
        throw FormatException(
          "Invalid type for field 'hasPedals' on Bike: expected bool, got ${json['hasPedals'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for Bike: missing or invalid required keys (expected: hasPedals)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> bikeToMap(Bike instance, {bool excludeNull = false}) =>
    <String, dynamic>{'hasPedals': instance.hasPedals};
Map<String, dynamic> bikeToDebugMap(
  Bike instance, {
  bool excludeNull = false,
}) => <String, dynamic>{'hasPedals': instance.hasPedals};
Map<String, dynamic> bikeDiff(Bike current, Bike other, {bool deep = true}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.hasPedals != other.hasPedals) {
    delta['hasPedals'] = other.hasPedals;
  }
  return delta;
}

extension BikeToMapExtension on Bike {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      bikeToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      bikeToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Bike other, {bool deep = true}) =>
      bikeDiff(this, other, deep: deep);
}

CustomKeyModel customKeyModelFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'wire_key': final String keyRaw} => CustomKeyModel(keyRaw),
    _ => () {
      if (!json.containsKey('wire_key')) {
        throw FormatException(
          "Missing required field 'wire_key' for CustomKeyModel",
          json,
        );
      }
      if (json['wire_key'] is! String) {
        throw FormatException(
          "Invalid type for field 'wire_key' on CustomKeyModel: expected String, got ${json['wire_key'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for CustomKeyModel: missing or invalid required keys (expected: wire_key)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> customKeyModelToMap(
  CustomKeyModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{'wire_key': instance.key};
Map<String, dynamic> customKeyModelToDebugMap(
  CustomKeyModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{'wire_key': instance.key};
Map<String, dynamic> customKeyModelDiff(
  CustomKeyModel current,
  CustomKeyModel other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.key != other.key) {
    delta['wire_key'] = other.key;
  }
  return delta;
}

extension CustomKeyModelToMapExtension on CustomKeyModel {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      customKeyModelToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      customKeyModelToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(CustomKeyModel other, {bool deep = true}) =>
      customKeyModelDiff(this, other, deep: deep);
}

NullableConverterModel nullableConverterModelFromMap(
  Map<String, dynamic> json,
) => NullableConverterModel(
  json['nullableConvertedInt'] == null
      ? null
      : const StringIntConverter().fromJson(json['nullableConvertedInt']),
);
Map<String, dynamic> nullableConverterModelToMap(
  NullableConverterModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  if (!excludeNull || instance.nullableConvertedInt != null)
    'nullableConvertedInt': instance.nullableConvertedInt == null
        ? null
        : const StringIntConverter().toJson(instance.nullableConvertedInt!),
};
Map<String, dynamic> nullableConverterModelToDebugMap(
  NullableConverterModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  if (!excludeNull || instance.nullableConvertedInt != null)
    'nullableConvertedInt': instance.nullableConvertedInt == null
        ? null
        : const StringIntConverter().toJson(instance.nullableConvertedInt!),
};
Map<String, dynamic> nullableConverterModelDiff(
  NullableConverterModel current,
  NullableConverterModel other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.nullableConvertedInt != other.nullableConvertedInt) {
    delta['nullableConvertedInt'] = other.nullableConvertedInt == null
        ? null
        : const StringIntConverter().toJson(other.nullableConvertedInt!);
  }
  return delta;
}

extension NullableConverterModelToMapExtension on NullableConverterModel {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      nullableConverterModelToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      nullableConverterModelToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(NullableConverterModel other, {bool deep = true}) =>
      nullableConverterModelDiff(this, other, deep: deep);
}

DeepCollectionsModel deepCollectionsModelFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'matrix': final List matrixRaw, 'mappedLists': final Map mappedListsRaw} =>
      DeepCollectionsModel(
        matrixRaw
            .cast<dynamic>()
            .map(
              (e) => (e as List<dynamic>)
                  .map((e1) => ((e1 as num).toInt()))
                  .toList(),
            )
            .toList(),
        mappedListsRaw.cast<String, dynamic>().map(
          (k, v) => MapEntry(
            k,
            (v as List<dynamic>).map((e1) => (e1 as String)).toList(),
          ),
        ),
      ),
    _ => () {
      if (!json.containsKey('matrix')) {
        throw FormatException(
          "Missing required field 'matrix' for DeepCollectionsModel",
          json,
        );
      }
      if (json['matrix'] is! List) {
        throw FormatException(
          "Invalid type for field 'matrix' on DeepCollectionsModel: expected List, got ${json['matrix'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('mappedLists')) {
        throw FormatException(
          "Missing required field 'mappedLists' for DeepCollectionsModel",
          json,
        );
      }
      if (json['mappedLists'] is! Map) {
        throw FormatException(
          "Invalid type for field 'mappedLists' on DeepCollectionsModel: expected Map, got ${json['mappedLists'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for DeepCollectionsModel: missing or invalid required keys (expected: matrix, mappedLists)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> deepCollectionsModelToMap(
  DeepCollectionsModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'matrix': instance.matrix.map((e) => e).toList(),
  'mappedLists': instance.mappedLists.map((k, v) => MapEntry(k, v)),
};
Map<String, dynamic> deepCollectionsModelToDebugMap(
  DeepCollectionsModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'matrix': instance.matrix.map((e) => e).toList(),
  'mappedLists': instance.mappedLists.map((k, v) => MapEntry(k, v)),
};
Map<String, dynamic> deepCollectionsModelDiff(
  DeepCollectionsModel current,
  DeepCollectionsModel other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (!$listEquals(current.matrix, other.matrix)) {
    delta['matrix'] = other.matrix.map((e) => e).toList();
  }
  if (!$mapEquals(current.mappedLists, other.mappedLists)) {
    delta['mappedLists'] = other.mappedLists.map((k, v) => MapEntry(k, v));
  }
  return delta;
}

extension DeepCollectionsModelToMapExtension on DeepCollectionsModel {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      deepCollectionsModelToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      deepCollectionsModelToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(DeepCollectionsModel other, {bool deep = true}) =>
      deepCollectionsModelDiff(this, other, deep: deep);
}

CaseStyledModel caseStyledModelFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {
      'user_full_name': final String userFullNameRaw,
      'login_attempt_count': final num loginAttemptCountRaw,
    } =>
      CaseStyledModel(userFullNameRaw, loginAttemptCountRaw.toInt()),
    _ => () {
      if (!json.containsKey('user_full_name')) {
        throw FormatException(
          "Missing required field 'user_full_name' for CaseStyledModel",
          json,
        );
      }
      if (json['user_full_name'] is! String) {
        throw FormatException(
          "Invalid type for field 'user_full_name' on CaseStyledModel: expected String, got ${json['user_full_name'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('login_attempt_count')) {
        throw FormatException(
          "Missing required field 'login_attempt_count' for CaseStyledModel",
          json,
        );
      }
      if (json['login_attempt_count'] is! num) {
        throw FormatException(
          "Invalid type for field 'login_attempt_count' on CaseStyledModel: expected num, got ${json['login_attempt_count'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for CaseStyledModel: missing or invalid required keys (expected: user_full_name, login_attempt_count)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> caseStyledModelToMap(
  CaseStyledModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'user_full_name': instance.userFullName,
  'login_attempt_count': instance.loginAttemptCount,
};
Map<String, dynamic> caseStyledModelToDebugMap(
  CaseStyledModel instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'user_full_name': instance.userFullName,
  'login_attempt_count': instance.loginAttemptCount,
};
Map<String, dynamic> caseStyledModelDiff(
  CaseStyledModel current,
  CaseStyledModel other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.userFullName != other.userFullName) {
    delta['user_full_name'] = other.userFullName;
  }
  if (current.loginAttemptCount != other.loginAttemptCount) {
    delta['login_attempt_count'] = other.loginAttemptCount;
  }
  return delta;
}

extension CaseStyledModelToMapExtension on CaseStyledModel {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      caseStyledModelToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      caseStyledModelToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(CaseStyledModel other, {bool deep = true}) =>
      caseStyledModelDiff(this, other, deep: deep);
}

mixin _$CaseStyledModelEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CaseStyledModel || runtimeType != other.runtimeType)
      return false;
    final self = this as CaseStyledModel;
    return self.userFullName == other.userFullName &&
        self.loginAttemptCount == other.loginAttemptCount;
  }

  @override
  int get hashCode {
    final self = this as CaseStyledModel;
    return Object.hash(self.userFullName, self.loginAttemptCount);
  }
}

mixin _$CaseStyledModelStringify {
  @override
  String toString() {
    final self = this as CaseStyledModel;
    return 'CaseStyledModel(userFullName: ${self.userFullName}, loginAttemptCount: ${self.loginAttemptCount})';
  }
}

mixin _$CaseStyledModel
    implements _$CaseStyledModelEqualsAndHashCode, _$CaseStyledModelStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CaseStyledModel || runtimeType != other.runtimeType)
      return false;
    final self = this as CaseStyledModel;
    return self.userFullName == other.userFullName &&
        self.loginAttemptCount == other.loginAttemptCount;
  }

  @override
  int get hashCode {
    final self = this as CaseStyledModel;
    return Object.hash(self.userFullName, self.loginAttemptCount);
  }

  @override
  String toString() {
    final self = this as CaseStyledModel;
    return 'CaseStyledModel(userFullName: ${self.userFullName}, loginAttemptCount: ${self.loginAttemptCount})';
  }
}

class $CaseStyledModelCopyWithProxy<$Res> {
  $CaseStyledModelCopyWithProxy(this._value, this._then);

  final CaseStyledModel _value;

  final $Res Function(CaseStyledModel) _then;

  $Res call({String? userFullName, int? loginAttemptCount}) {
    if ((userFullName == null ||
            identical(userFullName, _value.userFullName)) &&
        (loginAttemptCount == null ||
            identical(loginAttemptCount, _value.loginAttemptCount))) {
      return _then(_value);
    }

    return _then(
      CaseStyledModel(
        userFullName ?? _value.userFullName,
        loginAttemptCount ?? _value.loginAttemptCount,
        internalSecret: _value.internalSecret,
      ),
    );
  }
}

extension CaseStyledModelCopyWithExtension on CaseStyledModel {
  $CaseStyledModelCopyWithProxy<CaseStyledModel> get copyWith =>
      $CaseStyledModelCopyWithProxy(this, (v) => v);
}

LoginEvent loginEventFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'userId': final String userIdRaw} => LoginEvent(userIdRaw),
    _ => () {
      if (!json.containsKey('userId')) {
        throw FormatException(
          "Missing required field 'userId' for LoginEvent",
          json,
        );
      }
      if (json['userId'] is! String) {
        throw FormatException(
          "Invalid type for field 'userId' on LoginEvent: expected String, got ${json['userId'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for LoginEvent: missing or invalid required keys (expected: userId)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> loginEventToMap(
  LoginEvent instance, {
  bool excludeNull = false,
}) => <String, dynamic>{'userId': instance.userId};
Map<String, dynamic> loginEventToDebugMap(
  LoginEvent instance, {
  bool excludeNull = false,
}) => <String, dynamic>{'userId': instance.userId};
Map<String, dynamic> loginEventDiff(
  LoginEvent current,
  LoginEvent other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.userId != other.userId) {
    delta['userId'] = other.userId;
  }
  return delta;
}

extension LoginEventToMapExtension on LoginEvent {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      loginEventToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      loginEventToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(LoginEvent other, {bool deep = true}) =>
      loginEventDiff(this, other, deep: deep);
}

LogoutEvent logoutEventFromMap(Map<String, dynamic> json) => LogoutEvent();
Map<String, dynamic> logoutEventToMap(
  LogoutEvent instance, {
  bool excludeNull = false,
}) => <String, dynamic>{};
Map<String, dynamic> logoutEventToDebugMap(
  LogoutEvent instance, {
  bool excludeNull = false,
}) => <String, dynamic>{};
Map<String, dynamic> logoutEventDiff(
  LogoutEvent current,
  LogoutEvent other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  return delta;
}

extension LogoutEventToMapExtension on LogoutEvent {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      logoutEventToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      logoutEventToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(LogoutEvent other, {bool deep = true}) =>
      logoutEventDiff(this, other, deep: deep);
}

mixin _$EqualsOnlyModelEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EqualsOnlyModel || runtimeType != other.runtimeType)
      return false;
    final self = this as EqualsOnlyModel;
    return self.id == other.id && self.value == other.value;
  }

  @override
  int get hashCode {
    final self = this as EqualsOnlyModel;
    return Object.hash(self.id, self.value);
  }
}

mixin _$StringifyOnlyModelStringify {
  @override
  String toString() {
    final self = this as StringifyOnlyModel;
    return 'StringifyOnlyModel(title: ${self.title})';
  }
}

mixin _$LargeModelEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LargeModel || runtimeType != other.runtimeType) return false;
    final self = this as LargeModel;
    return self.f1 == other.f1 &&
        self.f2 == other.f2 &&
        self.f3 == other.f3 &&
        self.f4 == other.f4 &&
        self.f5 == other.f5 &&
        self.f6 == other.f6 &&
        self.f7 == other.f7 &&
        self.f8 == other.f8 &&
        self.f9 == other.f9 &&
        self.f10 == other.f10 &&
        self.f11 == other.f11 &&
        self.f12 == other.f12 &&
        self.f13 == other.f13 &&
        self.f14 == other.f14 &&
        self.f15 == other.f15 &&
        self.f16 == other.f16 &&
        self.f17 == other.f17 &&
        self.f18 == other.f18 &&
        self.f19 == other.f19 &&
        self.f20 == other.f20 &&
        self.f21 == other.f21 &&
        self.f22 == other.f22;
  }

  @override
  int get hashCode {
    final self = this as LargeModel;
    return Object.hash(
      self.f1,
      self.f2,
      self.f3,
      self.f4,
      self.f5,
      self.f6,
      self.f7,
      self.f8,
      self.f9,
      self.f10,
      self.f11,
      self.f12,
      self.f13,
      self.f14,
      self.f15,
      self.f16,
      self.f17,
      self.f18,
      self.f19,
      Object.hash(self.f20, self.f21, self.f22),
    );
  }
}

mixin _$LargeModelStringify {
  @override
  String toString() {
    final self = this as LargeModel;
    return 'LargeModel(f1: ${self.f1}, f2: ${self.f2}, f3: ${self.f3}, f4: ${self.f4}, f5: ${self.f5}, f6: ${self.f6}, f7: ${self.f7}, f8: ${self.f8}, f9: ${self.f9}, f10: ${self.f10}, f11: ${self.f11}, f12: ${self.f12}, f13: ${self.f13}, f14: ${self.f14}, f15: ${self.f15}, f16: ${self.f16}, f17: ${self.f17}, f18: ${self.f18}, f19: ${self.f19}, f20: ${self.f20}, f21: ${self.f21}, f22: ${self.f22})';
  }
}

mixin _$LargeModel
    implements _$LargeModelEqualsAndHashCode, _$LargeModelStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LargeModel || runtimeType != other.runtimeType) return false;
    final self = this as LargeModel;
    return self.f1 == other.f1 &&
        self.f2 == other.f2 &&
        self.f3 == other.f3 &&
        self.f4 == other.f4 &&
        self.f5 == other.f5 &&
        self.f6 == other.f6 &&
        self.f7 == other.f7 &&
        self.f8 == other.f8 &&
        self.f9 == other.f9 &&
        self.f10 == other.f10 &&
        self.f11 == other.f11 &&
        self.f12 == other.f12 &&
        self.f13 == other.f13 &&
        self.f14 == other.f14 &&
        self.f15 == other.f15 &&
        self.f16 == other.f16 &&
        self.f17 == other.f17 &&
        self.f18 == other.f18 &&
        self.f19 == other.f19 &&
        self.f20 == other.f20 &&
        self.f21 == other.f21 &&
        self.f22 == other.f22;
  }

  @override
  int get hashCode {
    final self = this as LargeModel;
    return Object.hash(
      self.f1,
      self.f2,
      self.f3,
      self.f4,
      self.f5,
      self.f6,
      self.f7,
      self.f8,
      self.f9,
      self.f10,
      self.f11,
      self.f12,
      self.f13,
      self.f14,
      self.f15,
      self.f16,
      self.f17,
      self.f18,
      self.f19,
      Object.hash(self.f20, self.f21, self.f22),
    );
  }

  @override
  String toString() {
    final self = this as LargeModel;
    return 'LargeModel(f1: ${self.f1}, f2: ${self.f2}, f3: ${self.f3}, f4: ${self.f4}, f5: ${self.f5}, f6: ${self.f6}, f7: ${self.f7}, f8: ${self.f8}, f9: ${self.f9}, f10: ${self.f10}, f11: ${self.f11}, f12: ${self.f12}, f13: ${self.f13}, f14: ${self.f14}, f15: ${self.f15}, f16: ${self.f16}, f17: ${self.f17}, f18: ${self.f18}, f19: ${self.f19}, f20: ${self.f20}, f21: ${self.f21}, f22: ${self.f22})';
  }
}

class $LargeModelCopyWithProxy<$Res> {
  $LargeModelCopyWithProxy(this._value, this._then);

  final LargeModel _value;

  final $Res Function(LargeModel) _then;

  $Res call({
    int? f1,
    int? f2,
    int? f3,
    int? f4,
    int? f5,
    int? f6,
    int? f7,
    int? f8,
    int? f9,
    int? f10,
    int? f11,
    int? f12,
    int? f13,
    int? f14,
    int? f15,
    int? f16,
    int? f17,
    int? f18,
    int? f19,
    int? f20,
    int? f21,
    int? f22,
  }) {
    if ((f1 == null || identical(f1, _value.f1)) &&
        (f2 == null || identical(f2, _value.f2)) &&
        (f3 == null || identical(f3, _value.f3)) &&
        (f4 == null || identical(f4, _value.f4)) &&
        (f5 == null || identical(f5, _value.f5)) &&
        (f6 == null || identical(f6, _value.f6)) &&
        (f7 == null || identical(f7, _value.f7)) &&
        (f8 == null || identical(f8, _value.f8)) &&
        (f9 == null || identical(f9, _value.f9)) &&
        (f10 == null || identical(f10, _value.f10)) &&
        (f11 == null || identical(f11, _value.f11)) &&
        (f12 == null || identical(f12, _value.f12)) &&
        (f13 == null || identical(f13, _value.f13)) &&
        (f14 == null || identical(f14, _value.f14)) &&
        (f15 == null || identical(f15, _value.f15)) &&
        (f16 == null || identical(f16, _value.f16)) &&
        (f17 == null || identical(f17, _value.f17)) &&
        (f18 == null || identical(f18, _value.f18)) &&
        (f19 == null || identical(f19, _value.f19)) &&
        (f20 == null || identical(f20, _value.f20)) &&
        (f21 == null || identical(f21, _value.f21)) &&
        (f22 == null || identical(f22, _value.f22))) {
      return _then(_value);
    }

    return _then(
      LargeModel(
        f1 ?? _value.f1,
        f2 ?? _value.f2,
        f3 ?? _value.f3,
        f4 ?? _value.f4,
        f5 ?? _value.f5,
        f6 ?? _value.f6,
        f7 ?? _value.f7,
        f8 ?? _value.f8,
        f9 ?? _value.f9,
        f10 ?? _value.f10,
        f11 ?? _value.f11,
        f12 ?? _value.f12,
        f13 ?? _value.f13,
        f14 ?? _value.f14,
        f15 ?? _value.f15,
        f16 ?? _value.f16,
        f17 ?? _value.f17,
        f18 ?? _value.f18,
        f19 ?? _value.f19,
        f20 ?? _value.f20,
        f21 ?? _value.f21,
        f22 ?? _value.f22,
      ),
    );
  }
}

extension LargeModelCopyWithExtension on LargeModel {
  $LargeModelCopyWithProxy<LargeModel> get copyWith =>
      $LargeModelCopyWithProxy(this, (v) => v);
}

Account accountFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'id': final String idRaw, 'acc_type': final Object typeRaw} => Account(
      id: idRaw,
      type: accountTypeFromValue(typeRaw),
      loginCount: json['loginCount'] == null
          ? 0
          : ((json['loginCount'] as num).toInt()),
      sessionTimer: Stopwatch(),
    ),
    _ => () {
      if (!json.containsKey('id')) {
        throw FormatException("Missing required field 'id' for Account", json);
      }
      if (json['id'] is! String) {
        throw FormatException(
          "Invalid type for field 'id' on Account: expected String, got ${json['id'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('acc_type')) {
        throw FormatException(
          "Missing required field 'acc_type' for Account",
          json,
        );
      }
      if (json['acc_type'] == null) {
        throw FormatException(
          "Invalid type for field 'acc_type' on Account: expected non-null value, got Null",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for Account: missing or invalid required keys (expected: id, acc_type)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> accountToMap(
  Account instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'id': instance.id,
  'acc_type': accountTypeToValue(instance.type),
  'loginCount': instance.loginCount,
};
Map<String, dynamic> accountToDebugMap(
  Account instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'id': instance.id,
  'acc_type': accountTypeToValue(instance.type),
  'loginCount': instance.loginCount,
};
Map<String, dynamic> accountDiff(
  Account current,
  Account other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.id != other.id) {
    delta['id'] = other.id;
  }
  if (current.type != other.type) {
    delta['acc_type'] = accountTypeToValue(other.type);
  }
  if (current.loginCount != other.loginCount) {
    delta['loginCount'] = other.loginCount;
  }
  return delta;
}

extension AccountToMapExtension on Account {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      accountToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      accountToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Account other, {bool deep = true}) =>
      accountDiff(this, other, deep: deep);
}

mixin _$AccountEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Account || runtimeType != other.runtimeType) return false;
    final self = this as Account;
    return self.id == other.id &&
        self.type == other.type &&
        self.loginCount == other.loginCount;
  }

  @override
  int get hashCode {
    final self = this as Account;
    return Object.hash(self.id, self.type, self.loginCount);
  }
}

mixin _$AccountStringify {
  @override
  String toString() {
    final self = this as Account;
    return 'Account(id: ${self.id}, type: ${self.type}, loginCount: ${self.loginCount})';
  }
}

mixin _$Account implements _$AccountEqualsAndHashCode, _$AccountStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Account || runtimeType != other.runtimeType) return false;
    final self = this as Account;
    return self.id == other.id &&
        self.type == other.type &&
        self.loginCount == other.loginCount;
  }

  @override
  int get hashCode {
    final self = this as Account;
    return Object.hash(self.id, self.type, self.loginCount);
  }

  @override
  String toString() {
    final self = this as Account;
    return 'Account(id: ${self.id}, type: ${self.type}, loginCount: ${self.loginCount})';
  }
}

class $AccountCopyWithProxy<$Res> {
  $AccountCopyWithProxy(this._value, this._then);

  final Account _value;

  final $Res Function(Account) _then;

  $Res call({String? id, AccountType? type, int? loginCount}) {
    if ((id == null || identical(id, _value.id)) &&
        (type == null || identical(type, _value.type)) &&
        (loginCount == null || identical(loginCount, _value.loginCount))) {
      return _then(_value);
    }

    return _then(
      Account(
        id: id ?? _value.id,
        type: type ?? _value.type,
        loginCount: loginCount ?? _value.loginCount,
        sessionTimer: _value.sessionTimer,
      ),
    );
  }
}

extension AccountCopyWithExtension on Account {
  $AccountCopyWithProxy<Account> get copyWith =>
      $AccountCopyWithProxy(this, (v) => v);
}

Address addressFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'street': final String streetRaw, 'city': final String cityRaw} => Address(
      street: streetRaw,
      apt: (json['apt'] as String?),
      city: cityRaw,
    ),
    _ => () {
      if (!json.containsKey('street')) {
        throw FormatException(
          "Missing required field 'street' for Address",
          json,
        );
      }
      if (json['street'] is! String) {
        throw FormatException(
          "Invalid type for field 'street' on Address: expected String, got ${json['street'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('city')) {
        throw FormatException(
          "Missing required field 'city' for Address",
          json,
        );
      }
      if (json['city'] is! String) {
        throw FormatException(
          "Invalid type for field 'city' on Address: expected String, got ${json['city'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for Address: missing or invalid required keys (expected: street, city)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> addressToMap(
  Address instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'street': instance.street,
  if (!excludeNull || instance.apt != null)
    'apt': instance.apt == null ? null : instance.apt,
  'city': instance.city,
};
Map<String, dynamic> addressToDebugMap(
  Address instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'street': instance.street,
  if (!excludeNull || instance.apt != null)
    'apt': instance.apt == null ? null : instance.apt,
  'city': instance.city,
};
Map<String, dynamic> addressDiff(
  Address current,
  Address other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.street != other.street) {
    delta['street'] = other.street;
  }
  if (current.apt != other.apt) {
    delta['apt'] = other.apt;
  }
  if (current.city != other.city) {
    delta['city'] = other.city;
  }
  return delta;
}

extension AddressToMapExtension on Address {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      addressToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      addressToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Address other, {bool deep = true}) =>
      addressDiff(this, other, deep: deep);
}

mixin _$AddressEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Address || runtimeType != other.runtimeType) return false;
    final self = this as Address;
    return self.street == other.street &&
        self.apt == other.apt &&
        self.city == other.city;
  }

  @override
  int get hashCode {
    final self = this as Address;
    return Object.hash(self.street, self.apt, self.city);
  }
}

mixin _$AddressStringify {
  @override
  String toString() {
    final self = this as Address;
    return 'Address(street: ${self.street}, apt: ${self.apt}, city: ${self.city})';
  }
}

mixin _$Address implements _$AddressEqualsAndHashCode, _$AddressStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Address || runtimeType != other.runtimeType) return false;
    final self = this as Address;
    return self.street == other.street &&
        self.apt == other.apt &&
        self.city == other.city;
  }

  @override
  int get hashCode {
    final self = this as Address;
    return Object.hash(self.street, self.apt, self.city);
  }

  @override
  String toString() {
    final self = this as Address;
    return 'Address(street: ${self.street}, apt: ${self.apt}, city: ${self.city})';
  }
}

class $AddressCopyWithProxy<$Res> {
  $AddressCopyWithProxy(this._value, this._then);

  final Address _value;

  final $Res Function(Address) _then;

  $Res call({String? street, String? apt, String? city}) {
    if ((street == null || identical(street, _value.street)) &&
        (apt == null || identical(apt, _value.apt)) &&
        (city == null || identical(city, _value.city))) {
      return _then(_value);
    }

    return _then(
      Address(
        street: street ?? _value.street,
        apt: apt ?? _value.apt,
        city: city ?? _value.city,
      ),
    );
  }
}

extension AddressCopyWithExtension on Address {
  $AddressCopyWithProxy<Address> get copyWith =>
      $AddressCopyWithProxy(this, (v) => v);

  Address copyWithNull({bool apt = false}) {
    if (!apt) {
      return this;
    }

    return Address(
      street: this.street,
      apt: apt ? null : this.apt,
      city: this.city,
    );
  }
}

Order orderFromMap(Map<String, dynamic> json) {
  if (!json.containsKey('id')) {
    throw FormatException("Missing required field 'id' for Order", json);
  }
  final idRaw = json['id'];
  if (!_daxleHasKey(json, 'order_status', const ['status', 'state'])) {
    throw FormatException(
      "Missing required field 'order_status' for Order",
      json,
    );
  }
  final statusRaw = _daxleResolveKey(json, 'order_status', const [
    'status',
    'state',
  ]);
  final shippingAddressJson = _daxleExtractPrefix(json, 'shipping_');
  return Order(
    id: (idRaw as String),
    status: paymentStatusFromValue(statusRaw),
    notes: (json['notes'] as String?),
    shippingAddress: addressFromMap(shippingAddressJson),
  );
}

Map<String, dynamic> orderToMap(Order instance, {bool excludeNull = false}) =>
    <String, dynamic>{
      'id': instance.id,
      'order_status': paymentStatusToValue(instance.status),
      if (!excludeNull || instance.notes != null)
        'notes': instance.notes == null ? null : instance.notes,
      for (final entry in addressToMap(
        instance.shippingAddress,
        excludeNull: excludeNull,
      ).entries)
        'shipping_${entry.key}': entry.value,
    };
Map<String, dynamic> orderToDebugMap(
  Order instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'id': instance.id,
  'order_status': paymentStatusToValue(instance.status),
  if (!excludeNull || instance.notes != null)
    'notes': instance.notes == null ? null : instance.notes,
  for (final entry in addressToDebugMap(
    instance.shippingAddress,
    excludeNull: excludeNull,
  ).entries)
    'shipping_${entry.key}': entry.value,
};
Map<String, dynamic> orderDiff(Order current, Order other, {bool deep = true}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.id != other.id) {
    delta['id'] = other.id;
  }
  if (current.status != other.status) {
    delta['order_status'] = paymentStatusToValue(other.status);
  }
  if (current.notes != other.notes) {
    delta['notes'] = other.notes;
  }
  final childDiff = addressDiff(
    current.shippingAddress,
    other.shippingAddress,
    deep: deep,
  );
  for (final entry in childDiff.entries) {
    delta['shipping_${entry.key}'] = entry.value;
  }
  return delta;
}

extension OrderToMapExtension on Order {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      orderToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      orderToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Order other, {bool deep = true}) =>
      orderDiff(this, other, deep: deep);
}

mixin _$OrderEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Order || runtimeType != other.runtimeType) return false;
    final self = this as Order;
    return self.id == other.id &&
        self.status == other.status &&
        self.notes == other.notes &&
        self.shippingAddress == other.shippingAddress;
  }

  @override
  int get hashCode {
    final self = this as Order;
    return Object.hash(self.id, self.status, self.notes, self.shippingAddress);
  }
}

mixin _$OrderStringify {
  @override
  String toString() {
    final self = this as Order;
    return 'Order(id: ${self.id}, status: ${self.status}, notes: ${self.notes}, shippingAddress: ${self.shippingAddress})';
  }
}

mixin _$Order implements _$OrderEqualsAndHashCode, _$OrderStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Order || runtimeType != other.runtimeType) return false;
    final self = this as Order;
    return self.id == other.id &&
        self.status == other.status &&
        self.notes == other.notes &&
        self.shippingAddress == other.shippingAddress;
  }

  @override
  int get hashCode {
    final self = this as Order;
    return Object.hash(self.id, self.status, self.notes, self.shippingAddress);
  }

  @override
  String toString() {
    final self = this as Order;
    return 'Order(id: ${self.id}, status: ${self.status}, notes: ${self.notes}, shippingAddress: ${self.shippingAddress})';
  }
}

class $OrderCopyWithProxy<$Res> {
  $OrderCopyWithProxy(this._value, this._then);

  final Order _value;

  final $Res Function(Order) _then;

  $Res call({
    String? id,
    PaymentStatus? status,
    String? notes,
    Address? shippingAddress,
  }) {
    if ((id == null || identical(id, _value.id)) &&
        (status == null || identical(status, _value.status)) &&
        (notes == null || identical(notes, _value.notes)) &&
        (shippingAddress == null ||
            identical(shippingAddress, _value.shippingAddress))) {
      return _then(_value);
    }

    return _then(
      Order(
        id: id ?? _value.id,
        status: status ?? _value.status,
        notes: notes ?? _value.notes,
        shippingAddress: shippingAddress ?? _value.shippingAddress,
      ),
    );
  }

  $AddressCopyWithProxy<$Res> get shippingAddress => $AddressCopyWithProxy(
    _value.shippingAddress,
    (val) => call(shippingAddress: val),
  );
}

extension OrderCopyWithExtension on Order {
  $OrderCopyWithProxy<Order> get copyWith =>
      $OrderCopyWithProxy(this, (v) => v);

  Order copyWithNull({bool notes = false}) {
    if (!notes) {
      return this;
    }

    return Order(
      id: this.id,
      status: this.status,
      notes: notes ? null : this.notes,
      shippingAddress: this.shippingAddress,
    );
  }
}

UserProfile userProfileFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'id': final Object idRaw, 'score': final Object scoreRaw} => UserProfile(
      userIdFromMap(idRaw),
      scoreFromMap(scoreRaw),
      (json['backupId'] == null ? null : userIdFromMap(json['backupId'])),
    ),
    _ => () {
      if (!json.containsKey('id')) {
        throw FormatException(
          "Missing required field 'id' for UserProfile",
          json,
        );
      }
      if (json['id'] == null) {
        throw FormatException(
          "Invalid type for field 'id' on UserProfile: expected non-null value, got Null",
          json,
        );
      }
      if (!json.containsKey('score')) {
        throw FormatException(
          "Missing required field 'score' for UserProfile",
          json,
        );
      }
      if (json['score'] == null) {
        throw FormatException(
          "Invalid type for field 'score' on UserProfile: expected non-null value, got Null",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for UserProfile: missing or invalid required keys (expected: id, score)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> userProfileToMap(
  UserProfile instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'id': userIdToMap(instance.id),
  'score': scoreToMap(instance.score),
  if (!excludeNull || instance.backupId != null)
    'backupId': instance.backupId == null
        ? null
        : userIdToMap(instance.backupId!),
};
Map<String, dynamic> userProfileToDebugMap(
  UserProfile instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'id': userIdToMap(instance.id),
  'score': scoreToMap(instance.score),
  if (!excludeNull || instance.backupId != null)
    'backupId': instance.backupId == null
        ? null
        : userIdToMap(instance.backupId!),
};
Map<String, dynamic> userProfileDiff(
  UserProfile current,
  UserProfile other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.id != other.id) {
    delta['id'] = userIdToMap(other.id);
  }
  if (current.score != other.score) {
    delta['score'] = scoreToMap(other.score);
  }
  if (current.backupId != other.backupId) {
    delta['backupId'] = (other.backupId == null
        ? null
        : userIdToMap(other.backupId!));
  }
  return delta;
}

extension UserProfileToMapExtension on UserProfile {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      userProfileToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      userProfileToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(UserProfile other, {bool deep = true}) =>
      userProfileDiff(this, other, deep: deep);
}

RecordContainer recordContainerFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {
      'user': final Object userRaw,
      'coords': final Object coordsRaw,
      'inlineAddress': final Object inlineAddressRaw,
    } =>
      RecordContainer(
        userInfoRecordFromMap(userRaw as Map<String, dynamic>),
        geoCoordsRecordFromList(coordsRaw as List<dynamic>),
        (() {
          final map = inlineAddressRaw as Map<String, dynamic>;
          return (city: (map['city'] as String), zip: (map['zip'] as String));
        })(),
        (json['grid'] == null
            ? null
            : (() {
                final list = json['grid'] as List<dynamic>;
                return (((list[0] as num).toInt()), ((list[1] as num).toInt()));
              })()),
      ),
    _ => () {
      if (!json.containsKey('user')) {
        throw FormatException(
          "Missing required field 'user' for RecordContainer",
          json,
        );
      }
      if (json['user'] == null) {
        throw FormatException(
          "Invalid type for field 'user' on RecordContainer: expected non-null value, got Null",
          json,
        );
      }
      if (!json.containsKey('coords')) {
        throw FormatException(
          "Missing required field 'coords' for RecordContainer",
          json,
        );
      }
      if (json['coords'] == null) {
        throw FormatException(
          "Invalid type for field 'coords' on RecordContainer: expected non-null value, got Null",
          json,
        );
      }
      if (!json.containsKey('inlineAddress')) {
        throw FormatException(
          "Missing required field 'inlineAddress' for RecordContainer",
          json,
        );
      }
      if (json['inlineAddress'] == null) {
        throw FormatException(
          "Invalid type for field 'inlineAddress' on RecordContainer: expected non-null value, got Null",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for RecordContainer: missing or invalid required keys (expected: user, coords, inlineAddress)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> recordContainerToMap(
  RecordContainer instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'user': userInfoRecordToMap(instance.user),
  'coords': geoCoordsRecordToList(instance.coords),
  'inlineAddress': {
    'city': instance.inlineAddress.city,
    'zip': instance.inlineAddress.zip,
  },
  if (!excludeNull || instance.grid != null)
    'grid': instance.grid == null
        ? null
        : [instance.grid!.$1, instance.grid!.$2],
};
Map<String, dynamic> recordContainerToDebugMap(
  RecordContainer instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'user': userInfoRecordToMap(instance.user),
  'coords': geoCoordsRecordToList(instance.coords),
  'inlineAddress': {
    'city': instance.inlineAddress.city,
    'zip': instance.inlineAddress.zip,
  },
  if (!excludeNull || instance.grid != null)
    'grid': instance.grid == null
        ? null
        : [instance.grid!.$1, instance.grid!.$2],
};
Map<String, dynamic> recordContainerDiff(
  RecordContainer current,
  RecordContainer other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.user != other.user) {
    delta['user'] = userInfoRecordToMap(other.user);
  }
  if (current.coords != other.coords) {
    delta['coords'] = geoCoordsRecordToList(other.coords);
  }
  if (current.inlineAddress != other.inlineAddress) {
    delta['inlineAddress'] = {
      'city': other.inlineAddress.city,
      'zip': other.inlineAddress.zip,
    };
  }
  if (current.grid != other.grid) {
    delta['grid'] = (other.grid == null
        ? null
        : [other.grid!.$1, other.grid!.$2]);
  }
  return delta;
}

extension RecordContainerToMapExtension on RecordContainer {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      recordContainerToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      recordContainerToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(RecordContainer other, {bool deep = true}) =>
      recordContainerDiff(this, other, deep: deep);
}

SecretProfile secretProfileFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {
      'publicUsername': final String publicUsernameRaw,
      'secretToken': final String secretTokenRaw,
      'rawPassword': final String rawPasswordRaw,
      'creditCards': final List creditCardsRaw,
      'recoveryCodes': final List recoveryCodesRaw,
      'tokens': final Map tokensRaw,
    } =>
      SecretProfile(
        publicUsernameRaw,
        secretTokenRaw,
        rawPasswordRaw,
        (json['optionalPin'] as String?),
        (json['nullablePreserved'] as String?),
        creditCardsRaw.cast<dynamic>().map((e) => (e as String)).toList(),
        recoveryCodesRaw.cast<dynamic>().map((e) => (e as String)).toSet(),
        tokensRaw.cast<String, dynamic>().map(
          (k, v) => MapEntry(k, (v as String)),
        ),
      ),
    _ => () {
      if (!json.containsKey('publicUsername')) {
        throw FormatException(
          "Missing required field 'publicUsername' for SecretProfile",
          json,
        );
      }
      if (json['publicUsername'] is! String) {
        throw FormatException(
          "Invalid type for field 'publicUsername' on SecretProfile: expected String, got ${json['publicUsername'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('secretToken')) {
        throw FormatException(
          "Missing required field 'secretToken' for SecretProfile",
          json,
        );
      }
      if (json['secretToken'] is! String) {
        throw FormatException(
          "Invalid type for field 'secretToken' on SecretProfile: expected String, got ${json['secretToken'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('rawPassword')) {
        throw FormatException(
          "Missing required field 'rawPassword' for SecretProfile",
          json,
        );
      }
      if (json['rawPassword'] is! String) {
        throw FormatException(
          "Invalid type for field 'rawPassword' on SecretProfile: expected String, got ${json['rawPassword'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('creditCards')) {
        throw FormatException(
          "Missing required field 'creditCards' for SecretProfile",
          json,
        );
      }
      if (json['creditCards'] is! List) {
        throw FormatException(
          "Invalid type for field 'creditCards' on SecretProfile: expected List, got ${json['creditCards'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('recoveryCodes')) {
        throw FormatException(
          "Missing required field 'recoveryCodes' for SecretProfile",
          json,
        );
      }
      if (json['recoveryCodes'] is! List) {
        throw FormatException(
          "Invalid type for field 'recoveryCodes' on SecretProfile: expected List, got ${json['recoveryCodes'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('tokens')) {
        throw FormatException(
          "Missing required field 'tokens' for SecretProfile",
          json,
        );
      }
      if (json['tokens'] is! Map) {
        throw FormatException(
          "Invalid type for field 'tokens' on SecretProfile: expected Map, got ${json['tokens'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for SecretProfile: missing or invalid required keys (expected: publicUsername, secretToken, rawPassword, creditCards, recoveryCodes, tokens)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> secretProfileToMap(
  SecretProfile instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'publicUsername': instance.publicUsername,
  'secretToken': instance.secretToken,
  'rawPassword': instance.rawPassword,
  if (!excludeNull || instance.optionalPin != null)
    'optionalPin': instance.optionalPin == null ? null : instance.optionalPin,
  if (!excludeNull || instance.nullablePreserved != null)
    'nullablePreserved': instance.nullablePreserved == null
        ? null
        : instance.nullablePreserved,
  'creditCards': instance.creditCards,
  'recoveryCodes': instance.recoveryCodes.toList(),
  'tokens': instance.tokens,
};
Map<String, dynamic> secretProfileToDebugMap(
  SecretProfile instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'publicUsername': instance.publicUsername,
  'secretToken': '[REDACTED]',
  'rawPassword': ('*'.isNotEmpty ? '*'[0] * instance.rawPassword.length : ''),
  if (!excludeNull || instance.optionalPin != null)
    'optionalPin': instance.optionalPin == null ? null : '[REDACTED]',
  if (!excludeNull || instance.nullablePreserved != null)
    'nullablePreserved': instance.nullablePreserved == null
        ? null
        : ('[REDACTED]'.isNotEmpty
              ? '[REDACTED]'[0] * instance.nullablePreserved!.length
              : ''),
  'creditCards': instance.creditCards.isEmpty
      ? <dynamic>[]
      : <dynamic>['[REDACTED]'],
  'recoveryCodes': instance.recoveryCodes.isEmpty
      ? <dynamic>[]
      : <dynamic>['[REDACTED]'],
  'tokens': '[REDACTED]',
};
Map<String, dynamic> secretProfileDiff(
  SecretProfile current,
  SecretProfile other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.publicUsername != other.publicUsername) {
    delta['publicUsername'] = other.publicUsername;
  }
  if (current.secretToken != other.secretToken) {
    delta['secretToken'] = other.secretToken;
  }
  if (current.rawPassword != other.rawPassword) {
    delta['rawPassword'] = other.rawPassword;
  }
  if (current.optionalPin != other.optionalPin) {
    delta['optionalPin'] = other.optionalPin;
  }
  if (current.nullablePreserved != other.nullablePreserved) {
    delta['nullablePreserved'] = other.nullablePreserved;
  }
  if (!$listEquals(current.creditCards, other.creditCards)) {
    delta['creditCards'] = other.creditCards;
  }
  if (!$setEquals(current.recoveryCodes, other.recoveryCodes)) {
    delta['recoveryCodes'] = other.recoveryCodes.toList();
  }
  if (!$mapEquals(current.tokens, other.tokens)) {
    delta['tokens'] = other.tokens;
  }
  return delta;
}

extension SecretProfileToMapExtension on SecretProfile {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      secretProfileToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      secretProfileToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(SecretProfile other, {bool deep = true}) =>
      secretProfileDiff(this, other, deep: deep);
}

mixin _$SecretProfileEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SecretProfile || runtimeType != other.runtimeType)
      return false;
    final self = this as SecretProfile;
    return self.publicUsername == other.publicUsername &&
        self.secretToken == other.secretToken &&
        self.rawPassword == other.rawPassword &&
        self.optionalPin == other.optionalPin &&
        self.nullablePreserved == other.nullablePreserved &&
        $listEquals(self.creditCards, other.creditCards) &&
        $setEquals(self.recoveryCodes, other.recoveryCodes) &&
        $mapEquals(self.tokens, other.tokens);
  }

  @override
  int get hashCode {
    final self = this as SecretProfile;
    return Object.hash(
      self.publicUsername,
      self.secretToken,
      self.rawPassword,
      self.optionalPin,
      self.nullablePreserved,
      $listHashCode(self.creditCards),
      $setHashCode(self.recoveryCodes),
      $mapHashCode(self.tokens),
    );
  }
}

mixin _$SecretProfileStringify {
  @override
  String toString() {
    final self = this as SecretProfile;
    return 'SecretProfile(publicUsername: ${self.publicUsername}, secretToken: [REDACTED], rawPassword: ${'*'.isNotEmpty ? '*'[0] * self.rawPassword.length : ''}, optionalPin: ${self.optionalPin == null ? 'null' : '[REDACTED]'}, nullablePreserved: ${self.nullablePreserved == null ? 'null' : ('[REDACTED]'.isNotEmpty ? '[REDACTED]'[0] * self.nullablePreserved!.length : '')}, creditCards: [REDACTED], recoveryCodes: [REDACTED], tokens: [REDACTED])';
  }
}

mixin _$SecretProfile
    implements _$SecretProfileEqualsAndHashCode, _$SecretProfileStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SecretProfile || runtimeType != other.runtimeType)
      return false;
    final self = this as SecretProfile;
    return self.publicUsername == other.publicUsername &&
        self.secretToken == other.secretToken &&
        self.rawPassword == other.rawPassword &&
        self.optionalPin == other.optionalPin &&
        self.nullablePreserved == other.nullablePreserved &&
        $listEquals(self.creditCards, other.creditCards) &&
        $setEquals(self.recoveryCodes, other.recoveryCodes) &&
        $mapEquals(self.tokens, other.tokens);
  }

  @override
  int get hashCode {
    final self = this as SecretProfile;
    return Object.hash(
      self.publicUsername,
      self.secretToken,
      self.rawPassword,
      self.optionalPin,
      self.nullablePreserved,
      $listHashCode(self.creditCards),
      $setHashCode(self.recoveryCodes),
      $mapHashCode(self.tokens),
    );
  }

  @override
  String toString() {
    final self = this as SecretProfile;
    return 'SecretProfile(publicUsername: ${self.publicUsername}, secretToken: [REDACTED], rawPassword: ${'*'.isNotEmpty ? '*'[0] * self.rawPassword.length : ''}, optionalPin: ${self.optionalPin == null ? 'null' : '[REDACTED]'}, nullablePreserved: ${self.nullablePreserved == null ? 'null' : ('[REDACTED]'.isNotEmpty ? '[REDACTED]'[0] * self.nullablePreserved!.length : '')}, creditCards: [REDACTED], recoveryCodes: [REDACTED], tokens: [REDACTED])';
  }
}

AccountCredentials accountCredentialsFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {
      'accountId': final String accountIdRaw,
      'profile': final Map profileRaw,
      'wholesaleRedactedProfile': final Map wholesaleRedactedProfileRaw,
    } =>
      AccountCredentials(
        accountIdRaw,
        secretProfileFromMap(profileRaw.cast<String, dynamic>()),
        secretProfileFromMap(
          wholesaleRedactedProfileRaw.cast<String, dynamic>(),
        ),
      ),
    _ => () {
      if (!json.containsKey('accountId')) {
        throw FormatException(
          "Missing required field 'accountId' for AccountCredentials",
          json,
        );
      }
      if (json['accountId'] is! String) {
        throw FormatException(
          "Invalid type for field 'accountId' on AccountCredentials: expected String, got ${json['accountId'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('profile')) {
        throw FormatException(
          "Missing required field 'profile' for AccountCredentials",
          json,
        );
      }
      if (json['profile'] is! Map) {
        throw FormatException(
          "Invalid type for field 'profile' on AccountCredentials: expected Map, got ${json['profile'].runtimeType}",
          json,
        );
      }
      if (!json.containsKey('wholesaleRedactedProfile')) {
        throw FormatException(
          "Missing required field 'wholesaleRedactedProfile' for AccountCredentials",
          json,
        );
      }
      if (json['wholesaleRedactedProfile'] is! Map) {
        throw FormatException(
          "Invalid type for field 'wholesaleRedactedProfile' on AccountCredentials: expected Map, got ${json['wholesaleRedactedProfile'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for AccountCredentials: missing or invalid required keys (expected: accountId, profile, wholesaleRedactedProfile)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> accountCredentialsToMap(
  AccountCredentials instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'accountId': instance.accountId,
  'profile': secretProfileToMap(instance.profile),
  'wholesaleRedactedProfile': secretProfileToMap(
    instance.wholesaleRedactedProfile,
  ),
};
Map<String, dynamic> accountCredentialsToDebugMap(
  AccountCredentials instance, {
  bool excludeNull = false,
}) => <String, dynamic>{
  'accountId': instance.accountId,
  'profile': secretProfileToDebugMap(
    instance.profile,
    excludeNull: excludeNull,
  ),
  'wholesaleRedactedProfile': '[REDACTED]',
};
Map<String, dynamic> accountCredentialsDiff(
  AccountCredentials current,
  AccountCredentials other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  final delta = <String, dynamic>{};
  if (current.accountId != other.accountId) {
    delta['accountId'] = other.accountId;
  }
  if (deep) {
    final childDiff = secretProfileDiff(
      current.profile,
      other.profile,
      deep: true,
    );
    if (childDiff.isNotEmpty) {
      delta['profile'] = childDiff;
    }
  } else {
    final childDiff = secretProfileDiff(
      current.profile,
      other.profile,
      deep: false,
    );
    if (childDiff.isNotEmpty) {
      delta['profile'] = secretProfileToMap(other.profile);
    }
  }
  if (deep) {
    final childDiff = secretProfileDiff(
      current.wholesaleRedactedProfile,
      other.wholesaleRedactedProfile,
      deep: true,
    );
    if (childDiff.isNotEmpty) {
      delta['wholesaleRedactedProfile'] = childDiff;
    }
  } else {
    final childDiff = secretProfileDiff(
      current.wholesaleRedactedProfile,
      other.wholesaleRedactedProfile,
      deep: false,
    );
    if (childDiff.isNotEmpty) {
      delta['wholesaleRedactedProfile'] = secretProfileToMap(
        other.wholesaleRedactedProfile,
      );
    }
  }
  return delta;
}

extension AccountCredentialsToMapExtension on AccountCredentials {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      accountCredentialsToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      accountCredentialsToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(AccountCredentials other, {bool deep = true}) =>
      accountCredentialsDiff(this, other, deep: deep);
}

mixin _$AccountCredentialsEqualsAndHashCode {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccountCredentials || runtimeType != other.runtimeType)
      return false;
    final self = this as AccountCredentials;
    return self.accountId == other.accountId &&
        self.profile == other.profile &&
        self.wholesaleRedactedProfile == other.wholesaleRedactedProfile;
  }

  @override
  int get hashCode {
    final self = this as AccountCredentials;
    return Object.hash(
      self.accountId,
      self.profile,
      self.wholesaleRedactedProfile,
    );
  }
}

mixin _$AccountCredentialsStringify {
  @override
  String toString() {
    final self = this as AccountCredentials;
    return 'AccountCredentials(accountId: ${self.accountId}, profile: ${self.profile}, wholesaleRedactedProfile: [REDACTED])';
  }
}

mixin _$AccountCredentials
    implements
        _$AccountCredentialsEqualsAndHashCode,
        _$AccountCredentialsStringify {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccountCredentials || runtimeType != other.runtimeType)
      return false;
    final self = this as AccountCredentials;
    return self.accountId == other.accountId &&
        self.profile == other.profile &&
        self.wholesaleRedactedProfile == other.wholesaleRedactedProfile;
  }

  @override
  int get hashCode {
    final self = this as AccountCredentials;
    return Object.hash(
      self.accountId,
      self.profile,
      self.wholesaleRedactedProfile,
    );
  }

  @override
  String toString() {
    final self = this as AccountCredentials;
    return 'AccountCredentials(accountId: ${self.accountId}, profile: ${self.profile}, wholesaleRedactedProfile: [REDACTED])';
  }
}

Shape shapeFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'shape_type': 'Circle'} => circleFromMap(json),
    {'shape_type': 'Square'} => squareFromMap(json),
    _ => () {
      if (!json.containsKey('shape_type')) {
        throw FormatException(
          "Missing required discriminator 'shape_type' for Shape",
          json,
        );
      }
      throw FormatException(
        "Unknown Shape discriminator: '${json['shape_type']}'",
        json,
      );
    }(),
  };
}

Map<String, dynamic> shapeToMap(Shape instance, {bool excludeNull = false}) {
  return switch (instance) {
    final Circle circle => circleToMap(
      circle,
      excludeNull: excludeNull,
    )..['shape_type'] = 'Circle',
    final Square square => squareToMap(
      square,
      excludeNull: excludeNull,
    )..['shape_type'] = 'Square',
  };
}

Map<String, dynamic> shapeToDebugMap(
  Shape instance, {
  bool excludeNull = false,
}) {
  return switch (instance) {
    final Circle circle => circleToDebugMap(
      circle,
      excludeNull: excludeNull,
    )..['shape_type'] = 'Circle',
    final Square square => squareToDebugMap(
      square,
      excludeNull: excludeNull,
    )..['shape_type'] = 'Square',
  };
}

Map<String, dynamic> shapeDiff(Shape current, Shape other, {bool deep = true}) {
  if (identical(current, other)) return const <String, dynamic>{};
  return switch ((current, other)) {
    (final Circle c, final Circle o) => circleDiff(c, o, deep: deep),
    (final Square c, final Square o) => squareDiff(c, o, deep: deep),
    _ => other.toMap(),
  };
}

extension ShapeToMapExtension on Shape {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      shapeToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      shapeToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Shape other, {bool deep = true}) =>
      shapeDiff(this, other, deep: deep);
}

Vehicle vehicleFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'vehicle_type': 'car_v1'} => carFromMap(json),
    {'vehicle_type': 'Bike'} => bikeFromMap(json),
    _ => () {
      if (!json.containsKey('vehicle_type')) {
        throw FormatException(
          "Missing required discriminator 'vehicle_type' for Vehicle",
          json,
        );
      }
      throw FormatException(
        "Unknown Vehicle discriminator: '${json['vehicle_type']}'",
        json,
      );
    }(),
  };
}

Map<String, dynamic> vehicleToMap(
  Vehicle instance, {
  bool excludeNull = false,
}) {
  return switch (instance) {
    final Car car => carToMap(
      car,
      excludeNull: excludeNull,
    )..['vehicle_type'] = 'car_v1',
    final Bike bike => bikeToMap(
      bike,
      excludeNull: excludeNull,
    )..['vehicle_type'] = 'Bike',
  };
}

Map<String, dynamic> vehicleToDebugMap(
  Vehicle instance, {
  bool excludeNull = false,
}) {
  return switch (instance) {
    final Car car => carToDebugMap(
      car,
      excludeNull: excludeNull,
    )..['vehicle_type'] = 'car_v1',
    final Bike bike => bikeToDebugMap(
      bike,
      excludeNull: excludeNull,
    )..['vehicle_type'] = 'Bike',
  };
}

Map<String, dynamic> vehicleDiff(
  Vehicle current,
  Vehicle other, {
  bool deep = true,
}) {
  if (identical(current, other)) return const <String, dynamic>{};
  return switch ((current, other)) {
    (final Car c, final Car o) => carDiff(c, o, deep: deep),
    (final Bike c, final Bike o) => bikeDiff(c, o, deep: deep),
    _ => other.toMap(),
  };
}

extension VehicleToMapExtension on Vehicle {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      vehicleToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      vehicleToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Vehicle other, {bool deep = true}) =>
      vehicleDiff(this, other, deep: deep);
}

Event eventFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'type': 'LoginEvent'} => loginEventFromMap(json),
    {'type': 'LogoutEvent'} => logoutEventFromMap(json),
    _ => () {
      if (!json.containsKey('type')) {
        throw FormatException(
          "Missing required discriminator 'type' for Event",
          json,
        );
      }
      throw FormatException(
        "Unknown Event discriminator: '${json['type']}'",
        json,
      );
    }(),
  };
}

Map<String, dynamic> eventToMap(Event instance, {bool excludeNull = false}) {
  return switch (instance) {
    final LoginEvent loginEvent => loginEventToMap(
      loginEvent,
      excludeNull: excludeNull,
    )..['type'] = 'LoginEvent',
    final LogoutEvent logoutEvent => logoutEventToMap(
      logoutEvent,
      excludeNull: excludeNull,
    )..['type'] = 'LogoutEvent',
  };
}

Map<String, dynamic> eventToDebugMap(
  Event instance, {
  bool excludeNull = false,
}) {
  return switch (instance) {
    final LoginEvent loginEvent => loginEventToDebugMap(
      loginEvent,
      excludeNull: excludeNull,
    )..['type'] = 'LoginEvent',
    final LogoutEvent logoutEvent => logoutEventToDebugMap(
      logoutEvent,
      excludeNull: excludeNull,
    )..['type'] = 'LogoutEvent',
  };
}

Map<String, dynamic> eventDiff(Event current, Event other, {bool deep = true}) {
  if (identical(current, other)) return const <String, dynamic>{};
  return switch ((current, other)) {
    (final LoginEvent c, final LoginEvent o) => loginEventDiff(
      c,
      o,
      deep: deep,
    ),
    (final LogoutEvent c, final LogoutEvent o) => logoutEventDiff(
      c,
      o,
      deep: deep,
    ),
    _ => other.toMap(),
  };
}

extension EventToMapExtension on Event {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      eventToMap(this, excludeNull: excludeNull);

  Map<String, dynamic> toDebugMap({bool excludeNull = false}) =>
      eventToDebugMap(this, excludeNull: excludeNull);

  Map<String, dynamic> diff(Event other, {bool deep = true}) =>
      eventDiff(this, other, deep: deep);
}

Object? _daxleResolveKey(
  Map<String, dynamic> json,
  String key,
  List<String> aliases,
) {
  if (json.containsKey(key)) return json[key];
  for (final alias in aliases) {
    if (json.containsKey(alias)) return json[alias];
  }
  return null;
}

bool _daxleHasKey(Map<String, dynamic> json, String key, List<String> aliases) {
  if (json.containsKey(key)) return true;
  for (final alias in aliases) {
    if (json.containsKey(alias)) return true;
  }
  return false;
}

Map<String, dynamic> _daxleExtractPrefix(
  Map<String, dynamic> json,
  String prefix,
) {
  if (prefix.isEmpty) return json;
  final result = <String, dynamic>{};
  for (final entry in json.entries) {
    if (entry.key.startsWith(prefix)) {
      result[entry.key.substring(prefix.length)] = entry.value;
    }
  }
  return result;
}
