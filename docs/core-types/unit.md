---
outline: deep
---

# Unit

Give your type-safe pipelines a clear way to succeed without returning data.

---

## What is Unit?

`Unit` is a type that holds exactly one value: the global constant `unit`. 

In standard Dart, you use `void` to say "this function doesn't return anything." But `void` isn't a real object type. When you try to use it inside a generic container like `Either<Failure, void>`, Dart's type system fights you. `Unit` fixes this by giving you a real, tangible object to return when a side effect—like deleting a file or sending a log—succeeds, but produces no data.

---

## Why you need it

If you build reliable systems using containers like `Option` or `Either`, you frequently run into operations that can fail, but have nothing to say when they succeed.

Instead of fighting compiler warnings with `void` or breaking type safety with `null`, you simply return `unit`:

* **Zero compiler warnings**: `Unit` plays perfectly with Dart's generic type parameters.
* **Safer composition**: Chain your operations seamlessly.
* **Clear intent**: Returning `unit` explicitly tells other developers, "This operation succeeded, and we are intentionally discarding the result."

```dart
// Returns a Left with the error, or a Right with unit
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

## See it in action

Here is how you use `unit` to handle a simple file-writing operation. 

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

`Unit` is incredibly simple. It has no methods other than an overridden `toString()`. Your only job is to return it or match against it.

### Returning Unit

Always return the predefined `unit` constant. Do not try to instantiate the class yourself.

```dart
Either<String, Unit> performAction(bool shouldSucceed) {
  if (shouldSucceed) {
    return Either.right(unit);
  } else {
    return Either.left('Action failed');
  }
}
```

### Checking for Unit

Because `Unit` is a final class, you can check for it flawlessly using Dart's pattern matching.

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

## Compose with ease

`Unit` shines when you chain multiple side effects together. You can execute tasks, discard their intermediate results, and keep your pipeline moving forward.

```dart
TaskEither<FileError, Unit> copyAndLog(String src, String dest) {
  return copyFileTask(src, dest) 
      .flatMap((_) => writeLogTask(dest)); // Chain the next operation
}
```

---

## Best Practices

* **Always use the constant**: Stick to the lowercase `unit`. 
* **Use for side effects**: Pair `Unit` with `Either` or `TaskEither` when your function performs a database write, file deletion, or cache clear.
* **Expect `()` in logs**: `unit.toString()` returns `'()'`. This matches the convention of other modern languages like Rust and Swift.

---

## Common Mistakes

* **Forcing `void` into generics**: Writing `Either<Failure, void>` creates brittle code and compiler warnings. Let `Unit` do the heavy lifting instead.
* **Falling back to `null`**: Returning `Either.right(null)` bypasses type safety. Use `unit` to keep your domains strict and predictable.

---

## Related Types

* [Either](either) - Pair with `Unit` to model fallible side effects (`Either<L, Unit>`).
* [TaskEither](task-either) - Pair with `Unit` to model asynchronous, fallible side effects (`TaskEither<L, Unit>`).
