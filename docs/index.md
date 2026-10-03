---
layout: home

hero:
  name: Daxle
  text: High-Performance Data Modeling, Concurrency & Stream Transformation
  tagline: Lightweight Dart 3+ toolkit for zero-cost nested map querying, sliding-window worker pool concurrency, reactive stream operators, and compile-time code generation.
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/introduction
    - theme: alt
      text: v5.0.0 Migration Guide
      link: /getting-started/migration-v5
    - theme: alt
      text: View on GitHub
      link: https://github.com/maranix/daxle

features:
  - title: Zero-Cost Map & JSON Queries
    details: Traverse deeply nested maps, embedded arrays, and matrices using QueryMap with dot notation and bracket indexing. Safely returns null on missing paths without runtime exceptions.
  - title: Sliding-Window Concurrency
    details: Control asynchronous execution limits with Concurrency (.bounded, .sequential, .unbounded) backed by package:pool, with automatic early termination abort protection.
  - title: Reactive Stream Transformations
    details: Curated re-exports of package:stream_transform operators (debounce, throttle, audit, buffer, switchMap, combineLatest, merge) for declarative event pipelines.
  - title: Compile-Time Code Generation
    details: Fast AST-based generator via daxle_gen. Automates serialization, deep copyWith proxies, structural equality, and field redaction without build_runner lag.
  - title: State Machine & Workflows (Preview)
    details: Declarative @StateMachine workflows with compile-time verified transition tables, async flow handlers, and epoch-based stale event cancellation.
  - title: Deep Structural Equality
    details: Multi-tiered structural equality ($deepEquals, $deepHashCode) supporting nested collections, sets, maps, and Dart 3 record hierarchies.
---

## Why Daxle?

Modern Dart features like pattern matching, sealed classes, and records provide an incredible foundation. However, building real-world applications and cloud services still introduces repetitive boilerplate and defensive noise:

- **Fragile Map & JSON Traversal**: Manually navigating untyped nested maps leads to runtime `TypeError`s, `RangeError`s, and defensive null assertions.
- **Uncontrolled Concurrency**: Unbounded `Future.wait` calls can overwhelm network bandwidth, exceed backend rate limits, or consume excess memory.
- **Data Class Boilerplate**: Manually writing serialization, deep `copyWith`, and multi-collection equality checks is time-consuming and error-prone.
- **Accidental Secret Leaks**: Logging configuration models often leaks API keys, passwords, or PII into system stdout or monitoring services.

**Daxle solves this.** It provides practical, high-performance tools engineered specifically for Dart 3+ that eliminate defensive boilerplate without academic jargon or runtime overhead.


## See it in Action

Here is how Daxle streamlines everyday Dart workflows:

### 1. Zero-Cost Nested Map & JSON Querying

Traverse deeply nested maps, embedded lists, and multi-dimensional matrices using `QueryMap`. Dot and bracket paths safely return `null` on missing paths or type mismatches instead of throwing `TypeError` or `RangeError`.

::: code-group
```dart [Daxle (QueryMap)]
import 'package:daxle/daxle.dart';

void main() {
  final payload = {
    'services': {
      'server': {'host': 'https://api.internal', 'port': 8080},
    },
    'users': [
      {'name': 'Alice', 'roles': ['admin', 'dev']},
    ],
    'cluster': {
      101: {'status': 'healthy'},
    },
  };

  final query = QueryMap(payload);

  // 1. Dot notation:
  final host = query.get<String>('services.server.host'); // 'https://api.internal'

  // 2. Bracket indexing on embedded lists:
  final role = query.get<String>('users[0].roles[0]'); // 'admin'

  // 3. Non-string map keys:
  final status = query.get<String>(['cluster', 101, 'status']); // 'healthy'

  // 4. Type safety (returns null instead of throwing TypeError):
  final port = query.get<String>('services.server.port'); // null (value is an int)
}
```

```dart [Standard Dart]
void main() {
  final payload = <String, dynamic>{/* ... */};

  // Verbose, defensive casting vulnerable to runtime TypeErrors and RangeErrors
  String? host;
  final services = payload['services'];
  if (services is Map<String, dynamic>) {
    final server = services['server'];
    if (server is Map<String, dynamic> && server['host'] is String) {
      host = server['host'] as String;
    }
  }

  String? role;
  final users = payload['users'];
  if (users is List && users.isNotEmpty) {
    final first = users[0];
    if (first is Map && first['roles'] is List && (first['roles'] as List).isNotEmpty) {
      final r = (first['roles'] as List)[0];
      if (r is String) role = r;
    }
  }
}
```
:::

