---
outline: deep
---

# Either

Representing a value of one of two possible types—typically failure or success.

---

## What is it?

`Either<L, R>` represents a value that can belong to one of two different types:
* `Left<L, R>`: Holds a value of type `L` (by convention, used for **failures** or **errors**).
* `Right<L, R>`: Holds a value of type `R` (by convention, used for **success**).

In standard Dart, unexpected issues are handled by throwing exceptions. While exceptions are useful for developer bugs or fatal system states, they are difficult to enforce at compile-time. `Either` brings error handling into the type system, forcing you and other developers to handle potential failure cases explicitly.

---

## Why use it?

Using `Either` instead of throwing exceptions offers several advantages:

1. **Self-Documenting Code**: A function signature like `Either<ParseError, Config> parseConfig(String data)` clearly warns the caller that the function can fail and specifies exactly what kind of error to expect.
2. **Compile-Time Safety**: Dart's compiler will prevent you from accessing the success value without checking or handling the failure value first.
3. **Safe Composition**: You can chain multiple fallible operations together. If any operation fails, the failure is propagated automatically down the pipeline.

Compare standard exception handling to `Either`:

```dart
// Standard Dart exceptions (untyped and hidden from signature)
Config loadConfig(String path) {
  final file = File(path);
  if (!file.existsSync()) throw ConfigFileNotFoundException();
  final content = file.readAsStringSync();
  return Config.fromJson(content); // might throw FormatException
}

// Using Either (fully typed and explicit)
Either<ConfigError, Config> loadConfigSafe(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return Either.left(ConfigError.notFound(path));
  }
  
  return Either.tryCatch(
    () => Config.fromJson(file.readAsStringSync()),
    (error, _) => ConfigError.invalidFormat(error.toString()),
  );
}
```

---

## Basic Example

Here is a practical example of parsing and validating a domain-specific value, such as a username. A username must not be empty, must not exceed a certain length, and must contain only alphanumeric characters.

```dart
import 'package:daxle/daxle.dart';

// Domain errors representable as types
sealed class ValidationError {
  final String message;
  const ValidationError(this.message);
}

class EmptyInput extends ValidationError {
  const EmptyInput() : super('Input cannot be empty');
}

class TooLong extends ValidationError {
  final int max;
  const TooLong(this.max) : super('Input exceeds maximum length of $max');
}

// Function returning Either
Either<ValidationError, String> validateUsername(String rawInput) {
  final cleaned = rawInput.trim();
  if (cleaned.isEmpty) {
    return Either.left(const EmptyInput());
  }
  if (cleaned.length > 15) {
    return Either.left(TooLong(15));
  }
  return Either.right(cleaned);
}

void main() {
  final inputs = ['', 'verylongusernamehere', 'validName'];

  for (final input in inputs) {
    final result = validateUsername(input);
    
    final message = result.fold(
      (error) => 'Validation failed: ${error.message}',
      (success) => 'Validated username: $success',
    );
    print(message);
  }
  // Prints:
  // Validation failed: Input cannot be empty
  // Validation failed: Input exceeds maximum length of 15
  // Validated username: validName
}
```

---

## Common Operations

### Creating Either Values

```dart
// 1. Direct construction
final success = Either.right(100);
final failure = Either.left('Something went wrong');

// 2. Based on a boolean condition
final isWeekend = false;
final rate = Either.cond(isWeekend, 1.5, 1.0); // Right(1.0)

// 3. Wrapping synchronous operations that can throw exceptions
final parsed = Either.tryCatch(
  () => Uri.parse('https://daxle.dev'),
  (error, stackTrace) => 'Invalid URL: $error',
);
```

### Inspecting State

```dart
final result = Either.right('data');

if (result.isRight) print('Operation succeeded');
if (result.isLeft) print('Operation failed');
```

### Transforming Success values (`map` / `flatMap`)

Operations on the success side (`Right`) are chained using `.map()` and `.flatMap()`. If the value is a `Left`, the transformation is skipped:

```dart
final original = Either.right(' 100 ');

// map: Transforms the success value synchronously
final doubled = original.map((s) => s.trim()).map(int.parse).map((n) => n * 2);
// Result: Right(200)

// flatMap: Chains another fallible operation returning an Either
final processed = original
    .map((s) => s.trim())
    .flatMap((s) => Either.tryCatch(
          () => int.parse(s),
          (e, _) => 'Failed to parse integer',
        ));
// Result: Right(100)
```

### Transforming Error values (`mapLeft` / `bimap`)

Sometimes you want to convert or enrich errors, or modify both sides of the computation:

```dart
final error = Either.left('database_error');

// mapLeft: Converts the Left error type
final domainError = error.mapLeft((dbErr) => 'Failed operation due to $dbErr');
// Result: Left('Failed operation due to database_error')

// bimap: Transforms both sides simultaneously
final mapped = error.bimap(
  (l) => 'Log failure: $l',
  (r) => 'Log success: $r',
);
```

### Pipelines and Validation (`ensure`)

Use `ensure` to check if a successful value meets certain requirements. If it fails, the value is converted to a `Left` with a specified fallback:

```dart
final rate = Either.right(85);

final validated = rate.ensure(
  (n) => n >= 0 && n <= 100,
  () => 'Rate must be between 0 and 100',
);
```

### Side Effects (`tap` / `tapLeft`)

Run callbacks without modifying the values flowing through the pipeline:

```dart
final result = Either.right('file_contents');

final logged = result
    .tap((content) => print('Length: ${content.length}'))
    .tapLeft((err) => print('Error occurred: $err'));
```

### Recovery (`orElse` / `getOrElse`)

Extract the successful value or recover from an error:

