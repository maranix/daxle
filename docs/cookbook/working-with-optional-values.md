---
outline: deep
---

# Working with Optional Values

## How do you eliminate repetitive null checks when navigating deep data structures?


## The Fatigue of Nested Nulls

Dart's built-in null-safety (`?` and `??`) is great for simple variables. But when you need to navigate deep JSON dictionaries or apply conditional logic to nested values, the convenience disappears. 

You quickly find yourself writing repetitive `if` statements, declaring temporary variables, and nesting null checks just to extract a single piece of data safely.

```dart
// Navigating nested configuration map with imperative null checks
String? getSanitizedServerHost(Map<String, dynamic> config) {
  final services = config['services'];
  if (services != null && services is Map) {
    final server = services['server'];
    if (server != null && server is Map) {
      final host = server['host'];
      if (host != null && host is String) {
        final cleaned = host.trim();
        if (cleaned.isNotEmpty && !cleaned.startsWith('localhost')) {
          return cleaned;
        }
      }
    }
  }
  return null;
}
```


## The Solution: Flat Query Pipelines with Option

Stop fighting nulls manually. Wrap your data in an `Option` and chain your logic using `flatMap`, `map`, and `filter`. 

This transforms your logic into a flat, declarative pipeline. If any value in the chain is null—or fails your validation rules—Daxle automatically short-circuits to `None`.

```dart
import 'package:daxle/daxle.dart';

// Helper to safely extract a map field from another map
Option<Map<String, dynamic>> getMapField(Map<String, dynamic> map, String key) {
  final value = map[key];
  return Option.fromPredicate(
    value,
    (v) => v != null && v is Map<String, dynamic>,
  ).map((v) => v as Map<String, dynamic>);
}

// Fluent querying of server host with Option
Option<String> getSanitizedServerHostSafe(Map<String, dynamic> config) {
  return getMapField(config, 'services')
      .flatMap((services) => getMapField(services, 'server'))
      .flatMap((server) => Option.fromNullable(server['host'] as String?))
      .map((host) => host.trim())
      .filter((host) => host.isNotEmpty)
      .filter((host) => !host.startsWith('localhost'));
}
```

When you're ready to use the data, provide a safe fallback value with `getOrElse` or `fold`:

```dart
void main() {
  final Map<String, dynamic> appConfig = {
    'services': {
      'server': {
        'host': '  api.production.internal  ',
        'port': 8080,
      }
    }
  };

  final host = getSanitizedServerHostSafe(appConfig)
      .getOrElse('default-gateway.internal');

  print('Target host: $host'); // Prints: Target host: api.production.internal
}
```


## Why You'll Love This Approach

* **Eradicate Scope Pollution**: You never have to declare a temporary variable just to check if it's null. Your code stays focused and clean.
* **Filter Data Powerfully**: The `.filter()` combinator lets you inject business logic right in the middle of your chain, without ever breaking your flow or creating new code branches.
* **Force Safe Handling**: Instead of hoping the caller remembers to write `if (result == null)`, Daxle's `getOrElse` and `fold` methods force them to explicitly handle the missing state at compile time.
