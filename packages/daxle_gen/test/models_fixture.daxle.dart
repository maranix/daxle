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
Status statusFromValue(Object? value) => switch (value) {
  'pending' => Status.pending,
  'active' => Status.active,
  'completed' => Status.completed,
  _ => throw ArgumentError('Unknown Status value: $value'),
};
const priorityEnumMap = {
  Priority.low: 10,
  Priority.medium: 20,
  Priority.high: 30,
};
dynamic priorityToValue(Priority instance) => priorityEnumMap[instance]!;
Priority priorityFromValue(Object? value) => switch (value) {
  10 => Priority.low,
  20 => Priority.medium,
  30 => Priority.high,
  _ => throw ArgumentError('Unknown Priority value: $value'),
};
const multiParamEnumEnumMap = {
  MultiParamEnum.first: 101,
  MultiParamEnum.second: 202,
};
dynamic multiParamEnumToValue(MultiParamEnum instance) =>
    multiParamEnumEnumMap[instance]!;
MultiParamEnum multiParamEnumFromValue(Object? value) => switch (value) {
  101 => MultiParamEnum.first,
  202 => MultiParamEnum.second,
  _ => throw ArgumentError('Unknown MultiParamEnum value: $value'),
};
const themeModeEnumMap = {
  ThemeMode.lightTheme: 'light-theme',
  ThemeMode.darkTheme: 'dark-theme',
  ThemeMode.systemDefault: 'system-default',
};
dynamic themeModeToValue(ThemeMode instance) => themeModeEnumMap[instance]!;
ThemeMode themeModeFromValue(Object? value) => switch (value) {
  'light-theme' => ThemeMode.lightTheme,
  'dark-theme' => ThemeMode.darkTheme,
  'system-default' => ThemeMode.systemDefault,
  _ => throw ArgumentError('Unknown ThemeMode value: $value'),
};
const annotatedEnumEnumMap = {
  AnnotatedEnum.inProgress: 'in_progress',
  AnnotatedEnum.fallbackStatus: 'fallbackStatus',
};
dynamic annotatedEnumToValue(AnnotatedEnum instance) =>
    annotatedEnumEnumMap[instance]!;
AnnotatedEnum annotatedEnumFromValue(Object? value) => switch (value) {
  'in_progress' => AnnotatedEnum.inProgress,
  'internalSecret' => AnnotatedEnum.internalSecret,
  'fallbackStatus' => AnnotatedEnum.fallbackStatus,
  _ => AnnotatedEnum.fallbackStatus,
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
    _ => throw FormatException('Invalid JSON shape for ComplexModel: $json'),
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
NestedContainer nestedContainerFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'containerId': final String containerIdRaw, 'model': final Map modelRaw} =>
      NestedContainer(
        containerId: containerIdRaw,
        model: complexModelFromJson(modelRaw as Map<String, dynamic>),
        optionalModel: (json['optionalModel'] == null
            ? null
            : complexModelFromJson(
                json['optionalModel'] as Map<String, dynamic>,
              )),
      ),
    _ => throw FormatException('Invalid JSON shape for NestedContainer: $json'),
  };
}

Map<String, dynamic> nestedContainerToMap(NestedContainer instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'model': complexModelToMap(instance.model),
      if (instance.optionalModel != null)
        'optionalModel': complexModelToMap(instance.optionalModel!),
    };
Circle circleFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'radius': final num radiusRaw} => Circle(radiusRaw.toDouble()),
    _ => throw FormatException('Invalid JSON shape for Circle: $json'),
  };
}

Map<String, dynamic> circleToMap(Circle instance) => <String, dynamic>{
  'radius': instance.radius,
};
Square squareFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'side': final num sideRaw} => Square(sideRaw.toDouble()),
    _ => throw FormatException('Invalid JSON shape for Square: $json'),
  };
}

Map<String, dynamic> squareToMap(Square instance) => <String, dynamic>{
  'side': instance.side,
};
Car carFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'seats': final num seatsRaw} => Car(seatsRaw.toInt()),
    _ => throw FormatException('Invalid JSON shape for Car: $json'),
  };
}

Map<String, dynamic> carToMap(Car instance) => <String, dynamic>{
  'seats': instance.seats,
};
Bike bikeFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'hasPedals': final bool hasPedalsRaw} => Bike(hasPedalsRaw),
    _ => throw FormatException('Invalid JSON shape for Bike: $json'),
  };
}

Map<String, dynamic> bikeToMap(Bike instance) => <String, dynamic>{
  'hasPedals': instance.hasPedals,
};
AsymmetricModel asymmetricModelFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'incoming_key': final String keyRaw} => AsymmetricModel(keyRaw),
    _ => throw FormatException('Invalid JSON shape for AsymmetricModel: $json'),
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
    _ => throw FormatException(
      'Invalid JSON shape for DeepCollectionsModel: $json',
    ),
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
    _ => throw FormatException('Invalid JSON shape for CaseStyledModel: $json'),
  };
}

Map<String, dynamic> caseStyledModelToMap(CaseStyledModel instance) =>
    <String, dynamic>{
      'user_full_name': instance.userFullName,
      'login_attempt_count': instance.loginAttemptCount,
    };
Shape shapeFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'shape_type': 'Circle'} => circleFromJson(json),
    {'shape_type': 'Square'} => squareFromJson(json),
    _ => throw FormatException(
      'Unknown Shape discriminator: ${json['shape_type']}',
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
  return switch (json) {
    {'vehicle_type': 'car_v1'} => carFromJson(json),
    {'vehicle_type': 'Bike'} => bikeFromJson(json),
    _ => throw FormatException(
      'Unknown Vehicle discriminator: ${json['vehicle_type']}',
    ),
  };
}

Map<String, dynamic> vehicleToMap(Vehicle instance) {
  return switch (instance) {
    final Car car => carToMap(car)..['vehicle_type'] = 'car_v1',
    final Bike bike => bikeToMap(bike)..['vehicle_type'] = 'Bike',
  };
}
