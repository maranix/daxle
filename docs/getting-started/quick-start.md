---
outline: deep
---

# Quick Start

This guide will walk you through building a simple, production-ready configuration parser. You will learn how to handle optional values, validate inputs, and manage domain errors using Daxle—without throwing a single exception or returning `null`.

---

## The Scenario

Imagine we are building a backend service or a Flutter app that requires a configuration object loaded from environment variables (a `Map<String, String>`):

1. **Port**: An optional port number. If present, it must be a valid integer between `1024` and `65535`. If missing or invalid, we fallback to a default port (`8080`).
2. **Database URL**: A required connection string. If it's missing or empty, the application cannot start and must report a configuration error.

Here is our target configuration object:

```dart
class AppConfig {
  final int port;
  final String databaseUrl;

  const AppConfig({required this.port, required this.databaseUrl});

  @override
  String toString() => 'AppConfig(port: $port, databaseUrl: $databaseUrl)';
}
```

---

## Step 1: Handling the Optional Port with `Option`

In standard Dart, parsing the optional port safely involves multiple conditional checks and helper variables:

```dart
// Standard Dart Approach
int parsePort(Map<String, String> env) {
  final raw = env['PORT'];
  if (raw != null) {
    final parsed = int.tryParse(raw);
    if (parsed != null && parsed >= 1024 && parsed <= 65535) {
      return parsed;
    }
  }
  return 8080;
}
```

With Daxle, we can express this entire flow as a single, readable pipeline using `Option`. We use the dot-shorthand constructors `.fromNullable` to wrap the value and `.none()` / `.some()` implicitly:

```dart
import 'package:daxle/daxle.dart';

int parsePort(Map<String, String> env) {
  return .fromNullable(env['PORT']) // Option<String>
      .flatMap((s) => .fromNullable(int.tryParse(s))) // Option<int>
      .filter((p) => p >= 1024 && p <= 65535) // Filters invalid ports
      .getOrElse(8080); // Default fallback
}
```

---

## Step 2: Handling the Required Database URL with `Either`

The database URL is a mandatory parameter. If it is missing, we want to fail fast and return a descriptive error message instead of throwing a generic runtime exception. 

We can model this using `Either<String, String>`, where the left side (`Left`) contains the error message, and the right side (`Right`) contains the validated URL.

We use `Either.cond` (written as `.cond` via dot-shorthand) to construct the value based on a boolean condition:

```dart
import 'package:daxle/daxle.dart';

Either<String, String> parseDatabaseUrl(Map<String, String> env) {
  final url = env['DATABASE_URL'];
  final isValid = url != null && url.isNotEmpty;

  return .cond(
    isValid,
    url ?? '',
    'DATABASE_URL configuration is missing or empty',
  );
}
```

---

## Step 3: Composing the Pipeline

Now, let's combine these steps to load our full `AppConfig`. We want our load function to return `Either<String, AppConfig>`. 

If the database URL validation fails, the entire pipeline fails. If it succeeds, we construct the configuration.

```dart
import 'package:daxle/daxle.dart';

Either<String, AppConfig> loadConfig(Map<String, String> env) {
  final port = parsePort(env);

  return parseDatabaseUrl(env).map(
    (dbUrl) => AppConfig(
      port: port,
      databaseUrl: dbUrl,
    ),
  );
}
```

---

## Step 4: Executing and Matching the Result

Now we can load our configuration and handle both success and failure cases using Dart's exhaustive pattern matching. Because `Either` is a sealed class, the compiler will warn us if we forget to handle either the `Left` or `Right` cases.

```dart
import 'package:daxle/daxle.dart';

void main() {
  // 1. Test case: Success
  final validEnv = {
    'PORT': '9000',
    'DATABASE_URL': 'postgres://localhost:5432/mydb',
  };

  final result1 = loadConfig(validEnv);
  final message1 = switch (result1) {
    Left(value: final err) => 'Initialization Failed: $err',
    Right(value: final config) => 'Service started successfully with $config',
  };
  print(message1);
  // Prints: Service started successfully with AppConfig(port: 9000, databaseUrl: postgres://localhost:5432/mydb)

  // 2. Test case: Failure (missing required Database URL)
  final invalidEnv = {
    'PORT': 'invalid_port_will_fallback_to_8080',
  };

  final result2 = loadConfig(invalidEnv);
  final message2 = switch (result2) {
    Left(value: final err) => 'Initialization Failed: $err',
    Right(value: final config) => 'Service started successfully with $config',
  };
  print(message2);
  // Prints: Initialization Failed: DATABASE_URL configuration is missing or empty
}
```

---

## What's Next?

You've built your first type-safe pipeline using Daxle! You've seen how `Option` replaces unsafe null checks and how `Either` makes errors first-class citizens.

* Learn more about [Option](/core-types/option) and [Either](/core-types/either) in the Core Types section.
* See how to write lazy asynchronous pipelines using [Task](/core-types/task) and [TaskEither](/core-types/task-either).
