---
outline: deep
---

# Quick Start

Welcome to the Daxle Quick Start guide! In this tutorial, we will walk you through building a simple yet robust, production-ready configuration parser. 

You'll discover firsthand how to handle optional values, rigorously validate inputs, and effectively manage domain errors using Daxle's powerful paradigms—all without throwing a single exception or resorting to the notorious `null`.

---

## The Scenario

Imagine we are tasked with building a backend service (or a Flutter application) that critically relies on a configuration object loaded from environment variables (represented as a `Map<String, String>`). 

Our configuration has two key requirements:

1. **Port (Optional but Validated)**: We expect an optional port number. If provided, it absolutely must be a valid integer between `1024` and `65535`. If it's missing or invalid, our application should seamlessly fall back to a default port (`8080`).
2. **Database URL (Required)**: A valid connection string is mandatory. If it is missing or empty, the application simply cannot function and must clearly report a configuration error, rather than crashing unpredictably later on.

Here is the Dart class representing our target configuration object:

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

## Step 1: Elegantly Handling the Optional Port with `Option`

In standard Dart, extracting and validating this optional port safely typically involves a cascade of conditional checks and intermediate variables:

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

While functional, this approach is visually noisy and hides the actual intent. With Daxle, we can express this entire validation flow as a single, highly readable declarative pipeline using `Option`. 

Notice how we leverage Daxle's convenient dot-shorthand constructors (`.fromNullable`) to effortlessly wrap values:

```dart
import 'package:daxle/daxle.dart';

int parsePort(Map<String, String> env) {
  final port = int.tryParse(env['PORT'] ?? '');

  return .fromNullable(port) // Securely wraps the potential null into an Option<int>
      .filter((p) => p >= 1024 && p <= 65535) // Discards the value if it's an invalid port
      .getOrElse(8080); // Provides our default fallback if the Option is empty
}
```

---

## Step 2: Enforcing the Required Database URL with `Either`

The database URL is a non-negotiable parameter. If it's absent, we want our system to fail gracefully and immediately, returning a descriptive error message instead of throwing a generic runtime exception that might be caught at the wrong level.

We model this perfectly using `Either<String, String>`. In Daxle, the left side (`Left`) conventionally holds the error message, while the right side (`Right`) holds the successfully validated URL.

We can gracefully handle the conditional branching and directly return our designated states using `.left` and `.right`:

```dart
import 'package:daxle/daxle.dart';

Either<String, String> parseDatabaseUrl(Map<String, String> env) {
  final url = env['DATABASE_URL'];

  if (url == null || url.isEmpty) {
    return .left('Critical Error: DATABASE_URL configuration is missing or empty.');
  }

  return .right(url);
}
```

---

## Step 3: Seamlessly Composing the Pipeline

Now, the magic happens. Let's combine these isolated steps to instantiate our complete `AppConfig`. Our overarching load function will return an `Either<String, AppConfig>`. 

If the crucial database URL validation fails, the entire pipeline smartly halts and returns the error. If it succeeds, we smoothly construct and return our fully populated configuration object.

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

## Step 4: Executing and Exhaustively Matching the Result

With our type-safe pipeline established, we can load our configuration and handle both the success and failure scenarios explicitly. Because Daxle's `Either` is meticulously built upon Dart's sealed classes, the compiler will act as our vigilant assistant, actively warning us if we ever forget to handle either the `Left` (error) or `Right` (success) cases!

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

  // Scenario 2: An Invalid Environment (Missing required Database URL)
  final invalidEnv = {
    'PORT': 'invalid_port_will_fallback_to_8080',
  };

  final result2 = loadConfig(invalidEnv);
  final message2 = switch (result2) {
    Left(value: final err) => 'Initialization Failed: $err',
    Right(value: final config) => 'Service started successfully! Config: $config',
  };
  print(message2);
  // Prints: Initialization Failed: Critical Error: DATABASE_URL configuration is missing or empty.
}
```

---

## What's Next on Your Journey?

Congratulations! You've just architected your very first robust, type-safe pipeline using Daxle. You have witnessed firsthand how `Option` elegantly eradicates unsafe null checks, and how `Either` promotes errors to first-class citizens, ensuring your code remains predictable and exceptionally safe.

* **Dive Deeper into Core Types**: Explore the intricacies of [Option](/core-types/option) and [Either](/core-types/either) in our dedicated Core Types section.
* **Master Asynchronous Control**: Discover how to design lazy, composable asynchronous pipelines using [Task](/core-types/task) and [TaskEither](/core-types/task-either).
