---
outline: deep
---

# Daxle v5.0.0 Migration Guide

Daxle v5.0.0 represents a major architectural milestone. 

This guide details the motivation behind the v5 rewrite, breaking changes, step-by-step instructions for migrating away from legacy functional types, and how to adopt the modern Daxle toolkit.

---

## Why the Paradigm Shift?

Earlier versions of Daxle focused on traditional functional programming abstractions (`Option`, `Either`, `Task`, `TaskEither`, `Unit`). 

With the maturation of modern Dart 3 (sound null safety, sealed class hierarchies, pattern matching, dot-shorthand constructors, and records), heavy monadic wrappers introduced:
- **Allocation & Indirection Overhead**: Wrapping values in multiple heap objects (`Some`, `Right`, `TaskEither`) degraded hot-path performance.
- **Ecosystem Friction**: Dart idioms favor native nullability (`T?`), pattern matching, and standard asynchronous `Future`s.

In v5.0.0, Daxle shed academic functional types and focused strictly on high-value, zero-cost developer primitives:
1. **`QueryMap`**: Zero-cost nested map, list, and matrix querying.
2. **`Concurrency` & `Pool`**: Flexible sliding-window worker pool execution with early-termination protection.
3. **Stream Transformations**: Complete reactive operators re-exported from `package:stream_transform`.
4. **Deep Structural Equality**: Multi-tiered equality comparisons (`$deepEquals`, `$deepHashCode`).
5. **Declarative Codegen (`daxle_gen`)**: Compile-time AST code generation for serialization, deep `copyWith` proxies, and sensitive field redaction (`@redact`).
6. **State Machine & Workflows (Preview)**: Declarative, compile-time verified state machine transitions.

---

## Summary of Breaking Changes

| Removed / Changed | Replacement in v5.0.0 | Impact |
| :--- | :--- | :--- |
| **`Option<T>`** | Dart native nullable types (`T?`), null-aware operators (`?.`, `??`), and `QueryMap.get<T>()`. | Removed |
| **`Either<L, R>`** | Dart 3 sealed class hierarchies, record tuples, or standard exceptions. | Removed |
| **`Task<T>`** | Standard async closures `() => Future<T>` and `Concurrency.process()`. | Removed |
| **`TaskEither<L, R>`** | Standard `Future`s with `Concurrency.dispatch()` and `shouldStop`. | Removed |
| **`Unit` / `unit`** | Standard Dart `void`. | Removed |
| **Library Imports** | Structured into `package:daxle/daxle.dart` and `package:daxle/async.dart`. | Updated Imports |

---

## 1. Migrating from `Option<T>`

Replace `Option<T>` with standard Dart null safety. Modern Dart handles optionality seamlessly without container objects.

### Mapping Optional Transformations

::: code-group
```dart [v4.x (Before)]
import 'package:daxle/daxle.dart';

Option<int> parsePort(String? raw) {
  return Option(int.tryParse(raw ?? ''))
      .filter((p) => p >= 1024 && p <= 65535);
}

int getPort(String? raw) {
  return parsePort(raw).getOrElse(8080);
}
```

```dart [v5.0.0 (After)]
int? parsePort(String? raw) {
  final port = int.tryParse(raw ?? '');
  if (port != null && port >= 1024 && port <= 65535) {
    return port;
  }
  return null;
}

int getPort(String? raw) {
  return parsePort(raw) ?? 8080;
}
```
:::

### QueryMap with Option

In v4, users frequently wrapped `QueryMap.get()` in `Option`. In v5, `QueryMap.get<T>()` already returns `T?` with safe nullability on missing paths or type mismatches:

::: code-group
```dart [v4.x (Before)]
final host = Option(query.get<String>('services.server.host'))
    .getOrElse('https://localhost');
```

```dart [v5.0.0 (After)]
final host = query.get<String>('services.server.host') ?? 'https://localhost';
```
:::

---

## 2. Migrating from `Either<L, R>`

Replace `Either<L, R>` with **Dart 3 sealed classes**. Sealed classes give you exhaustive compile-time verification with zero wrapper allocations and meaningful domain names.

### Defining Results with Sealed Hierarchies

::: code-group
```dart [v4.x (Before)]
import 'package:daxle/daxle.dart';

Either<String, User> authenticate(String token) {
  if (token.isEmpty) {
    return .left('Token cannot be empty');
  }
  return .right(User(id: '123'));
}

void handleLogin(String token) {
  final result = authenticate(token);
  switch (result) {
    case Left(value: final err):
      showError(err);
    case Right(value: final user):
      showDashboard(user);
  }
}
```

