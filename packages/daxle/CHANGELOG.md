## 4.0.0 (2026-08-13)

- **BREAKING CHANGES**:
  - `Option<T extends Object>` now strictly enforces non-nullable type parameter `T extends Object`. Storing `null` inside `Some` is prohibited.
  - Removed `Option.fromNullable(T? value)`. Use the smart factory constructor `Option(T? value)` instead, which automatically maps `null` to `None()` and non-null values to `Some(value)`.
  - Changed `Either.cond` signature from `(bool condition, R right, L left)` to lazy callbacks `(bool condition, R Function() right, L Function() left)` to fix eager early-evaluation bugs and guarantee that unchosen branches (e.g., throwing expressions like `a ~/ b`) are never executed.

- **NEW FEATURES**:
  - Introduced `QueryMap` zero-cost extension type (`extension type const QueryMap(Map<Object?, Object?> map)`) for type-safe nested map and array querying:
    - Dot notation for nested maps (`query.get<String>('services.server.host')`).
    - Bracket notation for single and multi-dimensional lists (`query.get<String>('users[0].name')`, `query.get<int>('matrix[0][2]')`).
    - Key lists / Iterable paths for non-string keys (`query.get<String>(['cluster', 101, 'status'])`).
    - Type-safe retrieval via `query.get<T>(path)` returning `null` on type mismatch without throwing `TypeError`.
    - Key presence checking via `query.has(path)` (differentiating explicit `null` from missing keys).
  - Introduced `Concurrency` extension type (`extension type const Concurrency._(int limit)`) to manage worker pool concurrency:
    - `Concurrency.sequential` (`.sequential`, limit 1): Executes tasks 1 by 1 sequentially.
    - `Concurrency.unbounded` (`.unbounded`, limit 0): Runs all tasks simultaneously in parallel.
    - `Concurrency.bounded(int limit)` (`.bounded(limit)`): Processes tasks in parallel worker chunks of size `limit`.
  - Added optional `{Concurrency mode = const .bounded(3)}` parameter to `Task.sequence`, `Task.traverse`, `TaskEither.sequence`, and `TaskEither.traverse`.
  - Full support for Dart dot-shorthand syntax (`mode: .sequential`, `mode: .unbounded`, `mode: .bounded(5)`).

- **PERFORMANCE & REFACTORING**:
  - Defensive snapshotting (`items.toList()`) in `Concurrency.process` prevents `ConcurrentModificationError` when iterables are mutated across asynchronous boundaries.
  - Eager failure short-circuiting (`eagerError: true`) stops processing immediately when an operation fails.

## 3.1.1 (2026-07-20)

- **BUG FIXES**:
  - Prevented `null` values inside `Some` instances by throwing an `ArgumentError` if `Some` is initialized with `null`.
  - Fixed `Option.map` to accept `B? Function(T)` and convert `null` return values into `None()` (`Option.fromNullable(f(value))`), preventing `Some(null)` values.

## 3.1.0 (2026-07-17)

- **PERFORMANCE & REFACTORING**:
  - Improved `TaskEither` and `Task` performance by migrating to `Future.then` to avoid async/await overhead.
  - Optimized memory allocations and performance in AOT for `Either` and `Option` by using pragma annotations and direct constructor instantiation.
  - Refactored `Either` and `Option` to delegate combinators directly to their respective subclasses.
  - Inlined async transformation helpers in `TaskEither` to further reduce runtime overhead.
- **TESTS**:
  - Added regression tests for `Task` and `TaskEither` exception handling.

## 3.0.0 (2026-07-14)

- **BREAKING CHANGES / ARCHITECTURE REDESIGN**:
  - Removed `Result<T, E>` entirely. Use `Either<L, R>` as the single abstraction for explicit success/failure.
  - Removed `Pipeline<T>` and `AsyncPipeline<T>`. Most useful functionality is now handled by `TaskEither<L, R>` with explicit control flow.
  - Core primitives are now strictly single-responsibility: `Option<T>`, `Either<L, R>`, `Task<T>`, `TaskEither<L, R>`, and `Unit`.

- **NEW FEATURES**:
  - Added `Task<T>` primitive for lazy asynchronous computations that do not model explicit failures.
  - Enhanced `TaskEither<L, R>` with comprehensive combinators:
    - Added `mapLeft`, `bimap`, `tap`, `tapLeft`, `ensure`, `sequence`, and `traverse`.
    - Added support for exception catching in `flatMap`.
  - Standardized `sequence` and `traverse` as static methods across `Either`, `Task`, and `TaskEither` for consistency and easier discovery.