```dart
final result = Either.left('cache_miss');

// getOrElse: Provides a default fallback value (takes a function containing the error)
final val = result.getOrElse((error) => 'default_value'); // 'default_value'

// orElse: Provides a fallback Either computation
final recovered = result.orElse((error) => Either.right('recovered_value')); // Right('recovered_value')
```

### Batch Operations (`sequence` / `traverse`)

Combine multiple `Either` operations:

* `sequence`: Turns a list of `Either`s into an `Either` of a list. If any item is a `Left`, it stops and returns that error.
* `traverse`: Maps a list of items to `Either`s and collects the results. If any item maps to a `Left`, it stops and returns that error.

```dart
final results = [Either.right(1), Either.right(2), Either.right(3)];
final combined = Either.sequence(results); // Right([1, 2, 3])

final inputs = ['10', '20', '30'];
final parsedList = Either.traverse(
  inputs,
  (str) => Either.tryCatch(() => int.parse(str), (e, _) => 'Failed to parse $str'),
); // Right([10, 20, 30])
```

---

## Composition

`Either` works seamlessly with other Daxle types. In the following example, we convert an `Option` to an `Either` (using `fold`), letting us attach an error message to a missing value:

```dart
Either<String, User> findUser(String id, Map<String, User> db) {
  final userOpt = Option.fromNullable(db[id]);
  
  return userOpt.fold(
    () => Either.left('User $id not found'),
    (user) => Either.right(user),
  );
}
```

---

## Best Practices

* **Create Custom Error Classes**: Avoid using simple strings (like `Either<String, Data>`) for your `Left` type. Create structured sealed hierarchies of errors. This allows you to match on specific errors using Dart's pattern matching.
* **Wrap tryCatch at the boundaries**: Don't sprinkle `tryCatch` throughout your business logic. Use it at repository or API boundaries to catch low-level library exceptions, convert them to typed domain errors, and return `Either`.
* **Prefer `fold` for resolving**: Instead of using `.isRight` and extracting manually, always use `.fold()` to handle both success and failure cases. This ensures that you have covered all paths.

---

## Common Mistakes

* **Treating `Left` as an exception**: Do not throw `Left` values. `Either` is designed to flow naturally through function returns.
* **Using `getOrElse` to ignore errors**: Calling `getOrElse` with a generic default value prematurely can hide bugs. Only fallback when a default makes sense in the current context.

---

## When to Use

* For business logic, validation, and domain-layer operations where errors are expected and need to be handled by the caller.
* When returning data from repositories, local databases, or parses where a failure is a normal, expected outcome.

### When NOT to Use

* For developer errors (e.g., passing an invalid parameter that violates a programming contract). Use standard Dart `ArgumentError` or `StateError` and let the application crash or fail fast.

---

## API Overview

### Classes

| Class | Description |
|---|---|
| `Either<L, R>` | Sealed class representing a value of type `L` (Left) or `R` (Right). |
| `Left<L, R>` | Represents the Left side of `Either`, containing the error value. |
| `Right<L, R>` | Represents the Right side of `Either`, containing the success value. |

### Constructors / Factories

| Constructor | Description |
|---|---|
| `Either.left(L value)` | Creates a `Left` instance holding the failure value. |
| `Either.right(R value)` | Creates a `Right` instance holding the success value. |
| `Either.cond(bool condition, R right, L left)` | Returns `Right` if `condition` is true, otherwise `Left`. |
| `Either.tryCatch(R Function() run, L Function(Object, StackTrace) onError)` | Runs a synchronous block, catching any exception and converting it to a `Left`. |

### Properties & Getters

| Property | Type | Description |
|---|---|---|
| `isLeft` | `bool` | Returns `true` if this is a `Left` instance. |
| `isRight` | `bool` | Returns `true` if this is a `Right` instance. |

### Methods

| Method | Return Type | Description |
|---|---|---|
| `fold<B>(B Function(L) ifLeft, B Function(R) ifRight)` | `B` | Projects the value to `B` depending on whether it is `Left` or `Right`. |
| `map<B>(B Function(R) f)` | `Either<L, B>` | Transforms the success value (`Right`). |
| `mapLeft<B>(B Function(L) f)` | `Either<B, R>` | Transforms the error value (`Left`). |
| `bimap<L2, R2>(L2 Function(L) mapLeft, R2 Function(R) mapRight)` | `Either<L2, R2>` | Transforms both the error and success values simultaneously. |
| `flatMap<B>(Either<L, B> Function(R) f)` | `Either<L, B>` | Chains another fallible operation. |
| `tap(void Function(R) callback)` | `Either<L, R>` | Runs a callback on success without modifying the value. |
| `tapLeft(void Function(L) callback)` | `Either<L, R>` | Runs a callback on failure without modifying the error. |
| `ensure(bool Function(R) predicate, L Function() onFailure)` | `Either<L, R>` | Converts `Right` to `Left` if the predicate is not met. |
| `orElse(Either<L, R> Function(L) f)` | `Either<L, R>` | Fallback computation if this is a `Left`. |
| `getOrElse(R Function(L) dflt)` | `R` | Extracts the success value or returns the result of the fallback function `dflt`. |

### Static Methods

| Method | Return Type | Description |
|---|---|---|
| `sequence<L, R>(Iterable<Either<L, R>> items)` | `Either<L, List<R>>` | Sequentially collects results of a list of `Either` objects. |
| `traverse<L, A, B>(Iterable<A> items, Either<L, B> Function(A) mapper)` | `Either<L, List<B>>` | Maps a list to `Either`s and collects results. |

---

## Related Types

* [Option](option) - A simpler container for optional values where there is no specific error information.
* [TaskEither](task-either) - The asynchronous version of `Either` (lazy async computations that can fail).
