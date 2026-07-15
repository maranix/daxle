---
outline: deep
---

# Either

Make your errors impossible to ignore.

---

## What is Either?

`Either<L, R>` forces you to handle both failure and success directly inside the type system.

It guarantees that a value holds one of two possible outcomes:
* `Left<L>`: Represents a **failure** or error.
* `Right<R>`: Represents a **success**.

Instead of relying on hidden exceptions that crash your app when forgotten, `Either` brings your errors to the surface. It proves at compile-time that your code is safe.

---

## Why you need it

Standard Dart exceptions are invisible. When you call a function, the signature doesn't warn you if it might throw. You just have to remember to wrap it in a `try-catch` block—and when you forget, your application breaks.

`Either` makes failure a core feature of your architecture:

1. **Self-Documenting Code**: A signature like `Either<NetworkError, User>` tells everyone exactly what can go wrong. No guessing required.
2. **Bulletproof Safety**: Dart's compiler physically stops you from accessing the success data without explicitly handling the failure case first.
3. **Seamless Error Propagation**: Chain multiple risky operations together. If any single step fails, `Either` automatically short-circuits and safely passes the error down the line.

```dart
// The Old Way: Hidden exceptions and crashes
Config loadConfig(String path) {
  final file = File(path);
  if (!file.existsSync()) throw ConfigFileNotFoundException();
  return Config.fromJson(file.readAsStringSync()); 
}

// The Either Way: Fully typed, explicit, and safe
Either<ConfigError, Config> loadSafe(String path) {
  final file = File(path);
  if (!file.existsSync()) return Either.left(ConfigError.notFound(path));
  
  return Either.tryCatch(
    () => Config.fromJson(file.readAsStringSync()),
    (error, _) => ConfigError.invalidFormat(error.toString()),
  );
}
```

---

## See it in action

Here is how you validate critical domain data, returning specific, typed errors when things go wrong:

```dart
import 'package:daxle/daxle.dart';

// 1. Define explicit domain errors
sealed class ValidationError {
  final String message;
  const ValidationError(this.message);
}
class EmptyInput extends ValidationError {
  const EmptyInput() : super('Input cannot be empty');
}
class TooLong extends ValidationError {
  const TooLong(this.max) : super('Maximum length is $max');
}

// 2. Validate safely
Either<ValidationError, String> validateUsername(String rawInput) {
  final cleaned = rawInput.trim();
  if (cleaned.isEmpty) return Either.left(const EmptyInput());
  if (cleaned.length > 15) return Either.left(const TooLong(15));
  
  return Either.right(cleaned);
}

void main() {
  final result = validateUsername('verylongusernamehere');
  
  // 3. The compiler forces you to handle both outcomes
  result.fold(
    (error) => print('Failed: ${error.message}'),
    (success) => print('Success: $success'),
  );
}
```

---

## Common Operations

### Create an Either

```dart
// Explicit outcomes
final success = Either.right(100);
final failure = Either.left('Missing data');

// Wrap risky code that throws exceptions
final parsed = Either.tryCatch(
  () => Uri.parse('https://daxle.dev'),
  (error, stackTrace) => 'Invalid URL: $error',
);
```

### Chain and Transform Data (`map` / `flatMap`)

Shape your success data confidently. If a step fails, subsequent transformations are skipped automatically.

```dart
final original = Either.right(' 100 ');

// map: Alter the success value
final doubled = original.map((s) => s.trim()).map(int.parse).map((n) => n * 2);

// flatMap: Chain into another risky operation
final processed = original
    .map((s) => s.trim())
    .flatMap((s) => Either.tryCatch(
          () => int.parse(s),
          (e, _) => 'Failed to parse',
        ));
```

### Transform Errors (`mapLeft`)

Adapt your errors as they move through different architectural layers (e.g., mapping a low-level Database error to a high-level Domain error):

```dart
final error = Either.left('db_timeout');

final domainError = error.mapLeft((dbErr) => 'System busy: $dbErr');
```

### Validate In-Flight (`ensure`)

Test your success values mid-pipeline. If the test fails, inject a custom error to halt the flow.

```dart
final rate = Either.right(85);

final validated = rate.ensure(
  (n) => n >= 0 && n <= 100,
  () => 'Rate out of bounds',
);
```

### Recover and Resolve (`orElse` / `getOrElse` / `fold`)

Handle errors gracefully when you reach the end of your logic.

```dart
final result = Either.left('cache_miss');

// Fallback to a default value
final val = result.getOrElse((error) => 'default'); 

// Fallback to another operation entirely
final recovered = result.orElse((error) => Either.right('backup_data')); 

// Process both branches cleanly
result.fold(
  (error) => handleError(error),
  (data) => renderData(data),
);
```

---

## Best Practices

* **Use Custom Error Classes**: Don't just use strings (`Either<String, Data>`). Build sealed classes for your errors so you can handle them precisely using Dart's pattern matching.
* **Wrap Exceptions at the Edges**: Don't scatter `tryCatch` everywhere. Use it right at the boundary where you talk to libraries or databases, converting their untyped exceptions into your typed domain errors.
* **Always Fold**: Stop checking `.isRight`. Use `.fold()` at the end of your pipeline to guarantee every outcome is handled.

---

## Common Mistakes

* **Throwing Lefts**: Never `throw` a `Left` value. `Either` is built to flow smoothly through your return types.
* **Ignoring Errors**: Using `.getOrElse()` too early hides valuable error data. Keep your errors in the `Either` until the absolute last moment where you need to display them to the user.

---

## Related Types

* [TaskEither](task-either) - The asynchronous powerhouse. Use this when your fallible operations require `await`.
* [Option](option) - A simpler tool for when data might be missing, but you don't need to specify *why*.
