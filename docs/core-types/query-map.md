---
outline: deep
---

# QueryMap

Safely query nested maps, embedded lists, and multi-dimensional matrices at zero runtime cost.


## What is QueryMap?

`QueryMap` is a zero-cost compile-time extension type (`extension type const QueryMap(Map<Object?, Object?> map)`) that provides expressive, path-based querying over structured `Map`s and JSON payloads.

Instead of writing fragile nested index chains and risky casts, `QueryMap` gives you intuitive dot notation, bracket indexing, and key list traversal that gracefully returns `null` on missing paths or type mismatches.

```dart
final config = {
  'services': {
    'server': {'host': 'https://api.internal', 'port': 8080},
    'database': null,
  },
  'users': [
    {'name': 'Alice', 'roles': ['admin', 'dev']},
  ],
};

final query = QueryMap(config);

final host = query.get<String>('services.server.host'); // 'https://api.internal'
final role = query.get<String>('users[0].roles[1]'); // 'dev'
```


## Why You Need It

Extracting nested values from complex JSON responses, configuration maps, or dynamic payloads in standard Dart is frustrating and error-prone:

1. **Repetitive Null Chaining**: Navigating deep structures requires tedious cascades like `map['services']?['server']?['host']`.
2. **Crash-Prone Type Casting**: Explicit casts (`as String?`) throw unhandled `TypeError` exceptions at runtime if backend payloads change unexpectedly or return a number instead of a string.
3. **Array Indexing Exceptions**: Accessing embedded lists with standard brackets (`list[0]`) throws `RangeError` if the list is empty or smaller than expected.
4. **Ambiguous Nulls**: Standard map access cannot distinguish between a missing key and an existing key whose value is explicitly `null`.

`QueryMap` fixes all four issues with zero runtime performance penalty—it compiles away completely down to standard Dart map lookups.


## Key Features

### 1. Dot Notation for Nested Maps
Query nested string keys using simple dot-separated paths:

```dart
final query = QueryMap({
  'database': {
    'primary': {
      'host': 'postgres.internal',
      'port': 5432,
    },
  },
});

final host = query.get<String>('database.primary.host'); // 'postgres.internal'
final port = query.get<int>('database.primary.port'); // 5432
```

### 2. Bracket Notation for Lists and Matrices
Access array elements and multi-dimensional matrices using intuitive bracket indices:

```dart
final query = QueryMap({
  'clusters': [
    {
      'nodes': ['node-alpha', 'node-beta'],
    },
  ],
  'matrix': [
    [10, 20],
    [30, 40],
  ],
});

// Single-level list index
final firstNode = query.get<String>('clusters[0].nodes[0]'); // 'node-alpha'

// Multi-dimensional array index
final cell = query.get<int>('matrix[1][0]'); // 30
```

### 3. Key Lists for Non-String Keys
Pass an `Iterable` or list of keys to traverse maps containing non-string keys (like `int`, `enum`, or `bool`):

```dart
final query = QueryMap({
  'cluster': {
    101: {'status': 'healthy'},
    102: {'status': 'draining'},
  },
});

// Query using a list of mixed-type keys
final status = query.get<String>(['cluster', 101, 'status']); // 'healthy'
```

### 4. Type-Safe Fallbacks (No TypeErrors)
`query.get<T>(path)` performs safe runtime type validation. If the path exists but the value does not match `T`, it returns `null` rather than throwing a `TypeError`:

```dart
final query = QueryMap({'port': '8080'}); // Stored as a String

// Requesting an int returns null safely instead of throwing TypeError:
final intPort = query.get<int>('port'); // null
final strPort = query.get<String>('port'); // '8080'
```

### 5. Presence Detection with `has()`
Check whether a key exists in the data structure, even when its value is `null`, `false`, `0`, or empty:

```dart
final query = QueryMap({
  'services': {
    'database': null,
  },
});

query.has('services.database'); // true (key exists with null value)
query.has('services.cache'); // false (key does not exist)
```


## Seamless Composition with Option

`QueryMap` pairs naturally with Daxle's `Option` type for expressive, default-fallback chaining:

```dart
import 'package:daxle/daxle.dart';

void main() {
  final payload = {
    'services': {
      'server': {'host': 'https://api.internal'},
    },
  };

  final query = QueryMap(payload);

  // Wrap query.get in Option to establish default fallbacks
  final host = Option(query.get<String>('services.server.host'))
      .getOrElse(() => 'https://fallback.internal');

  print('Target server: $host'); // Prints: Target server: https://api.internal
}
```


## Best Practices

* **Wrap API Boundaries**: Instantiate `QueryMap` immediately when receiving JSON data from HTTP responses or configuration files.
* **Combine with Option**: Use `Option(query.get<T>(path))` when you need declarative fallbacks (`getOrElse`) or conditional validation (`filter`).
* **Use Key Lists for Dynamic Keys**: When map keys are variables or non-strings, use the list format `query.get<T>([keyA, keyB])` instead of string interpolation.


## Related Types

* [Option](option) - Wrap `query.get` results in `Option` for functional chaining and fallbacks.
* [Either](either) - Convert missing query values into typed domain errors using `Either.fromNullable` patterns or `Option.fold`.
