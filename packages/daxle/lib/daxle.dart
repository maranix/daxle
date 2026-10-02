/// Build predictable, high-performance Dart applications with zero-overhead data modeling and map querying.
///
/// `package:daxle/daxle.dart` is the primary entrypoint for:
/// - **Compile-Time Codegen Annotations**: Declarative annotations ([Serialize], [Deserialize], [CopyWith], [EqualsAndHashCode], [Stringify], [AnnotationBundle], [SerializedValue], [Fallback], [Flatten], [Ignore], and [CaseStyle]) paired with `package:daxle_gen` in `dev_dependencies` for pure AST code generation.
/// - [QueryMap]: Zero-cost extension type for type-safe nested querying over maps with support for embedded lists and non-string keys.
/// - **Structural Equality Utilities**: Collection-aware deep equality checks ([$deepEquals], [$listEquals], [$setEquals], [$mapEquals]) and hash code calculators ([$deepHashCode]).
///
/// For asynchronous and reactive stream utilities (`Concurrency`, `Pool`, `stream_transform`, `FutureGroup`, `AsyncCache`),
/// import `package:daxle/async.dart`:
/// ```dart
/// import 'package:daxle/daxle.dart';
/// import 'package:daxle/async.dart';
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
///   final hasDb = query.has('services.database'); // true (key exists with null value)
///   final hasCache = query.has('services.cache'); // false (key does not exist)
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
library;

export 'src/annotations/codegen.dart';
export 'src/state_machine/exceptions.dart';
export 'src/state_machine/flow.dart';
export 'src/state_machine/transition_scope.dart';
export 'src/util/equality.dart';
export 'src/util/query_map.dart';