- **DOCUMENTATION & REFACTORING**:
  - Re-architected implementation of `TaskEither` and `Either` to strictly use `fold` for value transformations and exhaustive `switch` for control flow branching, reducing code duplication.
  - Improved `_transformWithErrorHandling` docstrings and formatting.
  - Instantiations of `Option.none()` now use the `const` constructor for improved performance.

## 2.2.0 (2026-07-11)

- **NEW FEATURES**:
  - Re-exported key utilities from `package:async` to simplify asynchronous control flow and stream manipulation. These include:
    - `FutureGroup`, `AsyncCache`, and `AsyncMemoizer` for advanced future handling.
    - `StreamZip`, `StreamQueue`, `StreamGroup`, and `StreamSplitter` for streamlined stream consumption and combination.

- **DOCUMENTATION & REFACTORING**:
  - Updated library documentation in `lib/daxle.dart` and `README.md` to document the new `async` utilities.
  - Completed the incomplete documentation example for `Unit` inside `lib/daxle.dart`.
  - Removed outdated record extensions references from `lib/daxle.dart` and `README.md`.

## 2.1.0 (2026-07-01)

- **NEW FEATURES**:
  - Re-introduced `Result<T, E>` with `Ok` and `Err` variants for representing operations that can succeed or fail.

- **BREAKING CHANGES**:
  - Removed all record extensions (`zipped()`, `map()`, `flatMap()`, and `filter()` on Dart tuples/records) to keep the library lean and focus on a single explicit way of doing things.
  - Removed all function extension methods (`.result()`, `.either()`, and `.option()`).

- **DOCUMENTATION & REFACTORING**:
  - Reorganized internal folder structure inside `lib/src/` into logical subfolders (`types/`).
  - Added comprehensive `{@template}` and `{@macro}` documentation to all core data types and classes to maximize readability and reduce doc comments redundancy.
  - Added `example/example.md` to showcase the primary library features on pub.dev.
  - Formatted the codebase to ensure a 160/160 pub points quality score.

## 2.0.0 (2026-06-27)

- **BREAKING CHANGES / API REWRITE**:
  - Removed `Lazy<T>` type. Use deferred pipelines or standard closures.
  - Redesigned `Option<T>` and `Either<L, R>` as sealed classes with direct subclasses (`Some`/`None`, `Left`/`Right`) for full compile-time exhaustive pattern matching.
  - Changed `Option.getOrElse` to take an eager default value `T` instead of a resolver callback.
  - Changed `Either.getOrElse` to take a resolver callback `R Function(L left)` instead of an eager default value.

- **NEW FEATURES**:
  - Added `TaskEither<L, R>` type to represent lazy, asynchronous computations that can fail (`Future<Either<L, R>>`), supporting monadic chaining (`map`, `flatMap`, `orElse`, `fold`).
  - Added `Pipeline<T>` and `AsyncPipeline<T>` classes to build deferred, type-safe operation chains.
    - Supports observational side-effects (`tap`).
    - Supports recovery from errors (`recover` and `recoverWith`).
    - Supports error mapping (`mapError`).
    - Supports cleanup logic (`finalize` / `finally` equivalent).
    - Supports folding success and failure states.
    - Supports concurrent combination of asynchronous pipelines (`zip`).
  - Added `Unit` type and `unit` constant to represent the absence of a meaningful value.
  - Added `zipped()`, `map()`, `flatMap()`, and `filter()` extension methods on Dart 3 `Record` tuples of size 2, 3, 4, and 5 containing `Option`, `Either`, or `TaskEither` values (runs `TaskEither` tasks concurrently).
  - Added `Option.fromPredicate` and `Either.cond` factory constructors, and `Option.filter` method for clean, explicit conditional evaluation.

---

## 1.1.0

- Introduced `Lazy` type for lazy evaluation and memoization of values.
- Supported transforming `Lazy` to `Result`, `Option`, and `Either`.

## 1.0.0

- Initial version. (2026-01-10)
  - Implemented `Either` type for representing success or failure.
  - Implemented `Option` type for representing the presence or absence of a value.
  - Implemented `Result` type for representing a result of an operation that can either succeed or fail.
