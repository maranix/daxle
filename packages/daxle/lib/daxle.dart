/// Build predictable, composable Dart applications.
///
/// `daxle` is a lightweight functional programming toolkit that replaces
/// imperative state checks and nested try/catch blocks with clean,
/// declarative pipelines. Inspired by languages like Rust and Haskell,
/// it brings robust functional primitives to modern Dart.
///
/// This library exports five core types and essential async utilities:
///
/// - [Option]: For composing optional values without imperative state checks.
/// - [Either]: For explicit, type-safe error handling and branching.
/// - [Task]: For composing lazy, asynchronous workflows.
/// - [TaskEither]: For chaining asynchronous operations that can fail, with automatic short-circuiting.
/// - [Unit]: For representing the absence of a meaningful value.
/// - **Async Utilities**: Re-exports of key utilities from `package:async` (like [FutureGroup], [AsyncCache], [AsyncMemoizer], [StreamZip], [StreamQueue], [StreamGroup], and [StreamSplitter]) for advanced asynchronous flow control.
///
/// ---
///
/// ## `Option<T>`
///
/// Compose optional values functionally. An instance of [Option] is either `Some`
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
///   final user = findUser('123');
///   final userName = user.getOrElse('Guest');
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
/// asynchronous computation that can fail (`Future<Either<L, R>>`), offering three major advantages:
///
/// 1. **Lazy Execution**: Unlike eager Futures, [TaskEither] only runs when `.run()`
///    is called, allowing you to easily build retries or fallbacks.
/// 2. **Short-Circuiting**: It embeds the [Either] state at each step. Any step
///    resolving to a [Left] short-circuits the pipeline gracefully.
/// 3. **Exception Guarding**: `TaskEither.fromFuture` automatically catches
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
///       .flatMap((user) => fetchConfig(user))
///       .run();
///
///   result.fold(
///     (error) => print('Failed: $error'),
///     (config) => print('Success: $config'),
///   );
/// }
/// ```
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

export 'src/types/option.dart';
export 'src/types/unit.dart';
export 'src/types/task.dart';
export 'src/types/task_either.dart';
export 'src/types/either.dart';
export 'src/internal/concurrency.dart';

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
