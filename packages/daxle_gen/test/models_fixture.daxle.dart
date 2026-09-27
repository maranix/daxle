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
const _annotatedEnumEnumMap = {
  AnnotatedEnum.inProgress: 'in_progress',
  AnnotatedEnum.archived: 'archived_val',
};
dynamic annotatedEnumToValue(AnnotatedEnum instance) =>
    _annotatedEnumEnumMap[instance]!;
AnnotatedEnum annotatedEnumFromValue(Object? value) => switch (value) {
  'in_progress' => AnnotatedEnum.inProgress,
  'internalSecret' => AnnotatedEnum.internalSecret,
  'archived_val' => AnnotatedEnum.archived,
  _ => throw ArgumentError('Unknown AnnotatedEnum value: $value'),
};
ComplexModel complexModelFromJson(Map<String, dynamic> json) {
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
        (json['optionalTag'] == null
            ? const None()
            : Some((json['optionalTag'] as String))),
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
  ComplexModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'count': instance.count,
  'rating': instance.rating,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'website': instance.website.toString(),
  'score': instance.score.toString(),
  'timeout': instance.timeout.inMicroseconds,
  'optionalTag': switch (instance.optionalTag) {
    Some(:final value) => value,
    None() => null,
  },
  'metadata': instance.metadata.map,
  'tags': instance.tags,
  'numbers': instance.numbers.toList(),
  'scores': instance.scores,
  'status': statusToValue(instance.status),
  'priority': priorityToValue(instance.priority),
  'role': instance.role,
  if (instance.customEpoch != null)
    'customEpoch': const EpochDateTimeConverter().toJson(instance.customEpoch!),
};

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
        self.status == other.status &&
        self.priority == other.priority &&
        self.role == other.role &&
        self.secretToken == other.secretToken &&
        self.createdAt == other.createdAt &&
        self.website == other.website &&
        self.score == other.score &&
        self.timeout == other.timeout &&
        self.optionalTag == other.optionalTag &&
        self.customEpoch == other.customEpoch &&
        _daxleDeepEquals(self.metadata, other.metadata) &&
        _daxleDeepEquals(self.tags, other.tags) &&
        _daxleDeepEquals(self.numbers, other.numbers) &&
        _daxleDeepEquals(self.scores, other.scores);
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
      _daxleDeepHashCode(self.metadata),
      _daxleDeepHashCode(self.tags),
      _daxleDeepHashCode(self.numbers),
      _daxleDeepHashCode(self.scores),
      self.status,
      self.priority,
      self.role,
      self.secretToken,
      self.customEpoch,
    );
  }
}

mixin _$ComplexModelStringify {
  @override
  String toString() {
    final self = this as ComplexModel;
    return 'ComplexModel(id: ${self.id}, count: ${self.count}, rating: ${self.rating}, isActive: ${self.isActive}, createdAt: ${self.createdAt}, website: ${self.website}, score: ${self.score}, timeout: ${self.timeout}, optionalTag: ${self.optionalTag}, metadata: ${self.metadata}, tags: ${self.tags}, numbers: ${self.numbers}, scores: ${self.scores}, status: ${self.status}, priority: ${self.priority}, role: ${self.role}, secretToken: ${self.secretToken}, customEpoch: ${self.customEpoch})';
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
        self.status == other.status &&
        self.priority == other.priority &&
        self.role == other.role &&
        self.secretToken == other.secretToken &&
        self.createdAt == other.createdAt &&
        self.website == other.website &&
        self.score == other.score &&
        self.timeout == other.timeout &&
        self.optionalTag == other.optionalTag &&
        self.customEpoch == other.customEpoch &&
        _daxleDeepEquals(self.metadata, other.metadata) &&
        _daxleDeepEquals(self.tags, other.tags) &&
        _daxleDeepEquals(self.numbers, other.numbers) &&
        _daxleDeepEquals(self.scores, other.scores);
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
      _daxleDeepHashCode(self.metadata),
      _daxleDeepHashCode(self.tags),
      _daxleDeepHashCode(self.numbers),
      _daxleDeepHashCode(self.scores),
      self.status,
      self.priority,
      self.role,
      self.secretToken,
      self.customEpoch,
    );
  }

  @override
  String toString() {
    final self = this as ComplexModel;
    return 'ComplexModel(id: ${self.id}, count: ${self.count}, rating: ${self.rating}, isActive: ${self.isActive}, createdAt: ${self.createdAt}, website: ${self.website}, score: ${self.score}, timeout: ${self.timeout}, optionalTag: ${self.optionalTag}, metadata: ${self.metadata}, tags: ${self.tags}, numbers: ${self.numbers}, scores: ${self.scores}, status: ${self.status}, priority: ${self.priority}, role: ${self.role}, secretToken: ${self.secretToken}, customEpoch: ${self.customEpoch})';
  }
}

