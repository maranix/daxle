# Daxle Code Generator (`daxle_gen`)

Compile-time functional code generator and AST inspection pipeline for Dart 3+.

[![Pub Version](https://img.shields.io/pub/v/daxle_gen.svg)](https://pub.dev/packages/daxle_gen)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Dart SDK](https://img.shields.io/badge/Dart-3.13+-0175C2.svg)](https://dart.dev)

`daxle_gen` provides pure, deterministic, and type-safe code generation targeting modern Dart 3 features: primary constructors, switch pattern matching, record types, extension types, and sealed class hierarchies. It generates top-level functional serialization (`toMap`, `fromMap`, `toList`, `fromList`), deep proxied immutable update lenses (`copyWith`, `copyWithNull`), tiered structural value equality (`operator ==`, `hashCode`), and clean string formatting (`toString`).

---

## Table of Contents

- [Features](#features)
- [Installation & Setup](#installation--setup)
- [Execution Workflows](#execution-workflows)
  - [CLI Runner](#1-cli-runner)
  - [CLI Flags & Options](#cli-flags--options)
  - [Native Assets Build Hook](#2-native-assets-build-hook)
- [Core Capabilities](#core-capabilities)
  - [1. Primary Constructors & Data Classes](#1-primary-constructors--data-classes)
  - [2. Dart 3 Record Types](#2-dart-3-record-types)
  - [3. Deep & Proxied `copyWith`](#3-deep--proxied-copywith)
  - [4. Structural Equality & HashCode](#4-structural-equality--hashcode)
  - [5. Stringify](#5-stringify)
  - [6. Composite Annotations (`AnnotationBundle`)](#6-composite-annotations-annotationbundle)
  - [7. Member & Field Annotations](#7-member--field-annotations)
  - [8. Sealed Class Polymorphism](#8-sealed-class-polymorphism)
  - [9. Extension Types](#9-extension-types)
  - [10. Part-File Support](#10-part-file-support)
- [Error Diagnostics & Fail-Fast Guarantees](#error-diagnostics--fail-fast-guarantees)
- [Architecture & Design](#architecture--design)
- [License](#license)

---

## Features

- **Primary Constructor First**: Full syntax support for Dart 3 concise parameter declarations (`class User(final String id, final String name);`).
- **Functional Serialization**: Pure, standalone functions (`<name>FromMap`, `<name>ToMap`) and zero-cost extension methods.
- **Dart 3 Records**: Comprehensive serialization and deserialization for positional `(int, String)` and named `({String name, int age})` records with standalone helper functions and extensions.
- **Deep Proxied `copyWith`**: Fluent nested updates (`user.copyWith.address.city(name: 'NYC')`) returning the root type, identity checks avoiding redundant allocations, and explicit nullification (`copyWithNull`).
- **Collection-Aware Deep Equality**: Tiered structural equality sorting cheap primitives first, nested objects second, and deep collections (`$listEquals`, `$setEquals`, `$mapEquals`, `$deepEquals`) last.
- **Clean `toString` Mixins**: Readable string representations for classes and enums.
- **Annotation Bundling**: Group multiple annotations into reusable constants via `AnnotationBundle` (e.g. `@DataClass`).
- **Granular Member Control**: Field renaming, backwards-compatible wire aliases, default value fallback injection, nested map flattening, and field exclusion.
- **Sealed Class Polymorphism**: Automatic switch dispatch with default (`'type'`) or custom discriminators and subclass tags.
- **High-Performance AST Tooling**: Analyzes syntax trees with `DaxleFileVisitor` without running slow builder cascades, featuring SHA-256 incremental caching and debounced watching.

---

## Installation & Setup

Add `daxle` and `daxle_gen` to your `pubspec.yaml`:

```yaml
dependencies:
  daxle: ^4.0.0

dev_dependencies:
  daxle_gen: ^0.3.0
```

In any source file where generation is required, declare the generated part file:

```dart
import 'package:daxle/daxle.dart';

part 'user.daxle.dart';

@serialize
@deserialize
@copyWith
@equalsAndHashCode
@stringify
class User(
  final String id,
  final String name,
  final Address? address,
);
```

---

## Execution Workflows

### 1. CLI Runner

Run the generator directly using the Dart tool:

```sh
# Generate all .daxle.dart part files in the project
dart run daxle_gen generate

# Or use the concise package executable shortcut
dart run daxle:generate
```

### CLI Flags & Options

| Flag | Short | Description |
| :--- | :--- | :--- |
| `--watch` | `-w` | Watches the filesystem for `.dart` file modifications and regenerates code incrementally with automated cache invalidation. |
| `--filter` | `-f` | Evaluates glob patterns to include or exclude files (e.g., `-f "lib/models/**"` or `-f "!lib/generated/**"`). |
| `--clean` | `-c` | Removes all generated `.daxle.dart` files registered in `.dart_tool/daxle_gen/manifest.json`. |
| `--force` | | Bypasses the SHA-256 fingerprint cache and forces regeneration of every file. |
| `--check` | | Validates whether generated files on disk are up-to-date without modifying them (returns exit code `1` on drift; recommended for CI). |
| `--verbose` | `-v` | Emits granular processing times and cache hit/miss statistics. |
| `--help` | `-h` | Prints available command options and usage guidance. |

```sh
# Watch with glob filters
dart run daxle_gen generate lib/ -w -f "lib/domain/**"

# Verify in CI
dart run daxle_gen generate --check

# Force clean build
dart run daxle_gen generate --force
```

### 2. Native Assets Build Hook

`daxle_gen` can execute directly inside Dart's compilation lifecycle via `hook/build.dart`. When configured, code is generated automatically before `dart run`, `dart test`, or `flutter build`:

```dart
// hook/build.dart
import 'package:daxle_gen/daxle_gen.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await buildHook(args, (input, output) async {
    final generator = DaxleGenerator();
    await generator.run(targetPath: 'lib');
  });
}
```

---

## Core Capabilities

### 1. Primary Constructors & Data Classes

Annotate classes with `@Serialize()` and `@Deserialize()` (or shorthand `@serialize` / `@deserialize`):

```dart
part 'product.daxle.dart';

@serialize
@deserialize
class Product(
  final String id,
  final String title,
  final double price,
  final bool inStock,
);
```

#### Generated Top-Level Functions & Extensions:

```dart
// product.daxle.dart
part of 'product.dart';

Product productFromJson(Map<String, dynamic> json) => productFromMap(json);

Product productFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {
      'id': final String id,
      'title': final String title,
      'price': final num price,
      'inStock': final bool inStock,
    } => Product(id, title, price.toDouble(), inStock),
    _ => () {
      // Precise diagnostic checks for each field and runtime type...
    }(),
  };
}

Map<String, dynamic> productToMap(Product instance, {bool excludeNull = false}) {
  final map = <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
    'price': instance.price,
    'inStock': instance.inStock,
  };
  if (excludeNull) {
    map.removeWhere((_, value) => value == null);
  }
  return map;
}

extension ProductToMapExtension on Product {
  Map<String, dynamic> toMap({bool excludeNull = false}) =>
      productToMap(this, excludeNull: excludeNull);
}
```

---

### 2. Dart 3 Record Types

`daxle_gen` fully supports modern Dart record types, both as fields inside models and as standalone top-level typedefs.

#### Positional Records:
Positional records serialize as JSON arrays `[a, b]` and deserialize into type-safe tuples:

```dart
@serialize
@deserialize
typedef Coordinates = (double latitude, double longitude);
```

Generated API:
- `List<dynamic> coordinatesToList(Coordinates instance)`
- `Coordinates coordinatesFromList(List<dynamic> list)`
- Extension `instance.toList()` on `Coordinates`
- Extension `list.toCoordinates()` on `List<dynamic>`

#### Named Records:
Named records serialize as JSON key-value objects `{'x': a, 'y': b}`:

```dart
@serialize
@deserialize
typedef GridPosition = ({int x, int y, String? label});
```

Generated API:
- `Map<String, dynamic> gridPositionToMap(GridPosition instance)`
- `GridPosition gridPositionFromMap(Map<String, dynamic> map)`
- Extension `instance.toMap()` on `GridPosition`
- Extension `map.toGridPosition()` on `Map<String, dynamic>`

---

### 3. Deep & Proxied `copyWith`

Annotate any class with `@CopyWith()` or `@copyWith` to generate immutable mutation lenses.

When nested models are annotated with `@copyWith`, `daxle_gen` synthesizes typed proxy getters that allow chaining mutation calls directly down the object tree while returning a newly constructed root instance:

```dart
@copyWith
class Address(final String street, final String city);

@copyWith
class Company(final String name, final Address address);

@copyWith
class User(final String id, final Company company);
```

#### Fluent Deep Updates:

```dart
final user = User(
  'u_1',
  Company('Acme Corp', Address('100 Main St', 'Old Town')),
);

// Deep nested modification returning the root User:
final updatedUser = user.copyWith.company.address(city: 'New Town');

print(updatedUser.company.address.city); // New Town
print(updatedUser.company.name);         // Acme Corp (preserved)
```

#### Additional CopyWith Features:

- **Instance Reuse (Identity Checks)**: If arguments passed to `copyWith` evaluate to identical or equal values, the existing instance is reused without allocating new objects.
- **Explicit Nullification (`copyWithNull`)**:
  ```dart
  // Sets nullable fields to null:
  final cleared = user.copyWithNull(company: true);
  ```
- **Field Exclusion**: Exclude specific fields from copy methods via `@CopyWith(ignoreFields: ['id'])`.

---

### 4. Structural Equality & HashCode

Annotate classes with `@EqualsAndHashCode()` or `@equalsAndHashCode` to generate deep, collection-aware `operator ==` and `hashCode` implementations.

```dart
@equalsAndHashCode
class Order(
  final String id,
  final List<String> itemIds,
  final Map<String, double> tags,
) with _$OrderEqualsAndHashCode;
```

#### Performance Tier Sorting:
Fields are evaluated using a 3-tier precedence strategy to short-circuit comparisons as early as possible:
1. **Tier 0 (Cheap Primitives & Enums)**: `bool`, `int`, `double`, `String`, and enum comparisons run first.
2. **Tier 1 (Non-Collection Objects)**: `DateTime`, `Uri`, `Duration`, `BigInt`, and custom model checks run second.
3. **Tier 2 (Deep Collections)**: Nested `List`, `Set`, `Map`, and `QueryMap` structures run last via optimized collection equivalence helpers (`$listEquals`, `$setEquals`, `$mapEquals`, `$deepEquals`).

When a class defines more than 20 fields, `daxle_gen` automatically splits hashing across nested `Object.hash` invocations to adhere to SDK limits.

---

### 5. Stringify

Annotate classes or enums with `@Stringify()` or `@stringify` to generate clean, readable `toString()` implementations:

```dart
@stringify
class Person(final String name, final int age) with _$PersonStringify;

@stringify
enum Status { pending, active, completed }
```

```dart
print(Person('Alice', 30).toString()); // Person(name: Alice, age: 30)
print(Status.active.toString());       // Status.active
```

> **Consolidated Mixin**: When applying both `@equalsAndHashCode` and `@stringify`, mix in `_$ClassName` to inherit both implementations together:
> ```dart
> class User(final String name) with _$User;
> ```

---

### 6. Composite Annotations (`AnnotationBundle`)

Define reusable annotation bundles using `AnnotationBundle` to keep domain definitions concise and standard across your codebase:

```dart
import 'package:daxle/daxle.dart';

const DataClass = AnnotationBundle([
  Serialize(),
  Deserialize(),
  CopyWith(),
  EqualsAndHashCode(),
  Stringify(),
]);

@DataClass
class Customer(
  final String id,
  final String email,
) with _$Customer;
```

`daxle_gen` expands `AnnotationBundle` constants at compile time while preserving any individual parameter configurations.

---

### 7. Member & Field Annotations

Fine-tune serialization and model behavior using member-level annotations:

| Annotation | Placement | Description |
| :--- | :--- | :--- |
| `@SerializedValue('wire_key', {aliases, converter})` | Field / Enum | Overrides JSON key name, defines fallback wire aliases, or binds a custom `DaxleJsonConverter`. |
| `@Fallback(value)` | Field / Enum | Injects a default value when incoming JSON is null/missing, or designates the fallback case for unrecognized enum values. |
| `@Flatten({prefix})` | Field | Inlines nested object fields directly into the parent JSON map, with an optional key prefix. |
| `@Ignore()` / `@ignore` | Field / Enum | Completely strips the member from serialization, deserialization, equality, hashCode, copyWith, and stringify. |

#### Comprehensive Member Example:

```dart
@Serialize(caseStyle: CaseStyle.snakeCase)
@Deserialize(caseStyle: CaseStyle.snakeCase)
class Account(
  // Custom wire key and backwards-compatible aliases
  @SerializedValue('acc_id', aliases: ['id', 'account_number'])
  final String accountId,

  // Fallback default value if null or missing
  @Fallback('standard')
  final String plan,

  // Inlined fields: address.street -> street, address.city -> city
  @flatten
  final Address address,

  // Excluded completely from all generated code
  @ignore
  final String internalCache,
);
```

#### Enums with CaseStyle and Fallbacks:

```dart
@Serialize(caseStyle: CaseStyle.kebabCase)
@Deserialize(caseStyle: CaseStyle.kebabCase)
@Fallback(AccountStatus.unknown)
enum AccountStatus {
  active,
  suspended,
  @SerializedValue('pending-verification')
  pending,
  unknown,
}
```

---

### 8. Sealed Class Polymorphism

`daxle_gen` generates exhaustive switch expressions for polymorphic sealed class hierarchies.

#### Default Discriminator:
By default, `@serialize` and `@deserialize` use `'type'` as the discriminator key and class names as tags:

```dart
@serialize
@deserialize
sealed class Event {}

class LoginEvent(final String userId) extends Event;
class LogoutEvent() extends Event;
```

#### Custom Discriminators & Subclass Tags:
Specify custom discriminator keys and explicit subclass tag identifiers:

```dart
@Serialize(discriminator: 'event_type')
@Deserialize(discriminator: 'event_type')
sealed class NetworkEvent {}

@SerializedValue('auth.login')
class AuthLoginEvent(final String token) implements NetworkEvent;

@SerializedValue('auth.logout')
class AuthLogoutEvent() implements NetworkEvent;
```

#### Generated Sealed Switch (`event.daxle.dart`):

```dart
NetworkEvent networkEventFromMap(Map<String, dynamic> json) {
  return switch (json) {
    {'event_type': 'auth.login'} => authLoginEventFromMap(json),
    {'event_type': 'auth.logout'} => authLogoutEventFromMap(json),
    _ => () {
      if (!json.containsKey('event_type')) {
        throw FormatException("Missing required discriminator 'event_type' for NetworkEvent", json);
      }
      throw FormatException("Unknown NetworkEvent discriminator: '${json['event_type']}'", json);
    }(),
  };
}
```

---

### 9. Extension Types

`daxle_gen` seamlessly generates serialization helpers for modern Dart 3 `extension type` declarations:

```dart
@serialize
@deserialize
extension type UserId(String value);
```

Generated helpers allow transparent conversion between the underlying representation and the typed abstraction:
- `UserId userIdFromMap(dynamic value)`
- `String userIdToMap(UserId instance)`

---

### 10. Part-File Support

Daxle automatically handles complex project structures where annotated models are defined inside part files:

```
bloc/
├── auth_bloc.dart        → part 'auth_state.dart'; part 'auth_bloc.daxle.dart';
├── auth_state.dart       → part of 'auth_bloc.dart';
```

When `auth_state.dart` is annotated, `daxle_gen` traverses up to the owning library root (`auth_bloc.dart`) and correctly generates `auth_bloc.daxle.dart` attached to the primary library.

---

## Error Diagnostics & Fail-Fast Guarantees

`daxle_gen` prioritizes actionable, clear error diagnostics. When deserialization encounters missing required fields, incompatible types, or missing discriminators, it throws a detailed `FormatException` and passes the offending payload directly to `FormatException.source`:

```
FormatException: Missing required field 'price' for Product
Source: {"id": "p_1", "title": "Desk"}
```

```
FormatException: Invalid type for 'price' on Product. Expected double, got String ('free')
Source: {"id": "p_1", "title": "Desk", "price": "free"}
```

---

## Architecture & Design

`daxle_gen` is built using a clean, layered AST visitor pipeline:

```
Source .dart File
       │
       ▼
 [DaxleAstParser] ──── Uses analyzer's parseString (lightweight, no build_runner)
       │
       ▼
[DaxleFileVisitor] ── Specialized RecursiveAstVisitor extracting declarations
       │
       ▼
[AnnotationRegistry] ─ Modular handlers (Serialize, Deserialize, CopyWith, etc.)
       │
       ▼
 [FileGenerator] ──── Synthesizes specs via code_builder & formats via dart_style
       │
       ▼
Generated .daxle.dart Part File
```

- **Zero Heavy Build Step**: Bypasses slow code generator frameworks (`build_runner`) by reading ASTs directly with `package:analyzer`.
- **Content-Addressed Caching**: Computes SHA-256 digests over source contents and generator version to skip unmutated files in sub-millisecond times.
- **Reactive Watcher**: In-memory debounced file watcher that invalidates modified compilation units instantaneously.

---

## License

`daxle_gen` is distributed under the terms of the [MIT License](LICENSE).
