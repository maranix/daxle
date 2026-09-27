import 'package:daxle/daxle.dart';

part 'models_fixture.daxle.dart';

// 1. Enums
@serializeEnum
@deserializeEnum
@stringify
enum Status with _$StatusStringify { pending, active, completed }

@SerializeEnum(valueField: 'code')
@DeserializeEnum(valueField: 'code')
enum const Priority(final int code) {
  low(10),
  medium(20),
  high(30),
}

// 2. Custom converter
class const EpochDateTimeConverter()
    implements DaxleJsonConverter<DateTime, int> {
  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

// 3. Primary constructor model
@serialize
@deserialize
@equalsAndHashCode
@stringify
@copyWith
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
  @Fallback('guest') final String role = 'guest',
  @ignore final String secretToken = '',
  @SerializedValue('customEpoch', converter: EpochDateTimeConverter())
  final DateTime? customEpoch,
}) with _$ComplexModel;

// 4. Legacy class declaration with nested models
@serialize
@deserialize
@equalsAndHashCode
@stringify
@copyWith
class NestedContainer with _$NestedContainer {
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

@SerializedValue('car_v1')
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
  second('second_label', 202),
}

// 8. Custom JSON key mapping via @SerializedValue
@serialize
@deserialize
class CustomKeyModel(
  @SerializedValue('wire_key') final String key,
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
  @SerializedValue('nullableConvertedInt', converter: StringIntConverter())
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
@EqualsAndHashCode(ignoreFields: ['internalSecret'])
@Stringify(ignoreFields: ['internalSecret'])
@CopyWith(ignoreFields: ['internalSecret'])
class CaseStyledModel(
  final String userFullName,
  final int loginAttemptCount, {
  final String internalSecret = 'secret',
}) with _$CaseStyledModel;

// 12. CaseStyle on enum
@SerializeEnum(caseStyle: CaseStyle.kebabCase)
@DeserializeEnum(caseStyle: CaseStyle.kebabCase)
enum ThemeMode { lightTheme, darkTheme, systemDefault }

// 13. Enum entries annotated with @SerializeValue and @DeserializeValue
@serializeEnum
@deserializeEnum
enum AnnotatedEnum {
  @SerializedValue('in_progress')
  inProgress,

  @ignore
  internalSecret,

  @SerializedValue('archived_val')
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

// 15. Single feature models
@equalsAndHashCode
class EqualsOnlyModel(
  final String id,
  final int value,
) with _$EqualsOnlyModelEqualsAndHashCode;

@stringify
class StringifyOnlyModel(
  final String title,
) with _$StringifyOnlyModelStringify;

// 16. Large model with > 20 fields for testing nested Object.hash
@equalsAndHashCode
@stringify
@copyWith
class LargeModel(
  final int f1,
  final int f2,
  final int f3,
  final int f4,
  final int f5,
  final int f6,
  final int f7,
  final int f8,
  final int f9,
  final int f10,
  final int f11,
  final int f12,
  final int f13,
  final int f14,
  final int f15,
  final int f16,
  final int f17,
  final int f18,
  final int f19,
  final int f20,
  final int f21,
  final int f22,
) with _$LargeModel;

// 17. Reference usage: @Fallback on enum, @SerializedValue, @Fallback, @ignore on class
@Fallback(AccountType.standard)
@serializeEnum
@deserializeEnum
@stringify
enum AccountType with _$AccountTypeStringify {
  @SerializedValue('std')
  standard,

  @SerializedValue('prem')
  premium,

  // UI/client-only state; excluded from serialization and mapping
  @ignore
  internalTest,
}

@serialize
@deserialize
@equalsAndHashCode
@stringify
@copyWith
class Account with _$Account {
  final String id;

  @SerializedValue('acc_type')
  final AccountType type;

  @Fallback(0)
  final int loginCount;

  // Transient state; omitted from all generated methods and JSON logic
  @ignore
  final Stopwatch sessionTimer;

  Account({
    required this.id,
    required this.type,
    this.loginCount = 0,
    required this.sessionTimer,
  });
}

// 18. Reference Usage: PaymentStatus (aliases), Address, Order (@Flatten, aliases, dynamic null handling)
@serializeEnum
@deserializeEnum
@stringify
enum PaymentStatus with _$PaymentStatusStringify {
  @SerializedValue(
    'pay_pending',
    aliases: ['pending', 'PAY_PENDING', 'in_progress'],
  )
  pending,

  @SerializedValue('pay_success', aliases: ['success', 'completed'])
  success,

  @SerializedValue('pay_failed', aliases: ['failed', 'error'])
  failed,
}

@serialize
@deserialize
@equalsAndHashCode
@stringify
@copyWith
class Address with _$Address {
  final String street;
  final String? apt;
  final String city;

  Address({required this.street, this.apt, required this.city});

  factory Address.fromMap(Map<String, dynamic> map) => addressFromMap(map);
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      addressToMap(this, excludeNull: excludeNull);
}

@serialize
@deserialize
@equalsAndHashCode
@stringify
@copyWith
class Order with _$Order {
  final String id;

  @SerializedValue('order_status', aliases: ['status', 'state'])
  final PaymentStatus status;

  final String? notes;

  @Flatten(prefix: 'shipping_')
  final Address shippingAddress;

  Order({
    required this.id,
    required this.status,
    this.notes,
    required this.shippingAddress,
  });

  factory Order.fromMap(Map<String, dynamic> map) => orderFromMap(map);
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      orderToMap(this, excludeNull: excludeNull);
}

// 19. Extension Types
@serialize
@deserialize
extension type UserId(String id) {}

@serialize
@deserialize
extension type Score(int value) {}

@serialize
@deserialize
class UserProfile(
  final UserId id,
  final Score score,
  final UserId? backupId,
);
