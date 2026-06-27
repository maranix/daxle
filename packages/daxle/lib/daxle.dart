/// `daxle` is a library that provides a set of functional programming constructs
/// inspired by languages like Rust and Haskell. It is designed to enhance the
/// robustness and clarity of Dart applications by offering explicit, type-safe
/// mechanisms for handling fallible operations, optional values, and deferred
/// computation pipelines.
///
/// This approach promotes safer error management and reduces the reliance on
/// traditional mechanisms such as throwing exceptions or using `null`.
///
/// This library exports five core concepts/types:
///
/// - [Option]: For values that may or may not be present (replacing nullable `T?`).
/// - [Either]: For values that can be one of two distinct types (typically Left for error, Right for success).
/// - [TaskEither]: For lazy, asynchronous computations that can fail.
/// - [Pipeline] and [AsyncPipeline]: For composing deferred pipelines of operations.
/// - [Unit]: A type representing the absence of a meaningful value.
/// - **Record Extensions**: Functional mapping, flatMapping, filtering, and zipping extensions on 2-tuples, 3-tuples, 4-tuples, and 5-tuples containing [Option], [Either], or [TaskEither].
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
///   return .none();
/// }
///
/// void main() {
///   final user = findUser('123');
///   final userName = user.getOrElse('Guest');
///   print('User: $userName'); // Prints: User: Alice
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
///   result.fold(
///     (error) => print('Error: $error'),
///     (value) => print('Value: $value'), // Prints: Value: 123
///   );
/// }
/// ```
///
/// ---
///
/// ## `TaskEither<L, R>`
///
/// The [TaskEither] type represents a lazy, asynchronous computation that can fail.
/// It wraps a function returning a `Future<Either<L, R>>`, providing significant
/// advantages over a raw `Future<Either<L, R>>` and standard [AsyncPipeline]s:
///
/// 1. **Lazy Execution**: Futures are eager and execute immediately. Like [AsyncPipeline],
///    [TaskEither] is lazy and only runs when `.run()` is called, allowing easy retries
///    and fallbacks (via `.orElse`).
/// 2. **Monadic Error Short-Circuiting**: Unlike [AsyncPipeline] (which relies on standard
///    exceptions propagating until caught by `recover`), [TaskEither] embeds the [Either]
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
/// ## `Pipeline<T>` & `AsyncPipeline<T>`
///
/// [Pipeline] and [AsyncPipeline] provide deferred, type-safe composition of
/// synchronous and asynchronous operations, with robust tap, recovery, finalization,
/// and concurrent execution (via zip) capabilities.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// void main() async {
///   // Synchronous Pipeline
///   final syncVal = Pipeline(() => 5)
///       .pipe((x) => x * 2)
///       .tap((x) => print('Tapped: $x'))
///       .run(); // Returns 10
///
///   // Asynchronous Pipeline
///   final asyncVal = await AsyncPipeline(() => Future.value(10))
///       .pipe((x) => Future.value(x * 5))
///       .run(); // Resolves to 50
/// }
/// ```
library;

export 'src/option.dart';
export 'src/unit.dart';
export 'src/pipeline.dart';
export 'src/task_either.dart';
export 'src/either.dart';
export 'src/record_extensions.dart';
