---
outline: deep
---

# Error Handling

In standard Dart applications, unexpected situations are usually handled by throwing exceptions. While exceptions are useful for developer bugs (like passing a null value where it isn't expected) or unrecoverable system failures (like out of memory errors), using exceptions for expected domain errors is fragile and hard to scale.

Daxle provides a type-safe alternative: treating errors as explicit, first-class values.

---

## The Problem with Exceptions

When a function throws an exception, that behavior is invisible in the function's type signature. 

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

1. **Hidden Failures**: You cannot tell by looking at `loadConfig` that it can fail, nor what exceptions it might throw. You must read its implementation details or trust its documentation.
2. **Missing Compiler Help**: If you forget to wrap this call in a `try-catch` block, your application might crash at runtime. The compiler cannot help you verify that you handled the failure case.
3. **Control Flow Inversion**: Exceptions interrupt the natural flow of your code, jumping to the nearest matching `catch` block. This makes it difficult to chain operations or recover gracefully inside data pipelines.

---

## The Solution: Errors as Values

Instead of jumping out of the program execution when something goes wrong, we return a data structure that explicitly represents either success or failure.

Daxle provides two primary types for this:
* **`Either<L, R>`** for synchronous computations.
* **`TaskEither<L, R>`** for asynchronous computations.

By convention:
* **`Left` (holding a value of type `L`)** represents the failure or error case.
* **`Right` (holding a value of type `R`)** represents the success case.

Using explicit error types, the `loadConfig` function becomes self-documenting:

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

Now, the compiler guarantees that callers of `loadConfigSafe` cannot access the `Config` without acknowledging that the operation might have returned a `ConfigError`.

---

## Working with Errors and Successes

Once an operation returns an `Either`, you can transform, validate, and extract values cleanly.

### Chaining Dependent Operations

If you need to perform multiple fallible operations in a sequence, use `flatMap`. If any step returns a `Left`, the rest of the chain is skipped, and the error propagates to the end of the pipeline.

```dart
Either<ConfigError, String> extractDatabaseUrl(String configPath) {
  return loadConfigSafe(configPath) // returns Either<ConfigError, Config>
      .flatMap((config) => config.dbUrl != null
          ? Either.right(config.dbUrl!)
          : Either.left(InvalidFormat('Database URL is missing in config')));
}
```

### Transforming Errors

Intermediate errors can be converted using `mapLeft`. This is particularly useful when translating lower-level exceptions or library errors into your high-level domain errors.

```dart
// Convert a generic filesystem or network error to a domain-specific one
Either<DomainError, Data> processLocalFile(String path) {
  return loadFile(path) // Either<FileSystemException, FileData>
      .mapLeft((fsException) => DomainError.storageAccessFailed(fsException.message));
}
```

### Unwrapping and Resolving Results

At the end of your pipeline, you must handle both cases. The most common way to resolve an `Either` is by using `fold`. The `fold` method takes two functions: one for the `Left` (failure) case and one for the `Right` (success) case, returning a single merged result.

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

---

## When to Use Either vs. Exceptions

Using explicit errors does not mean you should never use `throw` or `try-catch`. They both have their places in a healthy codebase:

| Scenario | Recommended Approach | Reason |
| :--- | :--- | :--- |
| **Domain Logic & I/O** | `Either` / `TaskEither` | Failures (like a missing file, a validation error, or a failed network response) are expected parts of normal execution. They should be typed and explicitly handled. |
| **Developer Errors** | `ArgumentError` / `StateError` | Program bugs (like calling a method in the wrong state or passing invalid parameters) should fail fast and crash the app during development to make them obvious. |
| **System Failures** | `OutOfMemoryError` | Unrecoverable infrastructure failures cannot be recovered from. There is no benefit to wrapping them in an `Either`. |
