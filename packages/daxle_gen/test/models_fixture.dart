import 'package:daxle/daxle.dart';

part 'models_fixture.daxle.dart';

// 1. Enums
@serializeEnum
@deserializeEnum
enum Status { pending, active, completed }

@SerializeEnum(valueField: 'code')
@DeserializeEnum(valueField: 'code')
enum const Priority(final int code) {
  low(10),
  medium(20),
  high(30);
}

// 2. Custom converter
class const EpochDateTimeConverter() implements DaxleJsonConverter<DateTime, int> {
  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

// 3. Primary constructor model
@serialize
@deserialize
class ComplexModel(
  final String id,
  final int count,
  final double rating,
  final bool isActive,
  final DateTime createdAt,
  final Uri website,
  final BigInt score,
  final Duration timeout,
  final Option<String> optionalTag,
  final QueryMap metadata,
  final List<String> tags,
  final Set<int> numbers,
  final Map<String, int> scores,
  final Status status,
  final Priority priority, {
  @SerializeValue(fallback: 'guest')
  @DeserializeValue(fallback: 'guest')
  final String role = 'guest',
  @SerializeValue(ignore: true)
  @DeserializeValue(ignore: true)
  final String secretToken = '',
  @SerializeValue(converter: EpochDateTimeConverter())
  @DeserializeValue(converter: EpochDateTimeConverter())
  final DateTime? customEpoch,
});

// 4. Legacy class declaration with nested models
@serialize
@deserialize
class NestedContainer {
  final String containerId;
  final ComplexModel model;
  final ComplexModel? optionalModel;

  const NestedContainer({
    required this.containerId,
    required this.model,
    this.optionalModel,
  });
}

// 5. Sealed class hierarchy
@Serialize(discriminator: 'shape_type')
@Deserialize(discriminator: 'shape_type')
sealed class Shape {}

class Circle extends Shape {
  final double radius;
  Circle(this.radius);
}

class Square extends Shape {
  final double side;
  Square(this.side);
}

// 6. Sealed hierarchy with implements and custom discriminator tag
@Serialize(discriminator: 'vehicle_type')
@Deserialize(discriminator: 'vehicle_type')
sealed class Vehicle {}

@SerializeValue(name: 'car_v1')
class Car implements Vehicle {
  final int seats;
  Car(this.seats);
}

class Bike implements Vehicle {
  final bool hasPedals;
  Bike(this.hasPedals);
}

// 7. Enhanced enum with multiple positional constructor parameters
@SerializeEnum(valueField: 'code')
@DeserializeEnum(valueField: 'code')
enum const MultiParamEnum(final String label, final int code) {
  first('first_label', 101),
  second('second_label', 202);
}

// 8. Asymmetric JSON key mapping
@serialize
@deserialize
class AsymmetricModel(
  @SerializeValue(name: 'outgoing_key')
  @DeserializeValue(name: 'incoming_key')
  final String key,
);

// 9. Nullable primitive with custom converter
class const StringIntConverter() implements DaxleJsonConverter<int, String> {
  @override
  int fromJson(String json) => int.parse(json);
  @override
  String toJson(int object) => object.toString();
}

@serialize
@deserialize
class NullableConverterModel(
  @SerializeValue(converter: StringIntConverter())
  @DeserializeValue(converter: StringIntConverter())
  final int? nullableConvertedInt,
);

// 10. Deep collections
@serialize
@deserialize
class DeepCollectionsModel(
  final List<List<int>> matrix,
  final Map<String, List<String>> mappedLists,
);

// 11. CaseStyle and ignoreFields on class
@Serialize(caseStyle: CaseStyle.snakeCase, ignoreFields: ['internalSecret'])
@Deserialize(caseStyle: CaseStyle.snakeCase, ignoreFields: ['internalSecret'])
class CaseStyledModel(
  final String userFullName,
  final int loginAttemptCount, {
  final String internalSecret = 'secret',
});

// 12. CaseStyle on enum
@SerializeEnum(caseStyle: CaseStyle.kebabCase)
@DeserializeEnum(caseStyle: CaseStyle.kebabCase)
enum ThemeMode { lightTheme, darkTheme, systemDefault }

// 13. Enum entries annotated with @SerializeValue and @DeserializeValue
@serializeEnum
@deserializeEnum
enum AnnotatedEnum {
  @SerializeValue(name: 'in_progress')
  @DeserializeValue(name: 'in_progress')
  inProgress,

  @SerializeValue(ignore: true)
  internalSecret,

  @SerializeValue(fallback: 'archived_val')
  @DeserializeValue(fallback: 'archived_val')
  archived,
}

// 14. Sealed hierarchy with default discriminator ('type' and class name tags)
@serialize
@deserialize
sealed class Event {}

class LoginEvent extends Event {
  final String userId;
  LoginEvent(this.userId);
}

class LogoutEvent extends Event {
  LogoutEvent();
}