extension ComplexModelCopyWithExtension on ComplexModel {
  ComplexModel copyWith({
    String? id,
    int? count,
    double? rating,
    bool? isActive,
    DateTime? createdAt,
    Uri? website,
    BigInt? score,
    Duration? timeout,
    Option<String>? optionalTag,
    QueryMap? metadata,
    List<String>? tags,
    Set<int>? numbers,
    Map<String, int>? scores,
    Status? status,
    Priority? priority,
    String? role,
    String? secretToken,
    DateTime? customEpoch,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (count == null || identical(count, this.count)) &&
        (rating == null || identical(rating, this.rating)) &&
        (isActive == null || identical(isActive, this.isActive)) &&
        (createdAt == null || identical(createdAt, this.createdAt)) &&
        (website == null || identical(website, this.website)) &&
        (score == null || identical(score, this.score)) &&
        (timeout == null || identical(timeout, this.timeout)) &&
        (optionalTag == null || identical(optionalTag, this.optionalTag)) &&
        (metadata == null || identical(metadata, this.metadata)) &&
        (tags == null || identical(tags, this.tags)) &&
        (numbers == null || identical(numbers, this.numbers)) &&
        (scores == null || identical(scores, this.scores)) &&
        (status == null || identical(status, this.status)) &&
        (priority == null || identical(priority, this.priority)) &&
        (role == null || identical(role, this.role)) &&
        (secretToken == null || identical(secretToken, this.secretToken)) &&
        (customEpoch == null || identical(customEpoch, this.customEpoch))) {
      return this;
    }

    return ComplexModel(
      id ?? this.id,
      count ?? this.count,
      rating ?? this.rating,
      isActive ?? this.isActive,
      createdAt ?? this.createdAt,
      website ?? this.website,
      score ?? this.score,
      timeout ?? this.timeout,
      optionalTag ?? this.optionalTag,
      metadata ?? this.metadata,
      tags ?? this.tags,
      numbers ?? this.numbers,
      scores ?? this.scores,
      status ?? this.status,
      priority ?? this.priority,
      role: role ?? this.role,
      secretToken: secretToken ?? this.secretToken,
      customEpoch: customEpoch ?? this.customEpoch,
    );
  }

