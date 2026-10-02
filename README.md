# Daxle

[![Documentation](https://img.shields.io/badge/docs-daxle.maranix.in-blue)](https://daxle.maranix.in)
[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](packages/daxle/LICENSE)

Data modeling, map querying, concurrency control, and stream transformations for modern Dart.

Daxle provides focused primitives designed specifically for Dart 3+:

- **`QueryMap`**: Extension type over `Map` with dot notation, bracket indexing for embedded lists, and non-string key support. Safely returns `null` on missing paths or type mismatches.
- **`Concurrency`**: Extension type for fine-grained async worker limits (`sequential`, `unbounded`, `bounded(limit)`), sliding-window worker pool execution backed by `package:pool`, and early termination (`shouldStop`).
- **`Pool`**: Re-exports `Pool` and `PoolResource` from `package:pool` for robust asynchronous resource management.
- **Deep Structural Equality**: Collection-aware equality checks (`$deepEquals`, `$deepHashCode`, `$listEquals`, `$setEquals`, `$mapEquals`).
- **Stream Transformations**: Complete suite of reactive operators from `package:stream_transform` (debounce, throttle, audit, merge, combineLatest, switchMap, scan, tap).
- **Async Flow Utilities**: Re-exports of key utilities from `package:async` (`FutureGroup`, `AsyncCache`, `AsyncMemoizer`, `StreamZip`, `StreamQueue`, `StreamGroup`, `StreamSplitter`).
- **Codegen Annotations**: Declarative annotations (`@serialize`, `@deserialize`, `@copyWith`, `@equalsAndHashCode`, `@stringify`, `@redact`, `@AnnotationBundle`) paired with `daxle_gen` in `dev_dependencies` for pure AST code generation.
- **State Machine Workflows (Preview & Experimental)**: Declarative annotations (`@StateMachine`, `Flow`, `TransitionScope`, `InvalidFlowException`) for verified transition graphs, async flow handlers, and epoch-based stale cancellation.

Import `package:daxle/daxle.dart` for core annotations, data classes, QueryMap, and preview state machines. Import `package:daxle/async.dart` for the curated async/reactive toolkit (`Concurrency`, `Pool`, `stream_transform`, `FutureGroup`, `AsyncCache`).

[📚 Read the Documentation](https://daxle.maranix.in) • [📦 View on Pub.dev](https://pub.dev/packages/daxle)

---

## Packages

| Package | Path | Description | Version | Pub |
| :--- | :--- | :--- | :--- | :--- |
| **daxle** | [`packages/daxle`](packages/daxle/) | Core toolkit containing `QueryMap`, `Concurrency`, equality, stream transforms, codegen annotations, and preview state machines. | `5.0.0` | [![Pub](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle) |
| **daxle_gen** | [`packages/daxle_gen`](packages/daxle_gen/) | High-performance AST code generator for functional serialization, deep copyWith, equality, stringify, and preview state machines. | `0.3.0` | [![Pub](https://img.shields.io/pub/v/daxle_gen.svg)](https://pub.dev/packages/daxle_gen) |

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
   cd ../daxle_gen && dart test
   ```

3. Run an example:
   ```bash
   dart run packages/daxle/example/query_map.dart
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
