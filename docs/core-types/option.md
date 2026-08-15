---
outline: deep
---

# Option

Handle missing values with absolute confidence and eliminate null-pointer crashes.


## What is Option?

`Option<T>` gives you a type-safe, declarative way to represent a value that might not exist. 

It lives in one of two clear states:
* `Some<T>`: You have the value.
* `None<T>`: The value is missing.

While Dart’s native `T?` handles simple optional values, `Option<T>` provides a fluid API that lets you transform and chain data safely—without cluttering your code with nested `if` blocks or risky `!` null-assertions.


## Why you need it

Dart's null safety prevents crashes, but it forces you into repetitive patterns when building complex logic:

1. **Repetitive Null Checks**: Every time you transform a nullable value, you must check it again.
2. **Messy Chaining**: Connecting multiple operations that might return null quickly turns into deeply nested spaghetti.
3. **Ambiguous Meaning**: A native `null` can't tell you the difference between "the request returned nothing" and "the request returned a null value."

`Option` solves this instantly. Compare the legacy way to the `Option` way:

```dart
// The old way: Fragile and nested
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

```dart
// The Option way: Flat, safe, and readable
Option<int> processInput(String? input) {
  return Option(input)
      .map((str) => str.trim())
      .filter((str) => str.isNotEmpty)
      .map(int.tryParse)
      .filter((val) => val > 0);
}
```


## See it in action

Here is how you safely extract data from an unpredictable log string:

```dart
import 'package:daxle/daxle.dart';

// Safely pluck a value from a log key=value string
Option<String> getValue(String logLine, String key) {
  final prefix = '$key=';
  if (!logLine.contains(prefix)) return const Option.none();
  
  final value = logLine.split(prefix).last.split(' ').firstOrNull;
  return Option.some(value);
}

void main() {
  final line = 'level=info timestamp=1690000000 trace_id=abcdef123';
  
  // Confidently extract the ID
  final traceId = getValue(line, 'trace_id');
  
  final message = traceId.fold(
    () => 'Trace ID not found',
    (id) => 'Trace ID is: $id',
  );
  
  print(message); // Prints: Trace ID is: abcdef123
}
```


## Common Operations

### Create an Option

In Daxle v4, `Option<T extends Object>` strictly enforces non-nullable type parameters `T extends Object`. Storing `null` inside `Some` is prohibited.

Use the smart factory constructor `Option(T? value)` to wrap nullable values—it automatically maps `null` to `None()` and non-null values to `Some(value)`.

```dart
// 1. Explicit state
final someVal = Option.some(42);
final noneVal = const Option.none();

// 2. Smart factory constructor (replaces removed Option.fromNullable)
final parsed = Option(int.tryParse('abc')); // Safely returns None()

// 3. Build from a condition
final name = Option.fromPredicate('Dart', (str) => str.isNotEmpty); 
```

### Transform the Data (`map` / `flatMap` / `filter`)

Shape your data without constantly checking if it exists. If the `Option` is `None`, these methods safely skip execution.

```dart
// 1. map: Transform an existing value synchronously (e.g. normalize an email for an avatar URL)
final rawEmail = Option('  Raman.Dev@Company.io  ');
final avatarUrl = rawEmail
    .map((email) => email.trim())
    .map((email) => email.toLowerCase())
    .map((email) => 'https://avatars.internal/u/$email'); 
// Some('https://avatars.internal/u/raman.dev@company.io')

// 2. flatMap: Chain operations where subsequent lookups may also return missing data
Option<String> findSessionToken(String userId) => Option('tok_sec_9842');
Option<String> fetchUserRole(String token) => Option('admin');

final activeRole = Option('usr_42')
    .flatMap(findSessionToken)
    .flatMap(fetchUserRole); 
// Some('admin')

// 3. filter: Discard a valid value if it fails a business rule or constraint check
final enteredPromo = Option('spring_sale_2026');
final validatedPromo = enteredPromo
    .map((code) => code.toUpperCase())
    .filter((code) => code.startsWith('SPRING_'))
    .filter((code) => !code.contains('EXPIRED')); 
// Some('SPRING_SALE_2026')
```

### Extract Safely

Pull your data out safely when you reach the end of the line:

```dart
final opt = Option(int.tryParse('bad_data'));

// 1. Fallback to a default
final val1 = opt.getOrElse(0); 

// 2. Handle both outcomes explicitly
final val2 = opt.fold(
  () => 'Fallback text',
  (val) => 'Found: $val',
);
```


## Best Practices

* **Always fold, never get**: Steer clear of `.get()`. If the value is missing, your app will crash. Always use safe extraction like `.fold()` or `.getOrElse()`.
* **Ditch `isSome` checks**: Calling `if (opt.isSome) { opt.get() }` just recreates the bad habits of standard null checking. Rely on `.map()` and `.flatMap()` to handle the data naturally.
* **Wrap messy APIs immediately**: When a third-party package gives you nullable data, wrap it in `Option(value)` right at the boundary.


## Common Mistakes

* **Nesting Options**: Writing `.map()` for a function that already returns an `Option` leaves you with `Option<Option<T>>`. Swap to `.flatMap()` to keep your pipeline completely flat.
* **Over-engineering simple code**: If you're checking a single local variable, Dart's `??` operator is fine. Unleash `Option` when you have multi-step transformations or complex domain rules.


## Related Types

* [QueryMap](query-map) - Safely extract nested values from JSON maps and pass them into `Option`.
* [Unit](unit) - Use `Option<Unit>` to signify an action that might happen, but returns no data.
* [Either](either) - Upgrade to `Either` if you need to know *why* the data is missing (by capturing a specific error).
