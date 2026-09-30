# Daxle: Write Safer, Predictable Dart Code

[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![Pub Points](https://img.shields.io/pub/points/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Stop writing nested try/catch blocks and imperative state checks. Daxle is a lightweight, type-safe functional programming toolkit and compile-time annotation suite that helps you build predictable, composable Dart applications.

**[📚 Read the Official Documentation](https://daxle.maranix.in)**

---

## Why Daxle?

Dart's type system is great, but runtime exceptions, missing values, and complex asynchronous workflows can still lead to unpredictable bugs. Daxle gives you explicit, declarative types to handle missing values and errors gracefully at compile time.

### Stop Guessing What Can Fail
Instead of throwing untyped exceptions that might crash your app in production, use `Either<L, R>` to make failures an explicit part of your function signatures. The compiler enforces that you handle both success and error states.

### Compose Values with Option
While Dart's null safety is excellent, `Option<T extends Object>` takes it further by allowing you to chain operations functionally. Replace imperative `if (val != null)` checks with clean, declarative pipelines that gracefully handle missing data without `null` leaking into your `Some` instances.

### Sliding-Window Concurrency & Early-Abort Protection
Instead of running unbounded parallel futures that overload your backend, or static batch chunks that leave workers idle, use `TaskEither` and `Task` with built-in `Concurrency` controls (`.sequential`, `.unbounded`, `.bounded(poolSize)`), or run raw collections directly via `concurrency.dispatch(items, worker)`. In bounded mode, a dynamic sliding-window worker pool ensures fast tasks never wait for slow tasks. If any task fails, unstarted queued tasks are **canceled immediately** to save network requests and computing resources.

### Zero-Cost Nested Map Querying with QueryMap
Traversing deeply nested JSON payloads or configuration maps manually requires tedious null checks and risky casting (`map['data']?['users']?[0]?['email'] as String?`), which can throw unhandled `TypeError`s or `RangeError`s in production. `QueryMap` provides a zero-cost compile-time extension type over `Map` with dot notation, bracket indexing for embedded lists, and non-string key lists that gracefully returns `null` on missing paths or type mismatches.

### Zero-Overhead Data Class Annotations
Daxle provides declarative annotations for functional serialization (`@serialize`, `@deserialize`), deep immutable copies with proxies (`@copyWith`), structural equality (`@equalsAndHashCode`), string formatting (`@stringify`), and annotation bundles (`AnnotationBundle`). All annotations carry zero reflective runtime overhead. Pair with `daxle_gen` in `dev_dependencies` to generate pure, zero-drift Dart 3 pattern matching code.

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

## How It Works

### Handle Missing Values with `Option<T>`
An alternative to nullable values (`T?`). Represents either the presence of a value (`Some`) or the absence of a value (`None`).

```dart
import 'package:daxle/daxle.dart';

void main() {
  // Smart constructor Option(value) converts null -> None() and non-null -> Some(value):
  final Option<int> someValue = Option(42);
  final Option<int> noValue = Option(null);

  // Exhaustive pattern matching enforced at compile-time!
  final message = switch (someValue) {
    Some(value: final v) => 'Found: $v',
    None() => 'Nothing here',
  };
}
```

### Make Errors Explicit with `Either<L, R>`
By convention, `Right` is success and `Left` is an error.

```dart
import 'package:daxle/daxle.dart';

Either<String, int> divide(int a, int b) {
  if (b == 0) return const .left('Cannot divide by zero');
  return .right(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  // Safely extract the value or handle the error
  final message = result.fold(
    (error) => 'Failure: $error',
    (value) => 'Result: $value',
  );
}
```

### Chain Async Operations & Manage Concurrency with `TaskEither<L, R>`
A lazy, asynchronous computation that returns an `Either<L, R>`. It embeds the `Either` state at each step, short-circuiting on failure and managing parallel worker limits cleanly.

```dart
import 'package:daxle/daxle.dart';

TaskEither<String, String> fetchUser(int id) => .fromFuture(
  () async => 'User #$id',
  (err, _) => 'User not found',
);

TaskEither<String, String> fetchConfig(String role) => .fromFuture(
  () async => 'Config for $role',
  (err, _) => 'Config not found',
);

void main() async {
  // Chain dependent async computations with clean tear-offs:
  final task = fetchUser(42).flatMap(fetchConfig);

  // The computation doesn't start until you run it
  final Either<String, String> result = await task.run();

  // Run multiple tasks with a sliding-window worker pool of 3.
  // If any task returns a Left, pending unstarted tasks are canceled immediately:
  final batchResult = await TaskEither.sequence(
    [fetchUser(1), fetchUser(2), fetchUser(3)],
    mode: .bounded(3),
  ).run();
}
```

### Safely Query Nested Maps & Embedded Lists with `QueryMap`
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

  // 1. Dot notation for nested maps:
  final host = query.get<String>('services.server.host'); // 'https://api.internal'
  final port = query.get<int>('services.server.port'); // 8080

  // 2. Bracket notation for embedded lists and matrices:
  final userName = query.get<String>('users[0].name'); // 'Alice'
  final firstRole = query.get<String>('users[0].roles[0]'); // 'admin'
  final matrixCell = query.get<int>('matrix[1][0]'); // 30

  // 3. Key lists for non-string map keys:
  final status = query.get<String>(['cluster', 101, 'status']); // 'healthy'

  // 4. Safe failure handling (no exceptions thrown):
  final wrongType = query.get<int>('services.server.host'); // null (value is a String)
  final outOfBounds = query.get<String>('users[99].name'); // null

  // 5. Presence checking (distinguishes explicit null from missing keys):
  query.has('services.database'); // true (key exists with null value)
  query.has('services.cache'); // false (key does not exist)

  // 6. Seamless composition with Option:
  final serverHost = Option(query.get<String>('services.server.host'))
      .getOrElse(() => 'https://fallback.internal');
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

Generate the corresponding `.daxle.dart` part files with:

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

## Ready to build safer apps?

Check out the full **[Documentation](https://daxle.maranix.in)** to explore `Task`, `Concurrency`, `Unit`, `Async Utilities`, `QueryMap`, and advanced combinators. 

---

## Contributing

Contributions are welcome! Please see the [monorepo workspace](https://github.com/maranix/daxle) for guidelines.

## License

Released under the [MIT License](LICENSE).