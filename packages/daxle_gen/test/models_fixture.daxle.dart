// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'models_fixture.dart';

const statusEnumMap = {
  Status.pending: 'pending',
  Status.active: 'active',
  Status.completed: 'completed',
};
dynamic statusToValue(Status instance) => statusEnumMap[instance]!;
Status statusFromValue(Object? value) {
  for (final entry in statusEnumMap.entries) {
    if (entry.value == value) return entry.key;
  }
  throw ArgumentError('Unknown Status value: $value');
}

Status statusFromJson(Object? value) => statusFromValue(value);
dynamic statusToJson(Status instance) => statusToValue(instance);
const priorityEnumMap = {
  Priority.low: 10,
  Priority.medium: 20,
  Priority.high: 30,
};
dynamic priorityToValue(Priority instance) => priorityEnumMap[instance]!;
Priority priorityFromValue(Object? value) {
  for (final entry in priorityEnumMap.entries) {
    if (entry.value == value) return entry.key;
  }
  throw ArgumentError('Unknown Priority value: $value');
}

Priority priorityFromJson(Object? value) => priorityFromValue(value);
dynamic priorityToJson(Priority instance) => priorityToValue(instance);
const multiParamEnumEnumMap = {
  MultiParamEnum.first: 101,
  MultiParamEnum.second: 202,
};
dynamic multiParamEnumToValue(MultiParamEnum instance) =>
    multiParamEnumEnumMap[instance]!;
MultiParamEnum multiParamEnumFromValue(Object? value) {
  for (final entry in multiParamEnumEnumMap.entries) {
    if (entry.value == value) return entry.key;
  }
  throw ArgumentError('Unknown MultiParamEnum value: $value');
}

MultiParamEnum multiParamEnumFromJson(Object? value) =>
    multiParamEnumFromValue(value);
dynamic multiParamEnumToJson(MultiParamEnum instance) =>
    multiParamEnumToValue(instance);
const themeModeEnumMap = {
  ThemeMode.lightTheme: 'light-theme',
  ThemeMode.darkTheme: 'dark-theme',
  ThemeMode.systemDefault: 'system-default',
};
dynamic themeModeToValue(ThemeMode instance) => themeModeEnumMap[instance]!;
ThemeMode themeModeFromValue(Object? value) {
  for (final entry in themeModeEnumMap.entries) {
    if (entry.value == value) return entry.key;
  }
  throw ArgumentError('Unknown ThemeMode value: $value');
}

