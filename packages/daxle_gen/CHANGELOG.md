## 0.3.1 (Preview)

- **NEW FEATURES (PREVIEW & EXPERIMENTAL)**:
  - **State Machine Generation (`@StateMachine`)**:
    - Synthesizes `_$ClassNameMachine` mixin for declarative, compile-time verified state machine workflows.
    - Generates compile-time verified static transition table (`_$transitions`) restricting valid transitions.
    - Synthesizes `FutureOr<void> on<State>(TransitionScope<State> scope, Event event)` flow handler stubs for async flow roots.
    - Provides concrete default implementations for synchronous, trivial, or single-target transitions.
    - Implements epoch-based cancellation (`_daxleEpoch`) to invalidate stale asynchronous transition scopes when newer events arrive.
    - Generates pattern-matching `dispatch(Event event)` with fail-fast `InvalidFlowException` validation against illegal transitions.
    - Supports explicit generics (`@StateMachine<TState, TEvent>`) and automatic type inference from declared flows or `Bloc` supertypes.
    - Supports self-loop state transitions (`Flow(from: State, to: State)`).
  - **Sensitive Field Redaction (`@redact` / `Redact`)**:
    - Generates sanitized `toString()` representations preventing secrets, passwords, tokens, and PII from leaking into logs.
    - Synthesizes dedicated `toDebugMap()` method with configurable masks (`mask`, `preserveLength`), while keeping standard wire-format `toMap()` unmodified.

- **DOCUMENTATION**:
  - Marked `StateMachine` generation as **preview and experimental** across documentation and guides.
  - Documented setup instructions, CLI commands, state machine workflow patterns, and sensitive field redaction in `README.md`.

## 0.3.0 (2026-09-30)

- **BREAKING CHANGES**:
  - Removed legacy `SerializeEnum` and `DeserializeEnum` annotations. Use unified `@Serialize()` and `@Deserialize()` annotations for enum declarations.

- **NEW FEATURES**:
  - **Dart 3 Record Serialization & Deserialization**:
    - Full serialization and deserialization support for Dart 3 record types in model fields and top-level record typedefs.
    - Positional records serialize as lists (`[a, b]`) and deserialize using `<name>FromList` functions and `.to<Name>()` extensions on `List<dynamic>`.
    - Named records serialize as key-value maps (`{'name': a, 'age': b}`) and deserialize using `<name>FromMap` functions and `.to<Name>()` extensions on `Map<String, dynamic>`.
    - Generated standalone top-level record typedef extensions (`${alias}ToListExtension`, `${alias}ListExtension`, `${alias}ToMapExtension`, `${alias}MapExtension`).
    - Full AST parser support for nested record signatures in `ParsedType`.
  - **CLI Enhancements**:
    - Added `--clean` (`-c`) flag to remove all generated `.daxle.dart` files recorded in `.dart_tool/daxle_gen/manifest.json`.
    - Added `--force` flag to force regeneration of all files ignoring cached content hashes.
    - Enhanced `--watch` file change reactivity and debouncing, invalidating cache upon source modifications to ensure instantaneous rebuilds.

- **PERFORMANCE & REFACTORING**:
  - Re-architected parser into an AST visitor (`DaxleFileVisitor`) subclassing analyzer's `RecursiveAstVisitor` for scalable, modular syntax tree inspection.
  - Modularized annotation parsing into standalone `AnnotationHandler` implementations registered within `AnnotationRegistry`.

- **DOCUMENTATION**:
  - Overhauled `README.md` with complete documentation covering CLI flags, Native Assets hooks, records, deep `copyWith` proxies, equality tiering, `AnnotationBundle`, and member annotations.
  - Added thorough Effective Dart documentation comments to library root and exposed complete public API exports.

## 0.2.1 (2026-09-28)

- **BUG FIXES**:
  - Fixed annotation configuration parameters (such as `ignoreFields` and `caseStyle`) being dropped when expanding `AnnotationBundle`.
  - Removed lingering debug print statements.

## 0.2.0 (2026-09-28)

- **NEW FEATURES**:
  - **Deep / Proxied `copyWith`**:
    - Generated `$ClassNameCopyWithProxy<$Res>` allowing fluent chained mutation across nested models (e.g., `user.copyWith.address.city(name: 'NYC')`) returning the root type.
    - Identity checks in `copyWith` invocations to avoid unnecessary object allocations when fields remain identical.
    - Added `copyWithNull({bool field = false})` method to explicitly set nullable properties to `null`.
  - **Bundled / Composite Annotations (`AnnotationBundle`)**:
    - Added support for combining multiple annotations into a single reusable constant (e.g., `const DataClass = AnnotationBundle([Serialize(), Deserialize(), CopyWith(), EqualsAndHashCode(), Stringify()])`).
  - **Part-File Support**:
    - Generator automatically detects and resolves source files that declare `part of '<library>.dart'`, walking up to the library root and generating proper `part of` declarations.

## 0.1.2 (2026-09-28)

- **NEW FEATURES**:
  - Added support for non-string map keys (e.g., `Map<int, String>`, `Map<DateTime, Object>`, etc.) in functional serialization and deserialization.
  - Extracted deep collection equality utilities (`$listEquals`, `$setEquals`, `$mapEquals`, `$deepEquals`, `$listHashCode`, `$setHashCode`, `$mapHashCode`, `$deepHashCode`).

## 0.1.1 (2026-09-27)

- **NEW FEATURES**:
  - Added Extension Type serialization and deserialization (`extension type Id(String value)`).
  - Cross-file enum resolution: properly resolve enum types defined across different files in the project.
- **REFACTORING**:
  - Removed legacy class annotation aliases to unify configuration around `@Serialize` and `@Deserialize`.
  - Added MIT `LICENSE`.

## 0.1.0 (2026-09-27)

- **INITIAL RELEASE**:
  - Initial standalone release of `daxle_gen` decoupled from the core `daxle` runtime package.
  - Zero-dependency functional code generator designed for Dart 3 switch pattern matching and primary constructors.
  - Generates `<name>FromMap`, `<name>ToMap`, and `${name}ToMapExtension`.
  - Sealed class polymorphism support with default (`'type'`) or custom discriminators and subclass tags.
  - Enum mapping with `<enum>ToValue`, `<enum>FromValue`, private lookup maps (`const _<enum>EnumMap`), and entry-level overrides.
  - Member annotations: `@SerializedValue` (wire names, alternative aliases, custom `DaxleJsonConverter`), `@Fallback`, `@Flatten`, and `@Ignore` / `@ignore`.
  - Value equality (`operator ==`) and `hashCode` generation with tiered field sorting (cheap primitives, objects, collections last).
  - Stringify (`toString()`) generation for classes and enums (`@Stringify`).
  - Comprehensive `FormatException` diagnostics with expected types, actual types, and `source` JSON payload.
  - SHA-256 content caching and CLI runner with glob filtering and `--check` drift validation.
  - Native Assets build hook integration (`hook/build.dart`).
