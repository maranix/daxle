---
outline: deep
---

# Parsing and Validation

## Question
**How do I safely parse and validate values without exceptions?**

---

## Problem
In standard Dart, parsing unstructured values (like CSV rows or key-value config files) and validating them can quickly clutter your code with `try-catch` blocks and nested `if` statements.

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

---

## Solution
Use `Either.tryCatch` to parse values safely, then use `ensure` to apply validation rules. This keeps the parsing and validation logic in a single, linear, compile-safe pipeline.

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

Usage is clean and predictable:

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

---

## Why this solution works well with Daxle

* **Unified pipeline**: Parsing (which can throw exceptions) and validation checks (which represent logical failures) are treated uniformly as inputs to `Either`.
* **Zero exception leakage**: `Either.tryCatch` acts as a safe boundary, converting untyped runtime exceptions into explicit, typed compiler warnings.
* **Separation of concerns**: The parsing logic, the validation rules, and the error definitions are decoupled, making them easy to test in isolation.
