---
outline: deep
---

# Quick Start

Welcome to the Daxle Quick Start guide. Let's build a production-ready configuration parser. 

In this tutorial, you will handle optional values, validate inputs, and manage domain errors using Daxle—without throwing a single exception or writing `null`.


## The Scenario

Imagine you need to load a configuration object from environment variables (`Map<String, String>`). 

Your configuration has two rules:
1. **Port (Optional)**: If provided, it must be an integer between `1024` and `65535`. If missing or invalid, fall back to `8080`.
2. **Database URL (Required)**: You need a valid connection string. If it's missing or empty, the app must stop and report a clear error.

Here is your `AppConfig` class:

```dart
class AppConfig {
  final int port;
  final String databaseUrl;

  const AppConfig({required this.port, required this.databaseUrl});

  @override
  String toString() => 'AppConfig(port: $port, databaseUrl: $databaseUrl)';
}
```


## Step 1: Handle Optional Values with `Option`

In standard Dart, you extract and validate the optional port using a messy cascade of `if` statements:

```dart
// The Standard Dart Approach
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

This hides your intent behind visual noise. With Daxle, you express this exact logic as a single, readable pipeline using `Option`. 

Watch how Daxle's smart factory constructor (`Option(port)`) effortlessly wraps potential nulls into an `Option`:

```dart
import 'package:daxle/daxle.dart';

int parsePort(Map<String, String> env) {
  final port = int.tryParse(env['PORT'] ?? '');

  return Option(port) // Smart constructor automatically converts null -> None()
      .filter((p) => p >= 1024 && p <= 65535) // Discard invalid ports
      .getOrElse(8080); // Provide the default fallback
}
```


## Step 2: Enforce Required Values with `Either`

Your database URL is required. If it's missing, you want your system to fail gracefully with a clear error message, not crash with a random runtime exception.

You can model this using `Either<String, String>`. In Daxle, `Left` holds your error message, and `Right` holds your valid data.

Return your success or failure states directly using `.left` and `.right`:

```dart
import 'package:daxle/daxle.dart';

Either<String, String> parseDatabaseUrl(Map<String, String> env) {
  final url = env['DATABASE_URL'];

  if (url == null || url.isEmpty) {
    return .left('Critical Error: DATABASE_URL is missing or empty.');
  }

  return .right(url);
}
```


## Step 3: Compose the Pipeline

Now, bring the pieces together. Your `loadConfig` function will return an `Either<String, AppConfig>`. 

If your database URL validation fails, the pipeline halts and returns the error. If it succeeds, it builds and returns your `AppConfig`.

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


## Step 4: Execute and Match the Result

With your type-safe pipeline built, you can load your configuration. Because Daxle's `Either` uses Dart's sealed classes, the compiler forces you to handle both success (`Right`) and failure (`Left`) cases. You never forget to handle an error again.

```dart
import 'package:daxle/daxle.dart';

void main() {
  // Scenario 1: A Valid Environment
  final validEnv = {
    'PORT': '9000',
    'DATABASE_URL': 'postgres://localhost:5432/mydb',
  };

  final result1 = loadConfig(validEnv);
  final message1 = switch (result1) {
    Left(value: final err) => 'Initialization Failed: $err',
    Right(value: final config) => 'Service started successfully! Config: $config',
  };
  print(message1);
  // Prints: Service started successfully! Config: AppConfig(port: 9000, databaseUrl: postgres://localhost:5432/mydb)

  // Scenario 2: Missing Database URL
  final invalidEnv = {
    'PORT': 'invalid_port_will_fallback_to_8080',
  };

  final result2 = loadConfig(invalidEnv);
  final message2 = switch (result2) {
    Left(value: final err) => 'Initialization Failed: $err',
    Right(value: final config) => 'Service started successfully! Config: $config',
  };
  print(message2);
  // Prints: Initialization Failed: Critical Error: DATABASE_URL is missing or empty.
}
```


## What's Next?

You just built a type-safe, error-proof pipeline. You used `Option` to eliminate unsafe null checks and `Either` to make errors predictable and safe.

Here's how to level up:

* **[Master Core Types](/core-types/option)**: Learn the full power of `Option` and `Either`.
* **[Control Async Logic](/core-types/task)**: Design lazy, composable asynchronous pipelines using `Task` and `TaskEither`.
