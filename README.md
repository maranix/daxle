# Daxle Workspace

[![Documentation](https://img.shields.io/badge/docs-daxle.maranix.in-blue)](https://daxle.maranix.in)

Welcome to the **Daxle** monorepo workspace! This repository contains the source code for `daxle`, a lightweight, type-safe functional programming toolkit designed to help you write predictable and robust Dart applications.

**[📚 Read the Full Documentation](https://daxle.maranix.in)**

---

## Packages

| Package | Path | Description | Version | Pub |
| :--- | :--- | :--- | :--- | :--- |
| **daxle** | [`packages/daxle`](packages/daxle/) | Build composable, predictable pipelines. Core toolkit offering `Option`, `Either`, `Task`, `TaskEither`, and `Unit`. | `3.1.1` | [![Pub](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle) |

---

## Why Daxle?

Dart's native error handling can sometimes be unpredictable. Uncaught exceptions crash apps, and nested async calls create callback hell. Daxle solves this by introducing robust, functional primitives to your workflow.

- **Declarative Data Flow**: Replace imperative `if-else` chains with explicit, functional types for missing values (`Option`) and operations that can fail (`Either`).
- **Modern FP Patterns**: Utilize sealed classes, pattern matching, and monadic chaining tailored for modern Dart.
- **Composable Asynchronous Workflows**: Chain asynchronous tasks lazily with `Task` and `TaskEither`. Handle failures at compile-time without throwing exceptions.

---

## Getting Started

1. Ensure you have the Dart SDK installed (`>=3.11.0`).
2. Run `dart pub get` from the root or within `packages/daxle` to resolve dependencies.
3. To run all unit tests:
   ```bash
   cd packages/daxle
   dart test
   ```
4. To run an example file:
   ```bash
   dart run packages/daxle/example/option_example.dart
   ```

---

## Contributing

We love contributions! If you would like to contribute to `daxle`, please follow the steps below:

1. Fork this repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and ensure all tests pass (`dart test`).
4. Ensure code formatting and static analysis are clean (`dart format` and `dart analyze`).
5. Submit a pull request.

---

## License

`daxle` is released under the [MIT License](packages/daxle/LICENSE).