  ComplexModel copyWithNull({bool customEpoch = false}) {
    if (!customEpoch) {
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
      this.optionalTag,
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

NestedContainer nestedContainerFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'containerId': final String containerIdRaw, 'model': final Map modelRaw} =>
      NestedContainer(
        containerId: containerIdRaw,
        model: complexModelFromJson(modelRaw.cast<String, dynamic>()),
        optionalModel: (json['optionalModel'] == null
            ? null
            : complexModelFromJson(
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

Map<String, dynamic> nestedContainerToMap(NestedContainer instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'model': complexModelToMap(instance.model),
      if (instance.optionalModel != null)
        'optionalModel': complexModelToMap(instance.optionalModel!),
    };

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

extension NestedContainerCopyWithExtension on NestedContainer {
  NestedContainer copyWith({
    String? containerId,
    ComplexModel? model,
    ComplexModel? optionalModel,
  }) {
    if ((containerId == null || identical(containerId, this.containerId)) &&
        (model == null || identical(model, this.model)) &&
        (optionalModel == null ||
            identical(optionalModel, this.optionalModel))) {
      return this;
    }

    return NestedContainer(
      containerId: containerId ?? this.containerId,
      model: model ?? this.model,
      optionalModel: optionalModel ?? this.optionalModel,
    );
  }

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

Circle circleFromJson(Map<String, dynamic> json) {
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

Map<String, dynamic> circleToMap(Circle instance) => <String, dynamic>{
  'radius': instance.radius,
};
Square squareFromJson(Map<String, dynamic> json) {
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

Map<String, dynamic> squareToMap(Square instance) => <String, dynamic>{
  'side': instance.side,
};
Car carFromJson(Map<String, dynamic> json) {
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

Map<String, dynamic> carToMap(Car instance) => <String, dynamic>{
  'seats': instance.seats,
};
Bike bikeFromJson(Map<String, dynamic> json) {
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

Map<String, dynamic> bikeToMap(Bike instance) => <String, dynamic>{
  'hasPedals': instance.hasPedals,
};
AsymmetricModel asymmetricModelFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'incoming_key': final String keyRaw} => AsymmetricModel(keyRaw),
    _ => () {
      if (!json.containsKey('incoming_key')) {
        throw FormatException(
          "Missing required field 'incoming_key' for AsymmetricModel",
          json,
        );
      }
      if (json['incoming_key'] is! String) {
        throw FormatException(
          "Invalid type for field 'incoming_key' on AsymmetricModel: expected String, got ${json['incoming_key'].runtimeType}",
          json,
        );
      }
      throw FormatException(
        'Invalid JSON shape for AsymmetricModel: missing or invalid required keys (expected: incoming_key)',
        json,
      );
    }(),
  };
}

Map<String, dynamic> asymmetricModelToMap(AsymmetricModel instance) =>
    <String, dynamic>{'outgoing_key': instance.key};
NullableConverterModel nullableConverterModelFromJson(
  Map<String, dynamic> json,
) {
  return switch (json) {
    _ => NullableConverterModel(
      json['nullableConvertedInt'] == null
          ? null
          : const StringIntConverter().fromJson(json['nullableConvertedInt']),
    ),
  };
}

Map<String, dynamic> nullableConverterModelToMap(
  NullableConverterModel instance,
) => <String, dynamic>{
  if (instance.nullableConvertedInt != null)
    'nullableConvertedInt': const StringIntConverter().toJson(
      instance.nullableConvertedInt!,
    ),
};
DeepCollectionsModel deepCollectionsModelFromJson(Map<String, dynamic> json) {
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

Map<String, dynamic> deepCollectionsModelToMap(DeepCollectionsModel instance) =>
    <String, dynamic>{
      'matrix': instance.matrix.map((e) => e).toList(),
      'mappedLists': instance.mappedLists.map((k, v) => MapEntry(k, v)),
    };
CaseStyledModel caseStyledModelFromJson(Map<String, dynamic> json) {
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

Map<String, dynamic> caseStyledModelToMap(CaseStyledModel instance) =>
    <String, dynamic>{
      'user_full_name': instance.userFullName,
      'login_attempt_count': instance.loginAttemptCount,
    };

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

extension CaseStyledModelCopyWithExtension on CaseStyledModel {
  CaseStyledModel copyWith({String? userFullName, int? loginAttemptCount}) {
    if ((userFullName == null || identical(userFullName, this.userFullName)) &&
        (loginAttemptCount == null ||
            identical(loginAttemptCount, this.loginAttemptCount))) {
      return this;
    }

    return CaseStyledModel(
      userFullName ?? this.userFullName,
      loginAttemptCount ?? this.loginAttemptCount,
      internalSecret: this.internalSecret,
    );
  }
}

LoginEvent loginEventFromJson(Map<String, dynamic> json) {
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

Map<String, dynamic> loginEventToMap(LoginEvent instance) => <String, dynamic>{
  'userId': instance.userId,
};
LogoutEvent logoutEventFromJson(Map<String, dynamic> json) {
  return switch (json) {
    _ => LogoutEvent(),
  };
}

Map<String, dynamic> logoutEventToMap(LogoutEvent instance) =>
    <String, dynamic>{};

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

extension LargeModelCopyWithExtension on LargeModel {
  LargeModel copyWith({
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
    if ((f1 == null || identical(f1, this.f1)) &&
        (f2 == null || identical(f2, this.f2)) &&
        (f3 == null || identical(f3, this.f3)) &&
        (f4 == null || identical(f4, this.f4)) &&
        (f5 == null || identical(f5, this.f5)) &&
        (f6 == null || identical(f6, this.f6)) &&
        (f7 == null || identical(f7, this.f7)) &&
        (f8 == null || identical(f8, this.f8)) &&
        (f9 == null || identical(f9, this.f9)) &&
        (f10 == null || identical(f10, this.f10)) &&
        (f11 == null || identical(f11, this.f11)) &&
        (f12 == null || identical(f12, this.f12)) &&
        (f13 == null || identical(f13, this.f13)) &&
        (f14 == null || identical(f14, this.f14)) &&
        (f15 == null || identical(f15, this.f15)) &&
        (f16 == null || identical(f16, this.f16)) &&
        (f17 == null || identical(f17, this.f17)) &&
        (f18 == null || identical(f18, this.f18)) &&
        (f19 == null || identical(f19, this.f19)) &&
        (f20 == null || identical(f20, this.f20)) &&
        (f21 == null || identical(f21, this.f21)) &&
        (f22 == null || identical(f22, this.f22))) {
      return this;
    }

    return LargeModel(
      f1 ?? this.f1,
      f2 ?? this.f2,
      f3 ?? this.f3,
      f4 ?? this.f4,
      f5 ?? this.f5,
      f6 ?? this.f6,
      f7 ?? this.f7,
      f8 ?? this.f8,
      f9 ?? this.f9,
      f10 ?? this.f10,
      f11 ?? this.f11,
      f12 ?? this.f12,
      f13 ?? this.f13,
      f14 ?? this.f14,
      f15 ?? this.f15,
      f16 ?? this.f16,
      f17 ?? this.f17,
      f18 ?? this.f18,
      f19 ?? this.f19,
      f20 ?? this.f20,
      f21 ?? this.f21,
      f22 ?? this.f22,
    );
  }
}

Shape shapeFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'shape_type': 'Circle'} => circleFromJson(json),
    {'shape_type': 'Square'} => squareFromJson(json),
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

Map<String, dynamic> shapeToMap(Shape instance) {
  return switch (instance) {
    final Circle circle => circleToMap(circle)..['shape_type'] = 'Circle',
    final Square square => squareToMap(square)..['shape_type'] = 'Square',
  };
}

Vehicle vehicleFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'vehicle_type': 'car_v1'} => carFromJson(json),
    {'vehicle_type': 'Bike'} => bikeFromJson(json),
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

Map<String, dynamic> vehicleToMap(Vehicle instance) {
  return switch (instance) {
    final Car car => carToMap(car)..['vehicle_type'] = 'car_v1',
    final Bike bike => bikeToMap(bike)..['vehicle_type'] = 'Bike',
  };
}

Event eventFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'type': 'LoginEvent'} => loginEventFromJson(json),
    {'type': 'LogoutEvent'} => logoutEventFromJson(json),
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

Map<String, dynamic> eventToMap(Event instance) {
  return switch (instance) {
    final LoginEvent loginEvent => loginEventToMap(
      loginEvent,
    )..['type'] = 'LoginEvent',
    final LogoutEvent logoutEvent => logoutEventToMap(
      logoutEvent,
    )..['type'] = 'LogoutEvent',
  };
}

bool _daxleDeepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;

  if (a is List && b is List) {
    final length = a.length;
    if (length != b.length) return false;
    for (var i = 0; i < length; i++) {
      if (!_daxleDeepEquals(a[i], b[i])) return false;
    }
    return true;
  }

  if (a is Set && b is Set) {
    if (a.length != b.length) return false;
    for (final element in a) {
      if (!b.contains(element)) {
        var found = false;
        for (final otherElement in b) {
          if (_daxleDeepEquals(element, otherElement)) {
            found = true;
            break;
          }
        }
        if (!found) return false;
      }
    }
    return true;
  }

  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key)) return false;
      if (!_daxleDeepEquals(entry.value, b[entry.key])) return false;
    }
    return true;
  }

  if (a is Iterable && b is Iterable) {
    final itA = a.iterator;
    final itB = b.iterator;
    while (itA.moveNext()) {
      if (!itB.moveNext()) return false;
      if (!_daxleDeepEquals(itA.current, itB.current)) return false;
    }
    return !itB.moveNext();
  }

  return a == b;
}

int _daxleDeepHashCode(Object? value) {
  if (value == null) return 0;
  if (value is List) {
    var hash = 1;
    for (var i = 0; i < value.length; i++) {
      hash = 0x1fffffff & (hash + _daxleDeepHashCode(value[i]));
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
  if (value is Set) {
    var hash = 0;
    for (final element in value) {
      hash = (hash + _daxleDeepHashCode(element)) & 0x3fffffff;
    }
    return hash;
  }
  if (value is Map) {
    var hash = 0;
    for (final entry in value.entries) {
      final entryHash =
          (_daxleDeepHashCode(entry.key) ^ _daxleDeepHashCode(entry.value)) &
          0x3fffffff;
      hash = (hash + entryHash) & 0x3fffffff;
    }
    return hash;
  }
  if (value is Iterable) {
    var hash = 1;
    for (final element in value) {
      hash = 0x1fffffff & (hash + _daxleDeepHashCode(element));
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
  return value.hashCode;
}