```dart [v5.0.0 (After)]
// Domain-specific sealed class hierarchy
sealed class AuthResult {}

class AuthSuccess extends AuthResult {
  final User user;
  const AuthSuccess(this.user);
}

class AuthFailure extends AuthResult {
  final String error;
  const AuthFailure(this.error);
}

AuthResult authenticate(String token) {
  if (token.isEmpty) {
    return const AuthFailure('Token cannot be empty');
  }
  return AuthSuccess(User(id: '123'));
}

void handleLogin(String token) {
  final result = authenticate(token);
  switch (result) {
    case AuthFailure(:final error):
      showError(error);
    case AuthSuccess(:final user):
      showDashboard(user);
  }
}
```
:::

If you prefer lightweight tuple returns for simple utility functions, use native Dart 3 records:

```dart
(String? error, User? user) authenticate(String token) {
  if (token.isEmpty) return ('Token cannot be empty', null);
  return (null, User(id: '123'));
}
```

---

## 3. Migrating from `Task` and `TaskEither`

In v4, `Task` and `TaskEither` provided lazy async blueprints and batch worker pools via `TaskEither.traverse` and `Task.sequence`.

In v5, use standard async functions alongside **`Concurrency`** from `package:daxle/async.dart`.

### Batch Concurrency & Worker Limits

::: code-group
```dart [v4.x (Before)]
import 'package:daxle/daxle.dart';

final urls = ['https://site1.com', 'https://site2.com', 'https://site3.com'];

// Executed tasks with sliding-window pool of 3 workers
final results = await TaskEither.traverse(
  urls,
  (url) => TaskEither.fromFuture(
    () => httpClient.read(Uri.parse(url)),
    (err, _) => 'Failed: $err',
  ),
  mode: .bounded(3),
).run();
```

```dart [v5.0.0 (After)]
import 'package:daxle/async.dart';

final urls = ['https://site1.com', 'https://site2.com', 'https://site3.com'];

// Concurrency.bounded directly dispatches items with worker limit:
final results = await const Concurrency.bounded(3).dispatch(
  urls,
  (url) => httpClient.read(Uri.parse(url)),
  shouldStop: (response) => false, // Optional early abort predicate
);
```
:::

### Processing Zero-Argument Task Thunks

If you have a collection of zero-argument async task functions:

```dart
import 'package:daxle/async.dart';

final tasks = <Future<String> Function()>[
  () => fetchConfig(),
  () => fetchUserProfile(),
  () => fetchNotifications(),
];

// Execute up to 2 tasks in parallel:
final results = await const Concurrency.bounded(2).process(tasks);
```

---

## 4. Migrating from `Unit`

The `Unit` type and `unit` singleton are removed. Use Dart's native `void` keyword.

::: code-group
```dart [v4.x (Before)]
TaskEither<AppError, Unit> logAnalytics(Event event) {
  sendEvent(event);
  return TaskEither.right(unit);
}
```

```dart [v5.0.0 (After)]
Future<void> logAnalytics(Event event) async {
  await sendEvent(event);
}
```
:::

---

## 5. Structured Library Entrypoints

Daxle v5 reorganizes its public API into two focused libraries:

```dart
// 1. Core data modeling, QueryMap, equality, and preview state machine
import 'package:daxle/daxle.dart';

// 2. Concurrency, Pool, stream_transform, and async utilities
import 'package:daxle/async.dart';
```

---

## 6. What's New in Daxle v5.x?

Upgrading to v5 unlocks several modern capabilities:

- **Reactive Stream Transformations**: Direct re-exports from `package:stream_transform`:
  ```dart
  import 'package:daxle/async.dart';

  stream.debounce(const Duration(milliseconds: 300)).switchMap(...);
  ```
- **Battle-Tested Resource Pooling (`Pool`)**: Re-exports `Pool` and `PoolResource` from `package:pool`, plus `Concurrency.createPool()`.
- **Sensitive Field Masking (`@redact`)**: Prevent secret credentials, tokens, or PII from leaking into logs via `toString()` and `toDebugMap()` without affecting `toMap()`.
- **Compile-Time Code Generation (`daxle_gen`)**: High-performance AST code generation for serialization, deep `copyWith` proxies, equality, and records without `build_runner`.
- **State Machine & Workflows (Preview)**: Declarative `@StateMachine([Flow(...)])` for compile-time verified state transitions and epoch-based stale event cancellation.

---

## Upgrade Checklist

1. **Update `pubspec.yaml`**:
   ```yaml
   dependencies:
     daxle: ^5.1.0

   dev_dependencies:
     daxle_gen: ^0.3.1
   ```
2. **Update Imports**:
   - Use `import 'package:daxle/daxle.dart';` for core annotations and `QueryMap`.
   - Use `import 'package:daxle/async.dart';` for `Concurrency`, `Pool`, and stream operators.
3. **Remove Legacy Types**:
   - Replace `Option<T>` with nullable types `T?` and `??`.
   - Replace `Either<L, R>` with Dart 3 `sealed class` hierarchies or record tuples.
   - Replace `Task` and `TaskEither` with `Future` and `Concurrency.bounded().dispatch()`.
   - Replace `Unit` with `void`.
4. **Run Verification**:
   ```bash
   dart analyze
   dart test
   ```
