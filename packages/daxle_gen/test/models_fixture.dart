import 'package:daxle/daxle.dart';

part 'models_fixture.daxle.dart';

// 1. Enums
@serialize
@deserialize
enum Status { pending, active, completed }

@serialize
@deserialize
@Serialize(valueField: 'code')
@Deserialize(valueField: 'code')
enum Priority {
  low(10),
  medium(20),
  high(30);

  const Priority(this.code);
  final int code;
}

// 2. Custom converter
class EpochDateTimeConverter implements DaxleJsonConverter<DateTime, int> {
  const EpochDateTimeConverter();

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
  @SerializeValue(defaultValue: 'guest')
  @DeserializeValue(defaultValue: 'guest')
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
@serialize
@deserialize
@Serialize(valueField: 'code')
@Deserialize(valueField: 'code')
enum MultiParamEnum {
  first('first_label', 101),
  second('second_label', 202);

  const MultiParamEnum(this.label, this.code);
  final String label;
  final int code;
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
class StringIntConverter implements DaxleJsonConverter<int, String> {
  const StringIntConverter();
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

