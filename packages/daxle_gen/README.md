# Daxle Code Generator (`daxle_gen`)

Compile-time functional serialization and deserialization generator for Dart 3+.

[![Pub Version](https://img.shields.io/pub/v/daxle_gen.svg)](https://pub.dev/packages/daxle_gen)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

`daxle_gen` provides functional, type-safe serialization (`toMap`) and deserialization (`fromJson`) code generation designed specifically for Dart 3 pattern matching and primary constructors.

---

## Features

- **Primary Constructors & Classes**: Generates top-level `<camelCase>FromJson` and `<camelCase>ToMap` functions using Dart 3 switch pattern matching.
- **Enums**: Generates private lookup maps (`const _<enum>EnumMap`), `<enum>ToValue`, and pattern matching `<enum>FromValue` with entry-level overrides and fallbacks.
- **Sealed Class Polymorphism**: Supports both default (`'type'`) and custom discriminators with customizable subclass tags.
- **Accurate Error Reporting**: `FormatException` identifies the specific missing or invalid field, expected type, and actual runtime type, passing `json` to the SDK `source` parameter.
- **Dual Execution Modes**:
  1. **Native Assets Build Hook (`hook/build.dart`)**: Zero-drift compilation hook that generates `.daxle.dart` files on compile/test.
  2. **CLI Runner**: `dart run daxle_gen generate` (or `dart run daxle:generate`) with `--watch`, `--filter`, `--check`, and SHA-256 caching.

---

## Discriminator Comparison: Default vs Custom

Daxle supports polymorphic serialization for sealed class hierarchies with either zero-configuration defaults or fine-grained customization.

### 1. Default Discriminator (`@Serialize()` / `@Deserialize()`)

When `@Serialize()` or `@Deserialize()` (or shorthand `@serialize` / `@deserialize`) is applied without arguments:
- The discriminator key defaults to `'type'`.
- Subclass tags default to the respective class name.

#### Input Definition:
```dart
import 'package:daxle/daxle.dart';

part 'event.daxle.dart';

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
```

#### Generated Switch Code (`event.daxle.dart`):
```dart
part of 'event.dart';

Event eventFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'type': 'LoginEvent'} => loginEventFromJson(json),
    {'type': 'LogoutEvent'} => logoutEventFromJson(json),
    _ => () {
      if (!json.containsKey('type') || json['type'] == null) {
        throw FormatException("Missing required discriminator 'type' for Event", json);
      }
      throw FormatException("Unknown Event discriminator: '${json['type']}'", json);
    }(),
  };
}

Map<String, dynamic> eventToMap(Event instance) {
  return switch (instance) {
    final LoginEvent loginEvent => loginEventToMap(loginEvent)..['type'] = 'LoginEvent',
    final LogoutEvent logoutEvent => logoutEventToMap(logoutEvent)..['type'] = 'LogoutEvent',
  };
}
```

---

### 2. Custom Discriminator & Custom Tags (`@Serialize(discriminator: ...)` + `@SerializeValue(name: ...)`)

When specifying a custom discriminator key and custom subclass tags:
- The discriminator key matches the specified string (e.g., `'vehicle_type'`).
- Subclasses annotated with `@SerializeValue(name: '...')` / `@DeserializeValue(name: '...')` use the explicit tag.
- Subclasses without tag annotations fall back to their class name.

#### Input Definition:
```dart
import 'package:daxle/daxle.dart';

part 'vehicle.daxle.dart';

@Serialize(discriminator: 'vehicle_type')
@Deserialize(discriminator: 'vehicle_type')
sealed class Vehicle {}

@SerializeValue(name: 'car_v1')
@DeserializeValue(name: 'car_v1')
class Car implements Vehicle {
  final int seats;
  Car(this.seats);
}

class Bike implements Vehicle {
  final bool hasPedals;
  Bike(this.hasPedals);
}
```

#### Generated Switch Code (`vehicle.daxle.dart`):
```dart
part of 'vehicle.dart';

Vehicle vehicleFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {'vehicle_type': 'car_v1'} => carFromJson(json),
    {'vehicle_type': 'Bike'} => bikeFromJson(json),
    _ => () {
      if (!json.containsKey('vehicle_type') || json['vehicle_type'] == null) {
        throw FormatException("Missing required discriminator 'vehicle_type' for Vehicle", json);
      }
      throw FormatException("Unknown Vehicle discriminator: '${json['vehicle_type']}'", json);
    }(),
  };
}

Map<String, dynamic> vehicleToMap(Vehicle instance) {
  return switch (instance) {
    final Car car => carToMap(car)..['vehicle_type'] = 'car_v1',
    final Bike bike => bikeToMap(bike)..['vehicle_type'] = 'Bike',
  };
}
```

---

### Side-by-Side Comparison

| Feature | Default Discriminator | Custom Discriminator & Tag |
| :--- | :--- | :--- |
| **Sealed Annotation** | `@serialize` / `@Serialize()` | `@Serialize(discriminator: 'vehicle_type')` |
| **JSON Discriminator Key** | `'type'` | `'vehicle_type'` |
| **Subclass Tag (Car)** | `'Car'` (class name) | `'car_v1'` (via `@SerializeValue(name: 'car_v1')`) |
| **Subclass Tag (Bike)** | `'Bike'` (class name) | `'Bike'` (unannotated fallback to class name) |
| **Missing Discriminator Error** | `"Missing required discriminator 'type' for Event"` | `"Missing required discriminator 'vehicle_type' for Vehicle"` |
| **Unknown Tag Error** | `"Unknown Event discriminator: '<val>'"` | `"Unknown Vehicle discriminator: '<val>'"` |
| **`FormatException.source`** | Passes input `json` map | Passes input `json` map |
