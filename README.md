# Daxle Monorepo Workspace

Welcome to the `daxle` monorepo workspace. This repository contains the source code for `daxle`, a lightweight, type-safe functional programming toolkit for Dart.

## Packages

| Package | Path | Description | Version | Pub |
| :--- | :--- | :--- | :--- | :--- |
| **daxle** | [`packages/daxle`](packages/daxle/) | Core functional programming library offering modern constructs: `Option`, `Either`, `TaskEither`, `Pipeline`, `AsyncPipeline`, and `Unit`. | `2.0.0` | [![Pub](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle) |

---

## Workspace Goals

The primary goal of this workspace is to develop and maintain robust tools that enhance Dart applications by offering:
- **Type-Safety**: Enforce explicit handling of optional values and operations that can fail.
- **Modern FP Patterns**: Sealed classes, pattern matching, records, and monadic chaining.
- **Observability & Deferral**: Deferred synchronous and asynchronous pipelines with tap and recovery capabilities.

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

If you would like to contribute to `daxle`, please follow the steps below:

1. Fork this repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and ensure all tests pass (`dart test`).
4. Ensure code formatting and static analysis are clean (`dart format` and `dart analyze`).
5. Submit a pull request.

---

## License

`daxle` is released under the [MIT License](packages/daxle/LICENSE).