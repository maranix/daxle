# Daxle: High-Performance Data Modeling, Concurrency & Stream Transformation

[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![Pub Points](https://img.shields.io/pub/points/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Daxle is a lightweight Dart 3+ toolkit providing nested map querying (`QueryMap`), flexible sliding-window concurrency (`Concurrency`), deep collection equality, stream transformation operators, declarative code generation annotations, and preview state machine workflows.

**[📚 Read the Official Documentation](https://daxle.maranix.in)**

---

## Core Capabilities

- **Nested Map Traversal (`QueryMap`)**: Extension type over `Map` with dot notation, bracket indexing for embedded lists, and non-string key support. Safely returns `null` on missing paths or type mismatches without throwing exceptions.
- **Sliding-Window Worker Pool (`Concurrency`)**: Manage asynchronous workload throughput using `.sequential`, `.unbounded`, or `.bounded(poolSize)` modes backed by `package:pool`, with early termination abort protection via `shouldStop`.
- **Resource Pooling (`Pool`)**: Re-exports `Pool` and `PoolResource` from `package:pool` for robust asynchronous throttling and resource management.
- **Deep Structural Equality (`$deepEquals`, `$deepHashCode`)**: Multi-tiered equality comparisons for nested maps, sets, lists, and records.
- **Stream Transformation Operators**: Re-exports all operators from `package:stream_transform` (`debounce`, `throttle`, `audit`, `buffer`, `combineLatest`, `merge`, `switchMap`, `scan`, `tap`, `whereType`).
- **Async Flow Utilities**: Re-exports key utilities from `package:async` (`FutureGroup`, `AsyncCache`, `AsyncMemoizer`, `StreamZip`, `StreamQueue`, `StreamGroup`, `StreamSplitter`).
- **Data Class Annotations**: Declarative annotations (`@serialize`, `@deserialize`, `@copyWith`, `@equalsAndHashCode`, `@stringify`, `@redact`, `@AnnotationBundle`) paired with `daxle_gen` in `dev_dependencies` for AST-based code generation.
- **State Machine & Workflows (Preview & Experimental)**: Declarative annotations (`@StateMachine`, `Flow`, `TransitionScope`, `InvalidFlowException`) for validated state transition graphs, async flow handlers, and epoch-based stale flow cancellation.

---

## Structured Library Exports

To keep auto-complete clean and imports focused, Daxle organizes its exports into dedicated libraries:

- **`package:daxle/daxle.dart`**: Core annotations, data classes, structural equality (`$deepEquals`), map querying (`QueryMap`), and preview state machine primitives (`StateMachine`, `Flow`, `TransitionScope`, `InvalidFlowException`).
- **`package:daxle/async.dart`**: Curated asynchronous & reactive toolkit (`Concurrency`, `Pool`, `package:stream_transform` operators, `FutureGroup`, `AsyncCache`, `AsyncMemoizer`, `StreamZip`, `StreamQueue`, etc.).

```dart
// Data modeling, querying & state machine workflows
import 'package:daxle/daxle.dart';

// Async concurrency & reactive streams
import 'package:daxle/async.dart';
```

---

## Installation

Add Daxle to your `pubspec.yaml`:

```yaml
dependencies:
  daxle: ^5.0.0

# Optional: Add daxle_gen to dev_dependencies for code generation
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

Wrap any `Map` with `QueryMap` to query nested properties, embedded lists, and multi-dimensional matrices using dot notation, bracket indexing, or key lists.

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
import 'package:daxle/async.dart';

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
import 'package:daxle/async.dart';

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

## Data Classes & Code Generation (`daxle_gen`)

`daxle` provides declarative annotations for models. When combined with [`daxle_gen`](https://pub.dev/packages/daxle_gen) in `dev_dependencies`, code generation synthesizes type-safe, functional serialization, deep immutable lenses, structural equality, and clean string representations.

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

### 4. Sensitive Field Redaction (`@redact`)

Prevent sensitive data (passwords, tokens, PII) from leaking into logs by annotating fields with `@redact` / `Redact()`:

```dart
@serialize
@stringify
class ApiConfig(
  final String host,
  @redact
  final String secretKey,
  @Redact(mask: '***', preserveLength: true)
  final String authToken,
) with _$ApiConfigStringify;

void main() {
  final config = ApiConfig('api.domain.com', 'sk_live_9999', 'token_secret');

  // Logs and debug representations mask sensitive fields:
  print(config); // ApiConfig(host: api.domain.com, secretKey: [REDACTED], authToken: ************)
  print(config.toDebugMap()); // {'host': 'api.domain.com', 'secretKey': '[REDACTED]', 'authToken': '************'}

  // Wire serialization remains completely unaltered:
  print(config.toMap()); // {'host': 'api.domain.com', 'secretKey': 'sk_live_9999', 'authToken': 'token_secret'}
}
```

---

## State Machines & Workflows (Preview & Experimental)

> [!WARNING]
> **Preview & Experimental**: `StateMachine` and related workflow primitives (`Flow`, `TransitionScope`, `InvalidFlowException`) are currently in preview and under active experimental development. Public APIs and generated code conventions may evolve in subsequent releases.

Daxle provides declarative state machines with validated transition graphs, epoch-based stale flow cancellation, and async transition scopes.

When combined with `daxle_gen`, classes annotated with `@StateMachine` synthesize a `_$ClassNameMachine` mixin that enforces valid state transitions and guarantees safe asynchronous flow lifecycles.

```dart
import 'dart:async';
import 'package:daxle/daxle.dart';

part 'order_machine.daxle.dart';

// States
sealed class OrderState { const OrderState(); }
final class OrderIdle extends OrderState { const OrderIdle(); }
final class OrderSubmitting extends OrderState { const OrderSubmitting(); }
final class OrderPlaced extends OrderState { final String orderId; const OrderPlaced(this.orderId); }
final class OrderFailed extends OrderState { final String reason; const OrderFailed(this.reason); }

// Events
sealed class OrderEvent { const OrderEvent(); }
final class SubmitOrder extends OrderEvent { final String item; const SubmitOrder(this.item); }
final class RetryOrder extends OrderEvent { const RetryOrder(); }

@StateMachine([
  Flow(from: OrderIdle, to: OrderSubmitting, using: SubmitOrder),
  Flow(from: OrderSubmitting, to: OrderPlaced),
  Flow(from: OrderSubmitting, to: OrderFailed),
  Flow(from: OrderFailed, to: OrderSubmitting, using: RetryOrder),
])
final class OrderService with _$OrderServiceMachine {
  @override
  OrderState activeState = const OrderIdle();

  // Async flow handler for transition into OrderSubmitting
  @override
  FutureOr<void> onSubmitting(TransitionScope<OrderState> scope, OrderEvent event) async {
    try {
      final orderId = await submitToBackend();
      // Safe transition - checks active status and validates transition table:
      scope.transit(OrderPlaced(orderId));
    } catch (e) {
      scope.transit(OrderFailed(e.toString()));
    }
  }
}

void main() {
  final service = OrderService();

  // Dispatch events to drive transitions:
  service.dispatch(SubmitOrder('laptop'));

  // Invalid transitions throw InvalidFlowException immediately:
  // service.dispatch(RetryOrder()); // Throws: transition from OrderSubmitting via RetryOrder is not permitted
}
```

### Key Workflow Concepts:

- **`Flow(from: StateA, to: StateB, using: EventX)`**: Declares directed edges. `using` indicates an external event trigger. When omitted, the edge represents an internal autonomous transition within an async flow.
- **`TransitionScope<TState>`**: Passed to asynchronous flow handlers. Exposes `scope.transit(nextState)`, `scope.getActiveState()`, and `scope.isCurrent` to prevent race conditions.
- **Stale Flow Protection (`_daxleEpoch`)**: Monotonically increments an internal epoch when new events arrive. If an asynchronous flow completes after a subsequent event has transitioned the machine, calls to `scope.transit()` are safely ignored.
- **Fail-Fast Validation (`InvalidFlowException`)**: Any attempt to transition to an unlisted target state or dispatch an event not valid for the active state throws `InvalidFlowException` detailing the source state, attempted target, and permitted transitions.

---

## Contributing

Contributions are welcome! Please see the [monorepo workspace](https://github.com/maranix/daxle) for guidelines.

## License

Released under the [MIT License](LICENSE).