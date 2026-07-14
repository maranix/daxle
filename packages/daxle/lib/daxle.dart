/// `daxle` is a library that provides a set of functional programming constructs
/// inspired by languages like Rust and Haskell. It is designed to enhance the
/// robustness and clarity of Dart applications by offering explicit, type-safe
/// mechanisms for handling fallible operations, optional values, and deferred
/// computation pipelines.
///
/// This approach promotes safer error management and reduces the reliance on
/// traditional mechanisms such as throwing exceptions or using `null`.
///
/// This library exports seven core concepts/types/utilities:
///
/// - [Option]: For values that may or may not be present (replacing nullable `T?`).
/// - [Either]: For values that can be one of two distinct types (typically Left for error, Right for success).
/// - [Task]: For lazy, asynchronous computations.
/// - [TaskEither]: For lazy, asynchronous computations that can fail.
/// - [Unit]: A type representing the absence of a meaningful value.
/// - **Async Utilities**: Re-exports of key utilities from `package:async` (like [FutureGroup], [AsyncCache], [AsyncMemoizer], [StreamZip], [StreamQueue], [StreamGroup], and [StreamSplitter]) for advanced asynchronous flow control.
///
/// ---
///
/// ## `Option<T>`
///
/// The [Option] type is a container for an optional value. An instance of [Option]
/// is either `Some`, containing a value, or `None`, indicating the absence of a value.
/// It provides a type-safe alternative to using `null`.
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
/// The [Either] type is a generic sum type that can hold a value of one of two
/// distinct types: `Left` or `Right`. By convention, `Right` represents success
/// and `Left` represents failure.
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
/// The [Task] type represents a lazy, asynchronous computation that produces a value of type `T`.
/// Unlike a Future, a Task is lazy. The underlying computation is not started until run() is invoked.
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
/// The [TaskEither] type represents a lazy, asynchronous computation that can fail.
/// It wraps a function returning a `Future<Either<L, R>>`, providing significant
/// advantages over a raw `Future<Either<L, R>>`:
///
/// 1. **Lazy Execution**: Futures are eager and execute immediately.
///    [TaskEither] is lazy and only runs when `.run()` is called, allowing easy retries
///    and fallbacks (via `.orElse`).
/// 2. **Monadic Error Short-Circuiting**: [TaskEither] embeds the [Either]
///    state at each step. Any step resolving to a [Left] short-circuits the pipeline,
///    bypassing subsequent steps without throwing raw runtime exceptions.
/// 3. **Automatic Exception Guarding**: `TaskEither.fromFuture` catches runtime exceptions
///    and maps them automatically to a [Left] value.
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
