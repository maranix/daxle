import '../types/option.dart';
import '../types/either.dart';
import '../types/task_either.dart';

// =============================================================================
// OPTION RECORD EXTENSIONS (2, 3, 4, 5)
// =============================================================================

/// Extension methods for Dart [Record] tuples of size 2 containing [Option]s.
extension OptionRecord2Extension<A, B> on (Option<A>, Option<B>) {
  /// {@template option_record_zipped}
  /// Zips the options in this record into a single [Option] containing a record of values.
  /// {@endtemplate}
  Option<(A, B)> zipped() {
    return $1.flatMap((a) => $2.map((b) => (a, b)));
  }

  /// {@template option_record_map}
  /// Transforms the zipped record of values using function [f] if all options in the record are [Some].
  /// {@endtemplate}
  Option<R> map<R>(R Function(A a, B b) f) {
    return zipped().map((t) => f(t.$1, t.$2));
  }

  /// {@template option_record_flat_map}
  /// Chains a new [Option] computation using function [f] if all options in the record are [Some].
  /// {@endtemplate}
  Option<R> flatMap<R>(Option<R> Function(A a, B b) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2));
  }

  /// {@template option_record_filter}
  /// Filters the zipped record if all options in the record are [Some], retaining it only if [predicate] returns true.
  /// {@endtemplate}
  Option<(A, B)> filter(bool Function(A a, B b) predicate) {
    return zipped().flatMap(
      (t) => predicate(t.$1, t.$2) ? Option.some(t) : const Option.none(),
    );
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [Option]s.
extension OptionRecord3Extension<A, B, C> on (Option<A>, Option<B>, Option<C>) {
  /// {@macro option_record_zipped}
  Option<(A, B, C)> zipped() {
    return $1.flatMap((a) => $2.flatMap((b) => $3.map((c) => (a, b, c))));
  }

  /// {@macro option_record_map}
  Option<R> map<R>(R Function(A a, B b, C c) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3));
  }

  /// {@macro option_record_flat_map}
  Option<R> flatMap<R>(Option<R> Function(A a, B b, C c) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3));
  }

  /// {@macro option_record_filter}
  Option<(A, B, C)> filter(bool Function(A a, B b, C c) predicate) {
    return zipped().flatMap(
      (t) => predicate(t.$1, t.$2, t.$3) ? Option.some(t) : const Option.none(),
    );
  }
}

