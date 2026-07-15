---
outline: deep
---

# Option

Explicitly representing the presence or absence of a value.

---

## What is it?

`Option<T>` is a type that represents a value that may or may not be present. It can be in one of two states:
* `Some<T>`: Contains a value of type `T`.
* `None<T>`: Represents the absence of a value.

In Dart, we often use nullable types (`T?`) for optional values. While `T?` is convenient, `Option<T>` provides a fluent, type-safe API for transforming, chaining, and combining optional values without writing nested `if` statements or using the null-assertion operator (`!`).

---

## Why use it?

While Dart's built-in null safety is powerful, it has several limitations:

1. **Repetitive Null Checks**: When transforming a value, you often have to check if it's null before performing the next step.
2. **Difficult Chaining**: Chaining multiple operations that might return null requires nested null checks or verbose ternary operators.
3. **Inability to Represent Nested Nullability**: You cannot easily distinguish between "we didn't receive a value" and "we received a value, but the value itself is null" using standard `T?`.

`Option` provides a structured alternative. Instead of writing:

```dart
// Using standard nullable types
int? processInput(String? input) {
  if (input != null) {
    final cleaned = input.trim();
    if (cleaned.isNotEmpty) {
      final parsed = int.tryParse(cleaned);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
  }
  return null;
}
```

With `Option`, you write a clean, declarative pipeline:

```dart
// Using Option
Option<int> processInput(String? input) {
  return Option.fromNullable(input)
      .map((str) => str.trim())
      .filter((str) => str.isNotEmpty)
      .flatMap((str) => Option.fromNullable(int.tryParse(str)))
      .filter((val) => val > 0);
}
```

---

## Basic Example

Here is a basic example of extracting a key-value pair from a log entry. The log entry might be malformed or might not contain the key.

```dart
import 'package:daxle/daxle.dart';

// Safely gets a value from a simple log string key=value
Option<String> getValue(String logLine, String key) {
  final prefix = '$key=';
  if (!logLine.contains(prefix)) {
    return const Option.none();
  }
  final value = logLine.split(prefix).last.split(' ').first;
  return Option.some(value);
}

void main() {
  final line = 'level=info timestamp=1690000000 trace_id=abcdef123';
  
  // Extract and print the trace ID
  final traceId = getValue(line, 'trace_id');
  
  final message = traceId.fold(
    () => 'Trace ID not found',
    (id) => 'Trace ID is: $id',
  );
  
  print(message); // Prints: Trace ID is: abcdef123
}
```

---

## Common Operations

### Creating Options

You can create an `Option` in four ways:

```dart
// 1. Explicitly wrapping a value
final someVal = Option.some(42);
final noneVal = const Option.none();

// 2. From a nullable value (returns None if null)
final parsed = Option.fromNullable(int.tryParse('abc')); // None

// 3. Based on a predicate condition
final name = Option.fromPredicate('Dart', (str) => str.isNotEmpty); // Some('Dart')
final emptyName = Option.fromPredicate('', (str) => str.isNotEmpty); // None
```

### Inspecting State

You can inspect whether an option has a value:

```dart
final opt = Option.some('value');

if (opt.isSome) print('Has value!');
if (opt.isNone) print('Empty!');
```

### Transforming Values

Transform the value inside an `Option` without checking if it exists. If the option is `None`, these operations do nothing:

```dart
final option = Option.some(' 123 ');

// map: Transforms the inner value synchronously
final doubled = option.map((s) => s.trim()).map(int.parse).map((n) => n * 2); 
// Result: Some(246)

// flatMap: Transforms to another Option (useful for operations that can return None)
final parsed = option.map((s) => s.trim()).flatMap((s) => Option.fromNullable(int.tryParse(s)));
// Result: Some(123)

// filter: Keeps the value if it matches the predicate, otherwise returns None
final filtered = option.map((s) => s.trim()).map(int.parse).filter((n) => n > 200);
// Result: None
```

### Extracting Values Safely

Retrieve the inner value safely when you reach the end of your pipeline:

```dart
final opt = Option.fromNullable(int.tryParse('not_a_number'));

// 1. Provide a default fallback value
final value1 = opt.getOrElse(0); // 0

// 2. Pattern match or fold to handle both cases
final value2 = opt.fold(
  () => 'Fallback string',
  (val) => 'Found value: $val',
);

// 3. Convert back to standard nullable type
final int? value3 = opt.toNullable(); // null
```

