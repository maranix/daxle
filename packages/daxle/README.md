# Daxle: High-Performance Data Modeling, Concurrency & Stream Transformation

[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![Pub Points](https://img.shields.io/pub/points/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Daxle is a lightweight, zero-overhead Dart 3+ toolkit providing zero-cost map querying (`QueryMap`), flexible sliding-window concurrency (`Concurrency`), deep collection equality, stream transformation operators, and declarative compile-time code generation annotations.

**[📚 Read the Official Documentation](https://daxle.maranix.in)**

---

## Core Capabilities

- **Zero-Cost Nested Map Traversal (`QueryMap`)**: Zero-overhead compile-time extension type over `Map` with dot notation, bracket indexing for embedded lists, and non-string key support. Safely returns `null` on missing paths or type mismatches without exceptions.
- **Sliding-Window Worker Pool (`Concurrency`)**: Manage asynchronous workload throughput using `.sequential`, `.unbounded`, or `.bounded(poolSize)` modes backed by `package:pool`, with early termination abort protection via `shouldStop`.
- **Resource Pooling (`Pool`)**: Re-exports `Pool` and `PoolResource` from `package:pool` for robust asynchronous throttling and resource management.
- **Deep Structural Equality (`$deepEquals`, `$deepHashCode`)**: Multi-tiered equality comparisons for nested maps, sets, lists, and records.
- **Stream Transformation Operators**: Re-exports all operators from `package:stream_transform` (`debounce`, `throttle`, `audit`, `buffer`, `combineLatest`, `merge`, `switchMap`, `scan`, `tap`, `whereType`).
- **Async Flow Utilities**: Re-exports key utilities from `package:async` (`FutureGroup`, `AsyncCache`, `AsyncMemoizer`, `StreamZip`, `StreamQueue`, `StreamGroup`, `StreamSplitter`).
- **Zero-Overhead Data Class Annotations**: Declarative annotations (`@serialize`, `@deserialize`, `@copyWith`, `@equalsAndHashCode`, `@stringify`, `@AnnotationBundle`) paired with `daxle_gen` in `dev_dependencies` for pure AST code generation.

---

## Installation

Add Daxle to your `pubspec.yaml`:

```yaml
dependencies:
  daxle: ^4.0.0

# Optional: Add daxle_gen to dev_dependencies for compile-time code generation
dev_dependencies:
  daxle_gen: ^0.3.0
```

Then run:

```bash
dart pub get
```

---

## Quick Tour

### 1. Safely Query Nested Maps & Embedded Lists (`QueryMap`)

Wrap any `Map` at zero runtime cost to query deeply nested properties, embedded lists, and multi-dimensional matrices using dot notation, bracket indexing, or key lists.

```dart
import 'package:daxle/daxle.dart';

void main() {
  final payload = {
    'services': {
      'server': {'host': 'https://api.internal', 'port': 8080},
      'database': null,
    },
    'users': [
      {'name': 'Alice', 'roles': ['admin', 'dev']},
    ],
    'matrix': [
      [10, 20],
      [30, 40],
    ],
    'cluster': {
      101: {'status': 'healthy'},
    },
  };

  final query = QueryMap(payload);

  // Dot notation for nested maps:
  final host = query.get<String>('services.server.host'); // 'https://api.internal'
  final port = query.get<int>('services.server.port'); // 8080

  // Bracket notation for embedded lists and matrices:
  final userName = query.get<String>('users[0].name'); // 'Alice'
  final firstRole = query.get<String>('users[0].roles[0]'); // 'admin'
  final matrixCell = query.get<int>('matrix[1][0]'); // 30

  // Key lists for non-string map keys:
  final status = query.get<String>(['cluster', 101, 'status']); // 'healthy'

  // Safe failure handling (no exceptions thrown):
  final wrongType = query.get<int>('services.server.host'); // null (value is a String)
  final outOfBounds = query.get<String>('users[99].name'); // null

  // Presence checking (distinguishes explicit null from missing keys):
  query.has('services.database'); // true (key exists with null value)
  query.has('services.cache'); // false (key does not exist)
}
```

### 2. Controlled Asynchronous Concurrency

Control worker limits and execute raw collections directly:

```dart
import 'package:daxle/daxle.dart';

void main() async {
  final urls = [
    'https://api.site.com/1',
    'https://api.site.com/2',
    'https://api.site.com/3',
    'https://api.site.com/4',
  ];

  // Process items concurrently with a sliding-window pool of 2 workers:
  final results = await const Concurrency.bounded(2).dispatch(
    urls,
    (url) async => httpGet(url),
    shouldStop: (response) => response.statusCode >= 500, // Early abort condition
  );
}
```

### 3. Stream Transformation Utilities

Manipulate, debounce, and interleave event streams with reactive operators from `package:stream_transform`:

```dart
import 'dart:async';
import 'package:daxle/daxle.dart';

void main() async {
  final searchController = StreamController<String>();

  // Debounce rapid user input events:
  final debounced = searchController.stream
      .debounce(const Duration(milliseconds: 300))
      .tap((query) => print('Querying: $query'));

  // Interleave multiple event streams concurrently:
  final streamA = Stream.fromIterable([1, 3, 5]);
  final streamB = Stream.fromIterable([2, 4, 6]);
  final merged = streamA.merge(streamB); // 1, 2, 3, 4, 5, 6

  // Switch map to automatically cancel stale asynchronous calls:
  final searchResults = debounced.switchMap((query) => executeSearch(query));
}
```

---

## Data Classes & Compile-Time Codegen (`daxle_gen`)

`daxle` provides zero-overhead compile-time annotations. When combined with [`daxle_gen`](https://pub.dev/packages/daxle_gen) in `dev_dependencies`, code generation synthesizes type-safe, functional serialization, deep immutable lenses, structural equality, and clean string representations.

### 1. Bundle Annotations with `AnnotationBundle`

Avoid repetitive annotation boilerplate by declaring named bundles:

```dart
import 'package:daxle/daxle.dart';

part 'user.daxle.dart';

const DataClass = AnnotationBundle([
  Serialize(),
  Deserialize(),
  CopyWith(),
  EqualsAndHashCode(),
  Stringify(),
]);

@DataClass
class User(
  @SerializedValue('user_id', aliases: ['id'])
  final String id,
  final String name,
  final Address address,
  @Fallback('member')
  final String role,
  @ignore
  final String internalCache,
) with _$User;
```

Generate code with:

```bash
dart run daxle:generate
```

### 2. Deep & Proxied `copyWith`

Generated `$ClassNameCopyWithProxy` lenses allow updating deeply nested hierarchies with natural dot notation while returning the newly constructed root object:

```dart
final user = User(
  id: 'u_1',
  name: 'Alice',
  address: Address(street: '100 Main St', city: 'Old Town'),
);

// Fluent deep mutation returning root User:
final updatedUser = user.copyWith.address(city: 'New Town');

print(updatedUser.address.city); // 'New Town'
print(updatedUser.address.street); // '100 Main St' (preserved)
```

### 3. Sealed Class Polymorphism

Polymorphic hierarchies serialize and deserialize cleanly using Dart 3 pattern matching switches with default (`'type'`) or custom discriminators:

```dart
@Serialize(discriminator: 'event_type')
@Deserialize(discriminator: 'event_type')
sealed class Event {}

@SerializedValue('auth.login')
class LoginEvent(final String userId) implements Event;

@SerializedValue('auth.logout')
class LogoutEvent() implements Event;
```

Generated switch pattern in `event.daxle.dart`:

```dart
Event eventFromMap(Map<String, dynamic> json) => switch (json) {
  {'event_type': 'auth.login'} => loginEventFromMap(json),
  {'event_type': 'auth.logout'} => logoutEventFromMap(json),
  _ => () {
    if (!json.containsKey('event_type')) {
      throw FormatException("Missing required discriminator 'event_type' for Event", json);
    }
    throw FormatException("Unknown Event discriminator: '${json['event_type']}'", json);
  }(),
};
```

---

## Contributing

Contributions are welcome! Please see the [monorepo workspace](https://github.com/maranix/daxle) for guidelines.

## License

Released under the [MIT License](LICENSE).