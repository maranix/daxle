## 2.0.0 (2026-06-27)

- **BREAKING CHANGES / API REWRITE**:
  - Removed `Lazy<T>` type. Use deferred pipelines or standard closures.
  - Redesigned `Option<T>`, `Either<L, R>`, and `Result<T, E>` as sealed classes with direct subclasses (`Some`/`None`, `Left`/`Right`, `Ok`/`Err`) for full compile-time exhaustive pattern matching.
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
  - Re-introduced `Result<T, E>` with `Ok` and `Err` variants, featuring `.result()` extension methods on both synchronous and asynchronous functions to capture exceptions cleanly into `Result` types.

---

## 1.1.0

- Introduced `Lazy` type for lazy evaluation and memoization of values.
- Supported transforming `Lazy` to `Result`, `Option`, and `Either`.

## 1.0.0

- Initial version. (2026-01-10)
  - Implemented `Either` type for representing success or failure.
  - Implemented `Option` type for representing the presence or absence of a value.
  - Implemented `Result` type for representing a result of an operation that can either succeed or fail.
