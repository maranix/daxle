---
outline: deep
---

# Unit

Representing the absence of a meaningful value in generic computations.

---

## What is it?

`Unit` is a type that has exactly one value: the global constant `unit`. In functional programming, it is used to represent the return value of a computation or function that performs a side effect but doesn't need to return any actual data.

In standard Dart, you would use `void` for functions that don't return anything. However, because `void` is a keyword and not a proper type, it cannot be used as a generic type parameter (for instance, you cannot easily instantiate `Either<Failure, void>`). While `Future<void>` is allowed in Dart, `void` inside generic parameters behaves inconsistently and cannot be returned as a value. `Unit` solves this by being a standard Dart class with a single instance.

---

## Why use it?

If you are using type-safe containers like `Option` or `Either`, you will frequently run into situations where an operation can fail, but if it succeeds, there is no value to return. 

For example, when writing to a file, deleting a database record, or sending a log over the network:
* **The failure case**: Returns a specific error object (e.g., `StorageException`).
* **The success case**: Has no meaningful data to return. We just need to know it succeeded.

If you try to use `void` (e.g., `Either<StorageException, void>`), Dart's type system will make it difficult to construct and compose values. By using `Unit` (e.g., `Either<StorageException, Unit>`), you can return the `unit` constant to signal success:

```dart
// Returns a Left with the exception, or a Right with unit
Either<StorageException, Unit> deleteFile(String path) {
  try {
    File(path).deleteSync();
    return Either.right(unit); // Clearly signals success
  } catch (e) {
    return Either.left(StorageException(e.toString()));
  }
}
```

---

## Basic Example

Here is a simple example showing how `unit` is used in a file-writing operation. We want to write text to a file and return a result indicating success or failure.

```dart
import 'dart:io';
import 'package:daxle/daxle.dart';

class FileError {
  final String message;
  FileError(this.message);
}

// Writes text to a file, returning Unit on success
Either<FileError, Unit> writeLog(String path, String message) {
  try {
    final file = File(path);
    file.writeAsStringSync(message, mode: FileMode.append);
    return Either.right(unit); // Success containing no data
  } catch (e) {
    return Either.left(FileError('Failed to write log: $e'));
  }
}

void main() {
  final result = writeLog('app.log', 'System started.');
  
  result.fold(
    (error) => print('Error: ${error.message}'),
    (success) => print('Log written successfully! Value: $success'), // Prints: ()
  );
}
```

---

## Common Operations

`Unit` has no methods other than an overridden `toString()`. The only common operation is returning or matching the `unit` constant.

### Returning Unit

Always return the predefined global `unit` constant instead of trying to instantiate `Unit`.

```dart
Either<String, Unit> performAction(bool shouldSucceed) {
  if (shouldSucceed) {
    return Either.right(unit);
  } else {
    return Either.left('Action failed');
  }
}
```

### Checking for Unit in Pattern Matching

Since `Unit` is a final class, you can check for it using Dart's pattern matching.

```dart
void handleResult(Either<String, Unit> result) {
  switch (result) {
    case Left(value: final error):
      print('Failed: $error');
    case Right(value: unit):
      print('Succeeded with unit!');
  }
}
```

---

## Composition

`Unit` is highly useful when composing multiple operations where we discard intermediate results but want to keep track of execution success.

For example, copying a file and then logging the operation:

```dart
TaskEither<FileError, Unit> copyAndLog(String src, String dest) {
  return copyFileTask(src, dest) // TaskEither<FileError, Unit>
      .flatMap((_) => writeLogTask(dest)); // Chains another TaskEither returning Unit
}
```

In the example above, `flatMap` expects a function that takes the success value of `copyFileTask`. Since `copyFileTask` returns `Unit`, we can discard it using `_` and proceed with the next task.

---

## Best Practices

* **Use the global constant**: Always use the lowercase global constant `unit`. Never try to instantiate the `Unit` class (its constructor is private anyway).
* **Use for side effects**: Use `Unit` as the success type parameter in `Either` or `TaskEither` when the underlying operation is executed purely for its side effects (e.g., database writes, file deletes, cache clearing).
* **Represent as `()`**: Note that `unit.toString()` returns `'()'`. This aligns with other languages like Rust or Swift where the unit type is represented as an empty tuple.

---

## Common Mistakes

* **Trying to use `void` inside generic containers**: Writing `Either<Failure, void>` will cause compiler warnings or runtime issues because `void` cannot be treated as a regular object type in many contexts. Use `Either<Failure, Unit>` instead.
* **Using `null` as a placeholder**: Returning `Either.right(null)` is discouraged unless `null` is a valid domain value. It bypasses type safety and defeats the purpose of avoiding nullability issues.

---

## When to Use

* Use `Unit` when a generic type parameter requires a type, but the operation returns no meaningful data (e.g., `Either<L, Unit>`, `Task<Unit>`, `Option<Unit>`).
* Use `Unit` to signal the successful completion of a side-effecting function in a pipeline.

---

## API Overview

### Classes

| Class | Description |
|---|---|
| `Unit` | A final class representing a type with a single value. |

### Constants

| Constant | Type | Description |
|---|---|---|
| `unit` | `Unit` | The single global instance of the `Unit` type. |

### Methods

| Method | Return Type | Description |
|---|---|---|
| `toString()` | `String` | Returns `'()'`, representing the unit value. |

---

## Related Types

* [Either](either) - Commonly paired with `Unit` (e.g., `Either<L, Unit>`) to represent fallible side effects.
* [TaskEither](task-either) - Commonly paired with `Unit` (e.g., `TaskEither<L, Unit>`) to represent asynchronous fallible side effects.