### 2. Controlled Asynchronous Concurrency

Prevent resource exhaustion and rate limits. Control worker limits and execute collections directly with sliding-window concurrency backed by `package:pool`:

```dart
import 'package:daxle/async.dart';

void main() async {
  final urls = [
    'https://api.service.com/item/1',
    'https://api.service.com/item/2',
    'https://api.service.com/item/3',
    'https://api.service.com/item/4',
  ];

  // Process items concurrently with a sliding-window pool of 2 workers:
  final responses = await const Concurrency.bounded(2).dispatch(
    urls,
    (url) async => httpClient.get(Uri.parse(url)),
    shouldStop: (res) => res.statusCode >= 500, // Early abort on critical failure
  );
}
```

### 3. Declarative Code Generation & Sensitive Redaction

With `daxle_gen`, eliminate boilerplate for models, deep `copyWith` mutation, and equality comparisons. Protect secrets and PII from leaking into logs using `@redact`:

```dart
import 'package:daxle/daxle.dart';

part 'api_config.daxle.dart';

@serialize
@deserialize
@copyWith
@stringify
@equalsAndHashCode
class ApiConfig {
  final String endpoint;

  @redact
  final String apiKey;

  const ApiConfig({required this.endpoint, required this.apiKey});
}

void main() {
  final config = ApiConfig(endpoint: 'https://api.prod.com', apiKey: 'sk-923847293847');

  // toString() masks apiKey -> ApiConfig(endpoint: https://api.prod.com, apiKey: ***)
  print(config);

  // toDebugMap() masks apiKey -> {'endpoint': 'https://api.prod.com', 'apiKey': '***'}
  print(config.toDebugMap());

  // toMap() preserves raw apiKey for wire-format serialization:
  print(config.toMap());
}
```

### 4. Reactive Stream Transformation

Manipulate, debounce, and interleave event streams with reactive operators from `package:stream_transform`:

```dart
import 'package:daxle/async.dart';

void setupSearch(Stream<String> searchInput) {
  searchInput
      .debounce(const Duration(milliseconds: 300))
      .where((term) => term.trim().isNotEmpty)
      .switchMap((term) => api.searchStream(term))
      .listen((results) => updateUi(results));
}
```

### 5. State Machine & Workflows (Preview & Experimental)

Model directed state transitions with compile-time validated transition tables, flow handlers, and epoch-based stale event cancellation:

```dart
import 'package:daxle/daxle.dart';

part 'order_flow.daxle.dart';

@StateMachine<OrderState, OrderEvent>([
  Flow(from: OrderDraft, to: OrderProcessing, using: SubmitOrder),
  Flow(from: OrderProcessing, to: OrderCompleted, using: PaymentSucceeded),
  Flow(from: OrderProcessing, to: OrderFailed, using: PaymentFailed),
])
class OrderWorkflow extends _$OrderWorkflowMachine {
  @override
  FutureOr<void> onOrderProcessing(
    TransitionScope<OrderProcessing> scope,
    SubmitOrder event,
  ) async {
    final success = await processPayment(event.orderId);
    if (scope.isCurrent) {
      scope.transit(success ? OrderCompleted() : OrderFailed());
    }
  }
}
```


## Structured Library Architecture

Daxle exports clean, dedicated entrypoints to keep auto-complete focused and imports clean:

- **`package:daxle/daxle.dart`**: Core annotations, structural equality (`$deepEquals`), nested map queries (`QueryMap`), and preview state machine primitives.
- **`package:daxle/async.dart`**: Curated asynchronous & reactive toolkit (`Concurrency`, `Pool`, `stream_transform` operators, `FutureGroup`, `AsyncCache`, etc.).


## Quick Installation

Add Daxle to your project:

```bash
dart pub add daxle
```

For compile-time code generation (serialization, deep copyWith, equality, redaction):

```bash
dart pub add --dev daxle_gen
```

Ready to get started? Head over to the [Introduction Guide](/getting-started/introduction) or read the [v5.0.0 Migration Guide](/getting-started/migration-v5).