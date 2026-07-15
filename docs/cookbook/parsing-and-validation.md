---
outline: deep
---

# Parsing and Validation

## How do you safely parse and validate data without leaking exceptions?


## The Mess of Manual Validation

When you parse unstructured data—like CSV rows or raw configuration files—you have to validate it. In standard Dart, this means littering your code with `try-catch` blocks and deeply nested `if` statements.

Before long, your business logic is buried, formatting exceptions get swallowed, and you lose critical details about why the validation actually failed.

```dart
// Imperative validation: hard to read and easily lets exceptions escape
ThresholdConfig? parseAndValidate(String input) {
  try {
    final parts = input.split(':');
    if (parts.length != 2) return null;
    
    final name = parts[0].trim();
    if (name.isEmpty) return null;
    
    final limit = int.parse(parts[1].trim());
    if (limit <= 0 || limit > 1000) return null;
    
    return ThresholdConfig(name, limit);
  } catch (_) {
    return null; // Suppresses formatting exceptions and loses original details
  }
}
```


## The Solution: Safe, Linear Validation Pipelines

You can eliminate the clutter by using `Either.tryCatch` to safely parse values, followed by `ensure` to enforce your business rules. 

This creates a single, highly readable pipeline that is guaranteed to be compile-safe.

```dart
import 'package:daxle/daxle.dart';

// 1. Define custom validation errors
sealed class ValidationError {
  final String message;
  ValidationError(this.message);
}

class InvalidFormat extends ValidationError {
  InvalidFormat() : super('Input must be in "name:limit" format');
}

class InvalidName extends ValidationError {
  InvalidName() : super('Name cannot be empty');
}

class LimitOutOfRange extends ValidationError {
  final int value;
  LimitOutOfRange(this.value) : super('Limit $value must be between 1 and 1000');
}

// 2. Define the configuration class
class ThresholdConfig {
  final String name;
  final int limit;
  ThresholdConfig(this.name, this.limit);
}

// 3. Define the safe parsing pipeline
Either<ValidationError, ThresholdConfig> parseThreshold(String input) {
  final parts = input.split(':');
  if (parts.length != 2) {
    return Either.left(InvalidFormat());
  }

  final name = parts[0].trim();
  final rawLimit = parts[1].trim();

  if (name.isEmpty) {
    return Either.left(InvalidName());
  }

  // Safely parse the integer and validate the range
  return Either.tryCatch(
    () => int.parse(rawLimit),
    (_, __) => InvalidFormat(),
  )
  .ensure(
    (limit) => limit > 0 && limit <= 1000,
    (limit) => LimitOutOfRange(limit),
  )
  .map((limit) => ThresholdConfig(name, limit));
}
```

Usage becomes entirely predictable, with zero hidden exceptions:

```dart
void main() {
  final inputs = [
    'cpu_usage:85',
    'memory_limit:invalid',
    ':200',
    'disk_write:1500',
  ];

  for (final input in inputs) {
    final result = parseThreshold(input);
    
    result.fold(
      (error) => print('Error: ${error.message}'),
      (config) => print('Config parsed: ${config.name} with limit ${config.limit}'),
    );
  }
}
```


## Why You'll Love This Approach

* **Unify Your Flow**: Parsing errors (which throw exceptions) and validation errors (which fail logical checks) are treated exactly the same way. They both seamlessly feed into `Either`.
* **Stop Exception Leaks Completely**: `Either.tryCatch` acts as a bulletproof boundary. It catches untyped runtime exceptions and instantly converts them into explicit, typed compiler warnings.
* **Test with Confidence**: Because your parsing logic, validation rules, and error definitions are cleanly decoupled, you can easily test every single rule in isolation.