/// Extension methods for Dart [Record] tuples of size 4 containing [Option]s.
extension OptionRecord4Extension<A, B, C, D>
    on (Option<A>, Option<B>, Option<C>, Option<D>) {
  /// {@macro option_record_zipped}
  Option<(A, B, C, D)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap((b) => $3.flatMap((c) => $4.map((d) => (a, b, c, d)))),
    );
  }

  /// {@macro option_record_map}
  Option<R> map<R>(R Function(A a, B b, C c, D d) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// {@macro option_record_flat_map}
  Option<R> flatMap<R>(Option<R> Function(A a, B b, C c, D d) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// {@macro option_record_filter}
  Option<(A, B, C, D)> filter(bool Function(A a, B b, C c, D d) predicate) {
    return zipped().flatMap(
      (t) => predicate(t.$1, t.$2, t.$3, t.$4)
          ? Option.some(t)
          : const Option.none(),
    );
  }
}

/// Extension methods for Dart [Record] tuples of size 5 containing [Option]s.
extension OptionRecord5Extension<A, B, C, D, E>
    on (Option<A>, Option<B>, Option<C>, Option<D>, Option<E>) {
  /// {@macro option_record_zipped}
  Option<(A, B, C, D, E)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap(
        (b) => $3.flatMap(
          (c) => $4.flatMap((d) => $5.map((e) => (a, b, c, d, e))),
        ),
      ),
    );
  }

  /// {@macro option_record_map}
  Option<R> map<R>(R Function(A a, B b, C c, D d, E e) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// {@macro option_record_flat_map}
  Option<R> flatMap<R>(Option<R> Function(A a, B b, C c, D d, E e) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// {@macro option_record_filter}
  Option<(A, B, C, D, E)> filter(
    bool Function(A a, B b, C c, D d, E e) predicate,
  ) {
    return zipped().flatMap(
      (t) => predicate(t.$1, t.$2, t.$3, t.$4, t.$5)
          ? Option.some(t)
          : const Option.none(),
    );
  }
}

// =============================================================================
// EITHER RECORD EXTENSIONS (2, 3, 4, 5)
// =============================================================================

/// Extension methods for Dart [Record] tuples of size 2 containing [Either]s.
extension EitherRecord2Extension<L, A, B> on (Either<L, A>, Either<L, B>) {
  /// {@template either_record_zipped}
  /// Zips the eithers in this record into a single [Either] containing a record of values.
  /// {@endtemplate}
  Either<L, (A, B)> zipped() {
    return $1.flatMap((a) => $2.map((b) => (a, b)));
  }

  /// {@template either_record_map}
  /// Transforms the zipped record of values using function [f] if all eithers in the record are [Right].
  /// {@endtemplate}
  Either<L, R> map<R>(R Function(A a, B b) f) {
    return zipped().map((t) => f(t.$1, t.$2));
  }

  /// {@template either_record_flat_map}
  /// Chains a new [Either] computation using function [f] if all eithers in the record are [Right].
  /// {@endtemplate}
  Either<L, R> flatMap<R>(Either<L, R> Function(A a, B b) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2));
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [Either]s.
extension EitherRecord3Extension<L, A, B, C>
    on (Either<L, A>, Either<L, B>, Either<L, C>) {
  /// {@macro either_record_zipped}
  Either<L, (A, B, C)> zipped() {
    return $1.flatMap((a) => $2.flatMap((b) => $3.map((c) => (a, b, c))));
  }

  /// {@macro either_record_map}
  Either<L, R> map<R>(R Function(A a, B b, C c) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3));
  }

  /// {@macro either_record_flat_map}
  Either<L, R> flatMap<R>(Either<L, R> Function(A a, B b, C c) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3));
  }
}

/// Extension methods for Dart [Record] tuples of size 4 containing [Either]s.
extension EitherRecord4Extension<L, A, B, C, D>
    on (Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>) {
  /// {@macro either_record_zipped}
  Either<L, (A, B, C, D)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap((b) => $3.flatMap((c) => $4.map((d) => (a, b, c, d)))),
    );
  }

  /// {@macro either_record_map}
  Either<L, R> map<R>(R Function(A a, B b, C c, D d) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// {@macro either_record_flat_map}
  Either<L, R> flatMap<R>(Either<L, R> Function(A a, B b, C c, D d) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4));
  }
}

/// Extension methods for Dart [Record] tuples of size 5 containing [Either]s.
extension EitherRecord5Extension<L, A, B, C, D, E>
    on (Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>) {
  /// {@macro either_record_zipped}
  Either<L, (A, B, C, D, E)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap(
        (b) => $3.flatMap(
          (c) => $4.flatMap((d) => $5.map((e) => (a, b, c, d, e))),
        ),
      ),
    );
  }

  /// {@macro either_record_map}
  Either<L, R> map<R>(R Function(A a, B b, C c, D d, E e) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// {@macro either_record_flat_map}
  Either<L, R> flatMap<R>(Either<L, R> Function(A a, B b, C c, D d, E e) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }
}

// =============================================================================
// TASKEITHER RECORD EXTENSIONS (2, 3, 4, 5)
// =============================================================================

