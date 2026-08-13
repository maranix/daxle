# Daxle

[![Documentation](https://img.shields.io/badge/docs-daxle.maranix.in-blue)](https://daxle.maranix.in)
[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](packages/daxle/LICENSE)

Predictable data flow and composable error handling for modern Dart.

Daxle introduces type-safe, zero-dependency functional primitives to Dart and Flutter applications, eliminating uncaught runtime exceptions and defensive null checks at compile time.

[📚 Read the Documentation](https://daxle.maranix.in) • [📦 View on Pub.dev](https://pub.dev/packages/daxle)

---

## Overview

Daxle provides lightweight primitives designed specifically for Dart 3+ sealed classes and pattern matching:

- **`Option<T>`**: Represents optional values safely without runtime null ambiguity or nested null checks.
- **`Either<L, R>`**: Encapsulates operations that can fail, turning untyped exceptions into explicit, compile-time enforced types.
- **`Task<T>` & `TaskEither<L, R>`**: Handles lazy async evaluation, controlled concurrency, and failure recovery pipelines.
- **`Unit`**: Represents void operations as explicit functional returns.

---

## Quick Example

### Imperative Exception Handling
```dart
// May throw unhandled exceptions or return null without warning
Future<User> fetchUser(String id) async {
  final response = await api.get('/users/$id');
  if (response.statusCode != 200) throw Exception('Failed to fetch user');
  return User.fromJson(response.data);
}
```

### Daxle Declarative Flow
```dart
// Failure and success are explicit in the return type signature
TaskEither<NetworkError, User> fetchUser(String id) =>
    TaskEither.tryCatch(
      () => api.get('/users/$id').then((r) => User.fromJson(r.data)),
      (error, stack) => NetworkError.from(error),
    );
```

---

## Packages

| Package | Path | Description | Version | Pub |
| :--- | :--- | :--- | :--- | :--- |
| **daxle** | [`packages/daxle`](packages/daxle/) | Core functional toolkit containing `Option`, `Either`, `Task`, `TaskEither`, and `Unit`. | `4.0.0` | [![Pub](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle) |

---

## Why Daxle?

### Explicit Error Handling
Runtime exceptions force developers to inspect internal implementations to anticipate failures. `Either<L, R>` makes failure paths explicit in function signatures, ensuring error handling is enforced at compile time.

### Expressive Value Composition
While Dart null safety prevents accessing null references, operating on optional values often results in repetitive `if (val != null)` blocks. `Option<T>` enables declarative chaining with `map`, `flatMap`, and pattern matching.

### Controlled Async Execution
`Task` and `TaskEither` enable lazy async computation with built-in concurrency controls (`sequential`, `bounded`, `unbounded`), ensuring predictable execution without unhandled async rejections.

---

## Getting Started

### Requirements
- Dart SDK `>= 3.13.0`

### Setup

1. Fetch repository dependencies:
   ```bash
   dart pub get
   ```

2. Run the test suite:
   ```bash
   cd packages/daxle && dart test
   ```

3. Run an example:
   ```bash
   dart run packages/daxle/example/option_example.dart
   ```

---

## Contributing

Contributions are welcome. To propose changes:

1. Fork the repository and create a feature branch.
2. Ensure code passes analysis and formatting checks (`dart analyze` and `dart format`).
3. Verify all unit tests pass (`dart test`).
4. Submit a pull request with a summary of changes.

---

## License

`daxle` is distributed under the terms of the [MIT License](packages/daxle/LICENSE).

