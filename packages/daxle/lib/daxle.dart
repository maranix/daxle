/// Build predictable, high-performance Dart applications with zero-overhead data modeling, concurrency, and stream transformations.
///
/// `daxle` provides type-safe utilities, zero-cost map querying, concurrency scheduling,
/// deep structural equality, stream transformation operators, and declarative
/// compile-time annotations for modern Dart 3+.
///
/// This library exports core utilities and declarative code-generation annotations:
///
/// - [QueryMap]: Zero-cost extension type for type-safe nested querying over maps with support for embedded lists and non-string keys.
/// - [Concurrency]: Extension type for fine-grained async worker pool limits (`sequential`, `unbounded`, `bounded(limit)`), [Concurrency.dispatch], and [Concurrency.process].
/// - **Equality Utilities**: Collection-aware deep equality checks ([$deepEquals], [$listEquals], [$setEquals], [$mapEquals]) and hash code calculators ([$deepHashCode]).
/// - **Stream Transformation Utilities**: Comprehensive stream operator extensions from `package:stream_transform` (such as `debounce`, `throttle`, `audit`, `buffer`, `combineLatest`, `merge`, `switchMap`, `scan`, `tap`, and `whereType`).
/// - **Async Utilities**: Re-exports of key utilities from `package:async` (like [FutureGroup], [AsyncCache], [AsyncMemoizer], [StreamZip], [StreamQueue], [StreamGroup], and [StreamSplitter]).
/// - **Compile-Time Codegen Annotations**: Declarative annotations ([Serialize], [Deserialize], [CopyWith], [EqualsAndHashCode], [Stringify], [AnnotationBundle], [SerializedValue], [Fallback], [Flatten], [Ignore], and [CaseStyle]) paired with `package:daxle_gen` in `dev_dependencies` for zero-drift AST code generation.
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
///   final hasDb = query.has('services.database'); // true (key exists with null value)
///   final hasCache = query.has('services.cache'); // false (key does not exist)
/// }
/// ```
///
/// ---
///
/// ## `Concurrency`
///
/// Fine-grained control over asynchronous worker scheduling across the event loop:
///
/// - `Concurrency.sequential`: Runs tasks 1 by 1 in strict sequence.
/// - `Concurrency.unbounded`: Dispatches all tasks simultaneously in parallel without limits.
/// - `Concurrency.bounded(int poolSize)`: Executes tasks using a **sliding-window worker pool**.
///   Fast tasks never wait for slow tasks; available workers immediately pull the next task from the queue.
/// - **Standalone `dispatch` & `process`**: Use `concurrency.dispatch(items, worker)` to process raw collections without boilerplate, or `concurrency.process(thunks)` for zero-arg task closures.
/// - **Early Termination (`shouldStop`)**: Halts worker queue consumption as soon as a stop condition is met,
///   protecting your system from running redundant operations when a failure or target state is reached.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// void main() async {
///   final urls = ['https://api.a.com', 'https://api.b.com', 'https://api.c.com'];
///
///   // Process concurrently with a pool limit of 2:
///   final results = await Concurrency.bounded(2).dispatch(
///     urls,
///     (url) => httpGet(url),
///   );
/// }
/// ```
///
/// ---
///
/// ## Codegen Annotations & Data Classes
///
/// `daxle` provides compile-time annotations that define functional serialization,
/// deep immutable copy lenses, structural equality, and string representations.
/// The annotations introduce zero runtime overhead or reflective dependencies. Code is
/// synthesized at compile time by adding `package:daxle_gen` to your `dev_dependencies`:
///
/// ### Core Annotations:
/// - [Serialize] / [serialize]: Marks a class, enum, or extension type for functional serialization (`toMap` / `toValue`).
/// - [Deserialize] / [deserialize]: Marks a class, enum, or extension type for functional deserialization (`fromJson` / `fromMap` / `fromValue`).
/// - [CopyWith] / [copyWith]: Generates typed immutable copy proxies supporting chained deep mutations (such as `user.copyWith.address.city(name: 'NYC')`) returning the root type, and `copyWithNull` for explicit nullification.
/// - [EqualsAndHashCode] / [equalsAndHashCode]: Generates tiered collection-aware `operator ==` and `hashCode` implementations.
/// - [Stringify] / [stringify]: Generates clean `toString` representations for classes and enums.
/// - [AnnotationBundle]: Combines multiple annotations into reusable named constants (e.g. `@DataClass`).
///
/// ### Member & Field Annotations:
/// - [SerializedValue]: Customizes the wire key name, binds alternative aliases (`aliases: [...]`), or supplies a custom [DaxleJsonConverter].
/// - [Fallback]: Injects default fallback values for null or missing fields, or designates fallback enum cases.
/// - [Flatten] / [flatten]: Inlines child object properties directly into the parent JSON map.
/// - [Ignore] / [ignore]: Excludes a field completely from all generated logic.
/// - [CaseStyle]: Controls bidirectional naming conventions (such as `snakeCase`, `kebabCase`, `camelCase`).
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// part 'user.daxle.dart';
///
/// const DataClass = AnnotationBundle([
///   Serialize(),
///   Deserialize(),
///   CopyWith(),
///   EqualsAndHashCode(),
///   Stringify(),
/// ]);
///
/// @DataClass
/// class User(
///   @SerializedValue('user_id', aliases: ['id'])
///   final String id,
///   final String name,
///   @Fallback('user')
///   final String role,
///   @ignore
///   final String cachedToken,
/// ) with _$User;
/// ```
///
/// ---
///
/// ## Stream Transformation Utilities
///
/// `daxle` re-exports the complete set of reactive stream transformation extensions from `package:stream_transform`:
///
/// - **Rate Limiting & Buffering**:
///   - `stream.debounce(duration)`: Emits only after a specified quiet window has elapsed.
///   - `stream.throttle(duration)`: Emits the initial event and blocks subsequent events for a duration.
///   - `stream.audit(duration)`: Waits for quiet periods and emits the most recent event.
///   - `stream.buffer(trigger)`: Gathers events until a trigger stream emits.
/// - **Combining & Merging**:
///   - `stream.combineLatest(other, combiner)`: Pairs the latest events from multiple streams.
///   - `stream.merge(other)` / `stream.mergeAll(others)`: Interleaves events from multiple streams.
///   - `stream.followedBy(other)`: Chains an alternate stream after the source terminates.
/// - **Higher-Order Switching**:
///   - `stream.switchMap(mapper)`: Flattens stream-of-streams, automatically canceling stale inner subscriptions.
/// - **Transformation & Filtering**:
///   - `stream.scan(initial, accumulator)`: Yields successive cumulative accumulator states.
///   - `stream.tap(callback)`: Observes stream items for side effects without extra subscriptions.
///   - `stream.whereType<T>()`: Filters stream events by runtime type.
///   - `stream.takeUntil(future)`: Closes stream when an asynchronous future completes.
///
/// ### Example:
///
/// ```dart
/// import 'dart:async';
/// import 'package:daxle/daxle.dart';
///
/// void main() async {
///   final clicks = StreamController<String>();
///
///   // Debounce search query input to prevent redundant network requests:
///   final queries = clicks.stream
///       .debounce(const Duration(milliseconds: 300))
///       .tap((query) => print('Querying: $query'));
///
///   queries.listen(print);
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
library;

export 'src/annotations/codegen.dart';
export 'src/util/concurrency.dart';
export 'src/util/equality.dart';
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

// Export stream transformation operators from `stream_transform` package
export 'package:stream_transform/stream_transform.dart';
