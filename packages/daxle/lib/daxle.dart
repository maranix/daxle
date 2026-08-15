/// Build predictable, composable Dart applications.
///
/// `daxle` is a lightweight functional programming toolkit that replaces
/// imperative state checks and nested try/catch blocks with clean,
/// declarative pipelines. Inspired by languages like Rust and Haskell,
/// it brings robust functional primitives to modern Dart.
///
/// This library exports six core types, concurrency controls, and essential async utilities:
///
/// - [Option]: For composing optional values without imperative state checks.
/// - [Either]: For explicit, type-safe error handling and branching.
/// - [Task]: For composing lazy, asynchronous workflows with controlled concurrency.
/// - [TaskEither]: For chaining asynchronous operations that can fail, with automatic short-circuiting and controlled concurrency.
/// - [Unit]: For representing the absence of a meaningful value.
/// - [QueryMap]: Zero-cost extension type for type-safe nested querying over maps with support for embedded lists and non-string keys.
/// - [Concurrency]: Extension type for fine-grained async worker pool limits (`sequential`, `unbounded`, `bounded(limit)`).
/// - **Async Utilities**: Re-exports of key utilities from `package:async` (like [FutureGroup], [AsyncCache], [AsyncMemoizer], [StreamZip], [StreamQueue], [StreamGroup], and [StreamSplitter]) for advanced asynchronous flow control.
///
/// ---
///
/// ## `Option<T extends Object>`
///
/// Compose optional non-nullable values functionally. An instance of [Option] is either `Some`
/// (containing a value) or `None` (indicating absence). It allows you to chain
/// operations and handle missing data declaratively, avoiding messy `if` checks.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// Option<String> findUser(String id) {
///   if (id == '123') {
///     return .some('Alice');
///   }
///   return const .none();
/// }
///
/// void main() {
///   // Smart constructor converts null to None() and non-null to Some(value):
///   final user = Option(findUser('123').toNullable());
///   final userName = user.getOrElse(() => 'Guest');
///   print('User: $userName'); // Prints: User: Alice
///
///   // Construct using predicate:
///   final validAge = .fromPredicate(20, (a) => a >= 18); // Some(20)
///
///   // Filter values conditionally:
///   final filtered = validAge.filter((a) => a > 30); // None
///
///   // Pattern matching:
///   final message = switch (user) {
///     Some(value: final name) => 'Hello, $name',
///     None() => 'Welcome, guest!',
///   };
/// }
/// ```
///
/// ---
///
/// ## `Either<L, R>`
///
/// Make failures an explicit part of your function signatures. [Either] holds a
/// value of one of two types: `Left` or `Right`. By convention, `Right` represents
/// success and `Left` represents an error, forcing you to handle both states at compile-time.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// Either<String, int> parseNumber(String text) {
///   final val = int.tryParse(text);
///   if (val == null) {
///     return const .left('Invalid number format');
///   }
///   return .right(val);
/// }
///
/// void main() {
///   final result = parseNumber('123');
///
///   // Construct using boolean condition:
///   final auth = .cond(true, 'Authorized User', 'Access Denied');
///
///   result.fold(
///     (error) => print('Error: $error'),
///     (value) => print('Value: $value'), // Prints: Value: 123
///   );
/// }
/// ```
///
/// ---
///
/// ## `Task<T>`
///
/// Compose deferred asynchronous workflows. Unlike a `Future`, a [Task] is lazy
/// and won't execute until you call `.run()`. This allows you to construct
/// complex async pipelines before execution begins.
///
/// Execute collections of tasks with controlled worker limits via `Task.sequence` or `Task.traverse`:
///
/// ```dart
/// final tasks = [fetchA(), fetchB(), fetchC()];
///
/// // Process concurrently with a worker pool limit of 2:
/// final batch = Task.sequence(tasks, mode: .bounded(2));
/// final results = await batch.run();
/// ```
///
/// **Note**: [Task] does not provide explicit failure handling. If the underlying computation throws,
/// the exception propagates naturally. For explicit failure handling, use [TaskEither].
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// void main() async {
///   final task = Task(() async {
///     print('Executing...');
///     return 42;
///   }).map((x) => x * 2);
///
///   // The task hasn't executed yet.
///   final result = await task.run(); // Now it executes.
///   print('Result: $result');
/// }
/// ```
///
/// ---
///
/// ## `TaskEither<L, R>`
///
/// Chain async operations safely without nesting. [TaskEither] represents a lazy,
/// asynchronous computation that can fail (`Future<Either<L, R>>`), offering four major advantages:
///
/// 1. **Lazy Execution**: Unlike eager Futures, [TaskEither] only runs when `.run()`
///    is called, allowing you to easily build retries or fallbacks.
/// 2. **Short-Circuiting & Early Failure Abort**: It embeds the [Either] state at each step.
///    In chained pipelines or concurrent collections (`sequence`/`traverse`), any failure ([Left])
///    stops execution immediately and cancels unstarted pending tasks to save resources.
/// 3. **Dynamic Sliding-Window Concurrency**: Run concurrent task collections using a worker
///    pool (`.bounded(poolSize)`), strictly one-by-one (`.sequential`), or in parallel (`.unbounded`).
/// 4. **Exception Guarding**: `TaskEither.fromFuture` automatically catches
///    runtime exceptions and maps them to a safe [Left] value.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// TaskEither<String, String> fetchUser(int id) => .fromFuture(
///   () async => 'User #$id',
///   (err, _) => 'User not found',
/// );
///
/// TaskEither<String, String> fetchConfig(String role) => .fromFuture(
///   () async => 'Config for $role',
///   (err, _) => 'Config not found',
/// );
///
/// void main() async {
///   // Chain dependent async computations without nested awaits or try-catch blocks:
///   final result = await fetchUser(42)
///       .flatMap(fetchConfig) // Clean tear-off composition
///       .run();
///
///   result.fold(
///     (error) => print('Failed: $error'),
///     (config) => print('Success: $config'),
///   );
///
///   // Execute tasks concurrently with a sliding-window worker pool of 3.
///   // If any task yields a Left, remaining queued tasks are aborted immediately:
///   final batchResult = await TaskEither.sequence(
///     [fetchUser(1), fetchUser(2), fetchUser(3)],
///     mode: .bounded(3),
///   ).run();
/// }
/// ```
///
/// ---
///
/// ## `QueryMap`
///
/// Safely extract nested properties from structured [Map]s and their embedded lists.
/// `QueryMap` is a zero-cost extension type erased at compile-time that replaces
/// fragile manual map cast chains with type-safe path queries.
///
/// ### Supported Query Notations:
///
/// - **Dot Notation (Nested Maps)**: Query nested string map keys like `'services.server.host'`.
/// - **Bracket Notation (Embedded Lists)**: Access list elements and multidimensional arrays embedded within maps, e.g. `'users[0].name'` or `'matrix[0][2]'`.
/// - **Key Lists / Iterable Paths (Non-String Keys)**: Use iterable paths like `['cluster', 101, 'status']` or `['flags', true]` to query map keys that are not strings.
///
/// ### Safe by Design:
///
/// - **Type Safety**: `query.get<T>(path)` validates types at runtime. If the value does not match type `T`, it returns `null` without throwing a `TypeError`.
/// - **Bounds & Parsing Safety**: Missing keys, null intermediate nodes, out-of-bounds array indices, or malformed brackets safely evaluate to `null` without throwing `RangeError` or `FormatException`.
/// - **Presence Detection**: `query.has(path)` distinguishes between a missing key and an existing key whose value is `null`, `false`, `0`, or empty.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// void main() {
///   final payload = {
///     'services': {
///       'server': {'host': 'https://api.internal', 'port': 8080, 'active': true},
///       'database': null,
///     },
///     'users': [
///       {'id': 1, 'name': 'Alice', 'roles': ['admin', 'dev']},
///     ],
///     'matrix': [
///       [10, 20],
///       [30, 40],
///     ],
///     'cluster': {
///       101: {'status': 'healthy'},
///     },
///   };
///
///   final query = QueryMap(payload);
///
///   // 1. Dot notation for nested maps:
///   final host = query.get<String>('services.server.host'); // 'https://api.internal'
///   final port = query.get<int>('services.server.port'); // 8080
///
///   // 2. Bracket notation for embedded lists and multidimensional matrices:
///   final userName = query.get<String>('users[0].name'); // 'Alice'
///   final firstRole = query.get<String>('users[0].roles[0]'); // 'admin'
///   final matrixCell = query.get<int>('matrix[1][0]'); // 30
///
///   // 3. Key lists for non-string map keys:
///   final status = query.get<String>(['cluster', 101, 'status']); // 'healthy'
///
///   // 4. Safe failure handling (no exceptions thrown):
///   final invalidType = query.get<int>('services.server.host'); // null (value is a String)
///   final outOfBounds = query.get<String>('users[99].name'); // null
///
///   // 5. Presence checking (distinguishes explicit null from missing keys):
///   query.has('services.database'); // true (key exists with null value)
///   query.has('services.cache'); // false (key does not exist)
///
///   // 6. Seamless composition with Option:
///   final serverHost = Option(query.get<String>('services.server.host'))
///       .getOrElse(() => 'https://fallback.internal');
/// }
/// ```
///
/// ---
///
/// ## `Concurrency`
///
/// Fine-grained control over asynchronous worker scheduling across the event loop:
///
/// - `Concurrency.sequential` (or `.sequential`): Runs tasks 1 by 1 in strict sequence.
/// - `Concurrency.unbounded` (or `.unbounded`): Dispatches all tasks simultaneously in parallel without limits.
/// - `Concurrency.bounded(int poolSize)` (or `.bounded(3)`): Executes tasks using a **sliding-window worker pool**.
///   Fast tasks never wait for slow tasks; available workers immediately pull the next task from the queue.
/// - **Standalone `dispatch` & `process`**: Use `concurrency.dispatch(items, worker)` to process raw collections without `Task`/`TaskEither` boilerplate, or `concurrency.process(thunks)` for zero-arg task closures.
/// - **Early Termination (`shouldStop`)**: Halts worker queue consumption as soon as a stop condition is met,
///   protecting your system from running redundant operations when a failure or target state is reached.
///
/// ---
///
/// ## `Unit`
///
/// A singleton type containing exactly one value: `unit`. Used in functional programming to represent the absence of a meaningful value in generic constructs (like returning `Either<String, Unit>`).
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// Either<String, Unit> saveRecord(String data) {
///   try {
///     // Save logic...
///     return const .right(unit);
///   } catch (e) {
///     return .left('Failed to save: $e');
///   }
/// }
/// ```
///
/// ---
///
/// ## Async Utilities
///
/// This package re-exports several powerful primitives from `package:async` to simplify asynchronous control flow and stream manipulation:
///
/// - **Future Utilities**:
///   - [FutureGroup]: Collects futures and fires when all are complete, allowing dynamic addition of futures.
///   - [AsyncCache]: Caches the results of asynchronous operations.
///   - [AsyncMemoizer]: Runs an asynchronous block once and caches the result for future calls.
///
/// - **Stream Utilities**:
///   - [StreamZip]: Combines multiple streams into a single stream of zipped values.
///   - [StreamQueue]: Simplifies stream consumption with pull-based operations.
///   - [StreamGroup]: Merges multiple streams into a single output stream.
///   - [StreamSplitter]: Splits a single stream into multiple identical, independent streams.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// void main() async {
///   // Combine multiple streams concurrently
///   final streamA = Stream.fromIterable([1, 2, 3]);
///   final streamB = Stream.fromIterable(['A', 'B', 'C']);
///   final zipped = StreamZip([streamA, streamB]);
///
///   await for (final pair in zipped) {
///     print(pair); // [1, 'A'], [2, 'B'], [3, 'C']
///   }
/// }
/// ```
library;

export 'src/types/either.dart';
export 'src/types/option.dart';
export 'src/types/task.dart';
export 'src/types/task_either.dart';
export 'src/types/unit.dart';
export 'src/util/concurrency.dart';
export 'src/util/query_map.dart';

// Export some useful utilities from `async` package
export 'package:async/async.dart'
    show
        // Future
        FutureGroup,
        // Async
        AsyncCache,
        AsyncMemoizer,
        // Stream
        StreamZip,
        StreamQueue,
        StreamGroup,
        StreamSplitter;