/// Extension methods for Dart [Record] tuples of size 2 containing [TaskEither]s.
extension TaskEitherRecord2Extension<L, A, B>
    on (TaskEither<L, A>, TaskEither<L, B>) {
  /// {@template task_either_record_zipped}
  /// Runs all async computations in this record concurrently and zips their outcomes.
  /// {@endtemplate}
  TaskEither<L, (A, B)> zipped() {
    return TaskEither(() async {
      final (resA, resB) = await ($1.run(), $2.run()).wait;
      return resA.flatMap((a) => resB.map((b) => (a, b)));
    });
  }

  /// {@template task_either_record_map}
  /// Runs all async computations in this record concurrently, transforming their success values using [f].
  /// {@endtemplate}
  TaskEither<L, R> map<R>(R Function(A a, B b) f) {
    return zipped().map((t) => f(t.$1, t.$2));
  }

  /// {@template task_either_record_flat_map}
  /// Runs all async computations in this record concurrently, chaining a new task using [f].
  /// {@endtemplate}
  TaskEither<L, R> flatMap<R>(TaskEither<L, R> Function(A a, B b) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2));
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [TaskEither]s.
extension TaskEitherRecord3Extension<L, A, B, C>
    on (TaskEither<L, A>, TaskEither<L, B>, TaskEither<L, C>) {
  /// {@macro task_either_record_zipped}
  TaskEither<L, (A, B, C)> zipped() {
    return TaskEither(() async {
      final (resA, resB, resC) = await ($1.run(), $2.run(), $3.run()).wait;
      return resA.flatMap(
        (a) => resB.flatMap((b) => resC.map((c) => (a, b, c))),
      );
    });
  }

  /// {@macro task_either_record_map}
  TaskEither<L, R> map<R>(R Function(A a, B b, C c) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3));
  }

  /// {@macro task_either_record_flat_map}
  TaskEither<L, R> flatMap<R>(TaskEither<L, R> Function(A a, B b, C c) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3));
  }
}

/// Extension methods for Dart [Record] tuples of size 4 containing [TaskEither]s.
extension TaskEitherRecord4Extension<L, A, B, C, D>
    on
        (
          TaskEither<L, A>,
          TaskEither<L, B>,
          TaskEither<L, C>,
          TaskEither<L, D>,
        ) {
  /// {@macro task_either_record_zipped}
  TaskEither<L, (A, B, C, D)> zipped() {
    return TaskEither(() async {
      final (resA, resB, resC, resD) = await (
        $1.run(),
        $2.run(),
        $3.run(),
        $4.run(),
      ).wait;
      return resA.flatMap(
        (a) => resB.flatMap(
          (b) => resC.flatMap((c) => resD.map((d) => (a, b, c, d))),
        ),
      );
    });
  }

  /// {@macro task_either_record_map}
  TaskEither<L, R> map<R>(R Function(A a, B b, C c, D d) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// {@macro task_either_record_flat_map}
  TaskEither<L, R> flatMap<R>(TaskEither<L, R> Function(A a, B b, C c, D d) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4));
  }
}

/// Extension methods for Dart [Record] tuples of size 5 containing [TaskEither]s.
extension TaskEitherRecord5Extension<L, A, B, C, D, E>
    on
        (
          TaskEither<L, A>,
          TaskEither<L, B>,
          TaskEither<L, C>,
          TaskEither<L, D>,
          TaskEither<L, E>,
        ) {
  /// {@macro task_either_record_zipped}
  TaskEither<L, (A, B, C, D, E)> zipped() {
    return TaskEither(() async {
      final (resA, resB, resC, resD, resE) = await (
        $1.run(),
        $2.run(),
        $3.run(),
        $4.run(),
        $5.run(),
      ).wait;
      return resA.flatMap(
        (a) => resB.flatMap(
          (b) => resC.flatMap(
            (c) => resD.flatMap((d) => resE.map((e) => (a, b, c, d, e))),
          ),
        ),
      );
    });
  }

  /// {@macro task_either_record_map}
  TaskEither<L, R> map<R>(R Function(A a, B b, C c, D d, E e) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// {@macro task_either_record_flat_map}
  TaskEither<L, R> flatMap<R>(
    TaskEither<L, R> Function(A a, B b, C c, D d, E e) f,
  ) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }
}