---

## Composition

`Option` composes cleanly with itself and other types. Here, we parse a log string, extract an option, and chain another step:

```dart
class LogConfig {
  final int logLevel;
  LogConfig(this.logLevel);
}

Option<LogConfig> parseLogConfig(Map<String, String> env) {
  return Option.fromNullable(env['LOG_LEVEL'])
      .flatMap((s) => Option.fromNullable(int.tryParse(s)))
      .filter((level) => level >= 0 && level <= 5)
      .map((level) => LogConfig(level));
}
```

---

## Best Practices

* **Prefer `getOrElse` or `fold` over `get`**: Avoid calling `.get()`. It will throw a `StateError` if the option is `None`. Always use safe extraction methods.
* **Avoid `isSome` + `get`**: Checking `.isSome` before calling `.get()` is an anti-pattern that replicates standard `null` checks. Use `.map()`, `.flatMap()`, `.filter()`, or `.fold()` to interact with the value.
* **Wrap nullable APIs early**: When interacting with libraries or standard APIs that return nullable types, immediately wrap the results in `Option.fromNullable` to begin chaining.
* **Leverage pattern matching**: Dart 3 pattern matching works beautifully with the `Some` and `None` classes:
  ```dart
  switch (option) {
    case Some(:final value):
      print('Value: $value');
    case None():
      print('No value found');
  }
  ```

---

## Common Mistakes

* **Calling `.get()` blindly**: Using `.get()` is unsafe and will crash your application if the value is absent. Treat it like Dart's `!` operator.
* **Nesting `Option` inside `Option`**: If you use `.map()` with a function that returns an `Option`, you will end up with `Option<Option<T>>`. Use `.flatMap()` instead to keep the pipeline flat.
* **Using `Option` everywhere**: For simple, local variables where a standard Dart `?` null-aware operator (`val?.someProperty`) is clear and readable, standard null safety is perfectly fine. Use `Option` when you need complex chaining, transformations, or passing optional values through generic interfaces.

---

## When to Use

* When you want to construct complex pipelines where multiple steps can return empty results.
* In generic classes, repositories, or services where you need to represent optional returns explicitly in type signatures (e.g., `Option<User>`).
* To safely wrap nullable values returned from third-party APIs.

### When NOT to Use

* For simple, single-level null checks where a standard `if (value != null)` or `value ?? fallback` is more readable.

---

## API Overview

### Classes

| Class | Description |
|---|---|
| `Option<T>` | Sealed class representing the presence or absence of a value of type `T`. |
| `Some<T>` | A class representing the presence of a value. Subclass of `Option<T>`. |
| `None<T>` | A class representing the absence of a value. Subclass of `Option<T>`. |

### Constructors

| Constructor | Description |
|---|---|
| `Option.some(T value)` | Creates an `Option` containing `value`. |
| `Option.none()` | Creates an `Option` representing the absence of a value. |
| `Option.fromNullable(T? value)` | Returns `Some` if the value is not null, otherwise `None`. |
| `Option.fromPredicate(T value, bool Function(T) predicate)` | Returns `Some` wrapping `value` if it matches `predicate`, otherwise `None`. |

### Properties & Getters

| Property | Type | Description |
|---|---|---|
| `isSome` | `bool` | Returns `true` if this is a `Some` instance. |
| `isNone` | `bool` | Returns `true` if this is a `None` instance. |

### Methods

| Method | Return Type | Description |
|---|---|---|
| `fold<B>(B Function() ifNone, B Function(T value) ifSome)` | `B` | Resolves the option to a value of type `B`. |
| `map<B>(B Function(T value) f)` | `Option<B>` | Transforms the inner value using `f` if present. |
| `flatMap<B>(Option<B> Function(T value) f)` | `Option<B>` | Transforms the inner value to a new `Option` using `f`. |
| `get()` | `T` | Returns the inner value. Throws `StateError` if `None`. |
| `getOrElse(T dflt)` | `T` | Returns the inner value, or `dflt` if `None`. |
| `toNullable()` | `T?` | Converts this `Option` back to a nullable value. |
| `filter(bool Function(T value) predicate)` | `Option<T>` | Filters the option, converting to `None` if the predicate fails. |

---

## Related Types

* [Unit](unit) - Often used with `Option` (e.g., `Option<Unit>`) to represent optional actions with no return value.
* [Either](either) - Use when the absence of a value represents a failure that requires an error description.
