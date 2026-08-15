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


## The Solution: Seamless Querying with QueryMap and Option

Stop fighting nulls manually. Wrap your data in a zero-cost `QueryMap` to extract the nested property, then wrap the result in an `Option` to chain your validation rules using `map` and `filter`.

This transforms messy nested checks into a clean, declarative pipeline. If the path is missing, of the wrong type, or fails your validation rules, Daxle automatically short-circuits to `None`.

```dart
import 'package:daxle/daxle.dart';

// Fluent querying of server host with QueryMap & Option
//
// Reads like a step-by-step pipeline
Option<String> getSanitizedServerHostSafe(Map<String, dynamic> config) {
  final query = QueryMap(config);

  return Option(query.get<String>('services.server.host'))
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
