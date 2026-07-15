---
outline: deep
---

# Working with Optional Values

## Question
**How do I replace nested null checks with Option?**

---

## Problem
While Dart's built-in null-safety (`?` and `??`) is highly convenient, navigating deep configuration dictionaries or applying conditions to nested values can quickly lead to repetitive `if` statements and nested null checks.

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

---

## Solution
Wrap your values inside an `Option` and chain your operations using `flatMap`, `map`, and `filter`. This creates a flat, declarative query pipeline that automatically short-circuits to `None` if any element in the chain is null or fails a validation rule.

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

You can now use `getOrElse` or `fold` to resolve the option and supply a safe fallback value:

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

---

## Why this solution works well with Daxle

* **Zero intermediate variables**: You do not have to write temporary variables to check if they are null, keeping scope pollution to a minimum.
* **Expressive filtering**: The `.filter()` combinator allows you to inject logical checks mid-chain without breaking the flow or introducing nested branches.
* **Declarative fallbacks**: Instead of relying on manual `if (result == null)` handling at the caller site, Daxle's `getOrElse` and `fold` methods force the caller to explicitly handle the absent (`None`) state at the end of the query.