ThemeMode themeModeFromJson(Object? value) => themeModeFromValue(value);
dynamic themeModeToJson(ThemeMode instance) => themeModeToValue(instance);
ComplexModel complexModelFromJson(Map<String, dynamic> json) {
  return ComplexModel(
    (json['id'] as String),
    ((json['count'] as num).toInt()),
    ((json['rating'] as num).toDouble()),
    (json['isActive'] as bool),
    DateTime.parse(json['createdAt'] as String),
    Uri.parse(json['website'] as String),
    BigInt.parse(json['score'] as String),
    Duration(microseconds: (json['timeout'] as num).toInt()),
    (json['optionalTag'] == null
        ? const None()
        : Some((json['optionalTag'] as String))),
    QueryMap((json['metadata'] as Map).cast<Object?, Object?>()),
    (json['tags'] as List<dynamic>).map((e) => (e as String)).toList(),
    (json['numbers'] as List<dynamic>).map((e) => ((e as num).toInt())).toSet(),
    (json['scores'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, ((v as num).toInt())),
    ),
    statusFromValue(json['status']),
    priorityFromValue(json['priority']),
    role: json['role'] == null ? 'guest' : (json['role'] as String),
    customEpoch: json['customEpoch'] == null
        ? null
        : const EpochDateTimeConverter().fromJson(json['customEpoch']),
  );
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
NestedContainer nestedContainerFromJson(Map<String, dynamic> json) {
  return NestedContainer(
    containerId: (json['containerId'] as String),
    model: complexModelFromJson(json['model'] as Map<String, dynamic>),
    optionalModel: (json['optionalModel'] == null
        ? null
        : complexModelFromJson(json['optionalModel'] as Map<String, dynamic>)),
  );
}

Map<String, dynamic> nestedContainerToMap(NestedContainer instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'model': complexModelToMap(instance.model),
      if (instance.optionalModel != null)
        'optionalModel': complexModelToMap(instance.optionalModel!),
    };
Circle circleFromJson(Map<String, dynamic> json) {
  return Circle(((json['radius'] as num).toDouble()));
}

Map<String, dynamic> circleToMap(Circle instance) => <String, dynamic>{
  'radius': instance.radius,
};
Square squareFromJson(Map<String, dynamic> json) {
  return Square(((json['side'] as num).toDouble()));
}

Map<String, dynamic> squareToMap(Square instance) => <String, dynamic>{
  'side': instance.side,
};
Car carFromJson(Map<String, dynamic> json) {
  return Car(((json['seats'] as num).toInt()));
}

Map<String, dynamic> carToMap(Car instance) => <String, dynamic>{
  'seats': instance.seats,
};
Bike bikeFromJson(Map<String, dynamic> json) {
  return Bike((json['hasPedals'] as bool));
}

Map<String, dynamic> bikeToMap(Bike instance) => <String, dynamic>{
  'hasPedals': instance.hasPedals,
};
AsymmetricModel asymmetricModelFromJson(Map<String, dynamic> json) {
  return AsymmetricModel((json['incoming_key'] as String));
}

Map<String, dynamic> asymmetricModelToMap(AsymmetricModel instance) =>
    <String, dynamic>{'outgoing_key': instance.key};
NullableConverterModel nullableConverterModelFromJson(
  Map<String, dynamic> json,
) {
  return NullableConverterModel(
    json['nullableConvertedInt'] == null
        ? null
        : const StringIntConverter().fromJson(json['nullableConvertedInt']),
  );
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
  return DeepCollectionsModel(
    (json['matrix'] as List<dynamic>)
        .map(
          (e) =>
              (e as List<dynamic>).map((e1) => ((e1 as num).toInt())).toList(),
        )
        .toList(),
    (json['mappedLists'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        k,
        (v as List<dynamic>).map((e1) => (e1 as String)).toList(),
      ),
    ),
  );
}

Map<String, dynamic> deepCollectionsModelToMap(DeepCollectionsModel instance) =>
    <String, dynamic>{
      'matrix': instance.matrix.map((e) => e).toList(),
      'mappedLists': instance.mappedLists.map((k, v) => MapEntry(k, v)),
    };
CaseStyledModel caseStyledModelFromJson(Map<String, dynamic> json) {
  return CaseStyledModel(
    (json['user_full_name'] as String),
    ((json['login_attempt_count'] as num).toInt()),
  );
}

Map<String, dynamic> caseStyledModelToMap(CaseStyledModel instance) =>
    <String, dynamic>{
      'user_full_name': instance.userFullName,
      'login_attempt_count': instance.loginAttemptCount,
    };
Shape shapeFromJson(Map<String, dynamic> json) {
  return switch (json['shape_type'] as String?) {
    'Circle' => circleFromJson(json),
    'Square' => squareFromJson(json),
    final unknown => throw FormatException(
      'Unknown Shape discriminator: $unknown',
    ),
  };
}

Map<String, dynamic> shapeToMap(Shape instance) {
  return switch (instance) {
    final Circle circle => circleToMap(circle)..['shape_type'] = 'Circle',
    final Square square => squareToMap(square)..['shape_type'] = 'Square',
  };
}

Vehicle vehicleFromJson(Map<String, dynamic> json) {
  return switch (json['vehicle_type'] as String?) {
    'car_v1' => carFromJson(json),
    'Bike' => bikeFromJson(json),
    final unknown => throw FormatException(
      'Unknown Vehicle discriminator: $unknown',
    ),
  };
}

Map<String, dynamic> vehicleToMap(Vehicle instance) {
  return switch (instance) {
    final Car car => carToMap(car)..['vehicle_type'] = 'car_v1',
    final Bike bike => bikeToMap(bike)..['vehicle_type'] = 'Bike',
  };
}
