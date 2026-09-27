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
  AnnotatedEnum.fallbackStatus: 'fallbackStatus',
};
dynamic annotatedEnumToValue(AnnotatedEnum instance) =>
    _annotatedEnumEnumMap[instance]!;
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
    _ => () {
      if (!json.containsKey('id') || json['id'] == null) {
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
      if (!json.containsKey('count') || json['count'] == null) {
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
      if (!json.containsKey('rating') || json['rating'] == null) {
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
      if (!json.containsKey('isActive') || json['isActive'] == null) {
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
      if (!json.containsKey('createdAt') || json['createdAt'] == null) {
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
      if (!json.containsKey('website') || json['website'] == null) {
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
      if (!json.containsKey('score') || json['score'] == null) {
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
      if (!json.containsKey('timeout') || json['timeout'] == null) {
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
      if (!json.containsKey('metadata') || json['metadata'] == null) {
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
      if (!json.containsKey('tags') || json['tags'] == null) {
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
      if (!json.containsKey('numbers') || json['numbers'] == null) {
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
      if (!json.containsKey('scores') || json['scores'] == null) {
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
      if (!json.containsKey('status') || json['status'] == null) {
        throw FormatException(
          "Missing required field 'status' for ComplexModel",
          json,
        );
      }
      if (!json.containsKey('priority') || json['priority'] == null) {
        throw FormatException(
          "Missing required field 'priority' for ComplexModel",
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
    _ => () {
      if (!json.containsKey('containerId') || json['containerId'] == null) {
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
      if (!json.containsKey('model') || json['model'] == null) {
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
Circle circleFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'radius': final num radiusRaw} => Circle(radiusRaw.toDouble()),
    _ => () {
      if (!json.containsKey('radius') || json['radius'] == null) {
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
      if (!json.containsKey('side') || json['side'] == null) {
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
      if (!json.containsKey('seats') || json['seats'] == null) {
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
      if (!json.containsKey('hasPedals') || json['hasPedals'] == null) {
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
      if (!json.containsKey('incoming_key') || json['incoming_key'] == null) {
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
      if (!json.containsKey('matrix') || json['matrix'] == null) {
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
      if (!json.containsKey('mappedLists') || json['mappedLists'] == null) {
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
      if (!json.containsKey('user_full_name') ||
          json['user_full_name'] == null) {
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
      if (!json.containsKey('login_attempt_count') ||
          json['login_attempt_count'] == null) {
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
LoginEvent loginEventFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'userId': final String userIdRaw} => LoginEvent(userIdRaw),
    _ => () {
      if (!json.containsKey('userId') || json['userId'] == null) {
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
Shape shapeFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'shape_type': 'Circle'} => circleFromJson(json),
    {'shape_type': 'Square'} => squareFromJson(json),
    _ => () {
      if (!json.containsKey('shape_type') || json['shape_type'] == null) {
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
      if (!json.containsKey('vehicle_type') || json['vehicle_type'] == null) {
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
      if (!json.containsKey('type') || json['type'] == null) {
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
