---
outline: deep
---

# Error Handling

Dart handles unexpected problems by throwing exceptions. That works fine for developer bugs or crashing systems. But relying on exceptions for expected domain errors? That makes your app fragile and impossible to scale.

Daxle gives you a bulletproof alternative: **treat errors as explicit, first-class values.**


## Why Exceptions Sabotage Your Code

When a function throws an exception, that danger is invisible in the function's type signature. 

```dart
// The signature claims this always returns a Config, but it can throw!
Config loadConfig(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw ConfigFileNotFoundException(path);
  }
  return Config.fromJson(file.readAsStringSync());
}
```

This model has several downsides:

1. **Hidden Failures**: You can't trust the signature. You have to dig into the implementation to find out what might explode.
2. **No Compiler Help**: Forget a `try-catch` block? Your app crashes in production. The compiler won't save you.
3. **Broken Control Flow**: Exceptions hijack your code's natural flow, jumping to random `catch` blocks and ruining data pipelines.


## The Fix: Make Errors Visible Values

Stop jumping out of your program. Return explicit data structures that represent success or failure.

Daxle arms you with two core types:
* **`Either<L, R>`** for synchronous tasks.
* **`TaskEither<L, R>`** for asynchronous tasks.

The rules are simple:
* **`Left`** holds the failure (`L`).
* **`Right`** holds the success (`R`).

By using explicit errors, your functions document themselves:

```dart
import 'dart:io';
import 'package:daxle/daxle.dart';

// 1. Define domain errors as a type hierarchy
sealed class ConfigError {}
class FileNotFound extends ConfigError {
  final String path;
  FileNotFound(this.path);
}
class InvalidFormat extends ConfigError {
  final String details;
  InvalidFormat(this.details);
}

// 2. The type signature now explicitly warns callers about failures
Either<ConfigError, Config> loadConfigSafe(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return Either.left(FileNotFound(path));
  }

  return Either.tryCatch(
    () => Config.fromJson(file.readAsStringSync()),
    (error, _) => InvalidFormat(error.toString()),
  );
}
```

Now, the compiler forces every caller to acknowledge that `loadConfigSafe` might fail. No more surprise crashes.


## Mastering Success and Failure

Transform, validate, and extract values effortlessly once you have an `Either`.

### Chain Operations Without Fear

Need to run fallible operations in sequence? Use `flatMap`. If one step fails, Daxle skips the rest and safely delivers the error to the end of the pipeline.

```dart
Either<ConfigError, String> extractDatabaseUrl(String configPath) {
  return loadConfigSafe(configPath) // returns Either<ConfigError, Config>
      .flatMap((config) => config.dbUrl != null
          ? Either.right(config.dbUrl!)
          : Either.left(InvalidFormat('Database URL is missing in config')));
}
```

### Translate Errors Easily

Translate cryptic low-level exceptions into clear domain errors using `mapLeft`.

```dart
// Convert a generic filesystem or network error to a domain-specific one
Either<DomainError, Data> processLocalFile(String path) {
  return loadFile(path) // Either<FileSystemException, FileData>
      .mapLeft((fsException) => DomainError.storageAccessFailed(fsException.message));
}
```

### Resolve Your Results Safely

Use `fold` to finalize your pipeline. It forces you to handle both success and failure cleanly, giving you absolute peace of mind.

```dart
void applyConfig(String path) {
  final result = loadConfigSafe(path);

  final message = result.fold(
    (error) => switch (error) {
      FileNotFound(:final path) => 'Configuration file not found at $path',
      InvalidFormat(:final details) => 'Invalid JSON formatting: $details',
    },
    (config) => 'Configuration applied successfully on port ${config.port}!',
  );

  print(message);
}
```


## Either vs. Exceptions: The Cheatsheet

Using explicit errors doesn't mean deleting `throw` or `try-catch`. They both have their places in a healthy codebase:

| Scenario | Recommended Approach | Reason |
| :--- | :--- | :--- |
| **Domain Logic & I/O** | `Either` / `TaskEither` | Failures (like a missing file, a validation error, or a failed network response) are expected parts of normal execution. They should be typed and explicitly handled. |
| **Developer Errors** | `ArgumentError` / `StateError` | Program bugs (like calling a method in the wrong state or passing invalid parameters) should fail fast and crash the app during development to make them obvious. |
| **System Failures** | `OutOfMemoryError` | Unrecoverable infrastructure failures cannot be recovered from. There is no benefit to wrapping them in an `Either`. |
