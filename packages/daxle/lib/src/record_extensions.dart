import 'option.dart';
import 'either.dart';
import 'task_either.dart';

// =============================================================================
// OPTION RECORD EXTENSIONS (2, 3, 4, 5)
// =============================================================================

/// Extension methods for Dart [Record] tuples of size 2 containing [Option]s.
extension OptionRecord2Extension<A, B> on (Option<A>, Option<B>) {
  /// Zips both options into a single option containing a record of values.
  Option<(A, B)> zipped() {
    return $1.flatMap((a) => $2.map((b) => (a, b)));
  }

  /// Transforms the zipped record of values using function [f] if both options are [Some].
  Option<R> map<R>(R Function(A a, B b) f) {
    return zipped().map((t) => f(t.$1, t.$2));
  }

  /// Chains a new [Option] computation using function [f] if both options are [Some].
  Option<R> flatMap<R>(Option<R> Function(A a, B b) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2));
  }

  /// Filters the zipped record if both are [Some], retaining it only if [predicate] returns true.
  Option<(A, B)> filter(bool Function(A a, B b) predicate) {
    return zipped().flatMap(
      (t) => predicate(t.$1, t.$2) ? Option.some(t) : const Option.none(),
    );
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [Option]s.
extension OptionRecord3Extension<A, B, C> on (Option<A>, Option<B>, Option<C>) {
  /// Zips all three options into a single option containing a record of values.
  Option<(A, B, C)> zipped() {
    return $1.flatMap((a) => $2.flatMap((b) => $3.map((c) => (a, b, c))));
  }

  /// Transforms the zipped record of values using function [f] if all options are [Some].
  Option<R> map<R>(R Function(A a, B b, C c) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3));
  }

  /// Chains a new [Option] computation using function [f] if all options are [Some].
  Option<R> flatMap<R>(Option<R> Function(A a, B b, C c) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3));
  }

  /// Filters the zipped record if all are [Some], retaining it only if [predicate] returns true.
  Option<(A, B, C)> filter(bool Function(A a, B b, C c) predicate) {
    return zipped().flatMap(
      (t) => predicate(t.$1, t.$2, t.$3) ? Option.some(t) : const Option.none(),
    );
  }
}

/// Extension methods for Dart [Record] tuples of size 4 containing [Option]s.
extension OptionRecord4Extension<A, B, C, D>
    on (Option<A>, Option<B>, Option<C>, Option<D>) {
  /// Zips all four options into a single option containing a record of values.
  Option<(A, B, C, D)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap((b) => $3.flatMap((c) => $4.map((d) => (a, b, c, d)))),
    );
  }

  /// Transforms the zipped record of values using function [f] if all options are [Some].
  Option<R> map<R>(R Function(A a, B b, C c, D d) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// Chains a new [Option] computation using function [f] if all options are [Some].
  Option<R> flatMap<R>(Option<R> Function(A a, B b, C c, D d) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// Filters the zipped record if all are [Some], retaining it only if [predicate] returns true.
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
  /// Zips all five options into a single option containing a record of values.
  Option<(A, B, C, D, E)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap(
        (b) => $3.flatMap(
          (c) => $4.flatMap((d) => $5.map((e) => (a, b, c, d, e))),
        ),
      ),
    );
  }

  /// Transforms the zipped record of values using function [f] if all options are [Some].
  Option<R> map<R>(R Function(A a, B b, C c, D d, E e) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// Chains a new [Option] computation using function [f] if all options are [Some].
  Option<R> flatMap<R>(Option<R> Function(A a, B b, C c, D d, E e) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// Filters the zipped record if all are [Some], retaining it only if [predicate] returns true.
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
  /// Zips both eithers into a single either containing a record of values.
  Either<L, (A, B)> zipped() {
    return $1.flatMap((a) => $2.map((b) => (a, b)));
  }

  /// Transforms the zipped record of values using function [f] if both eithers are [Right].
  Either<L, R> map<R>(R Function(A a, B b) f) {
    return zipped().map((t) => f(t.$1, t.$2));
  }

  /// Chains a new [Either] computation using function [f] if both eithers are [Right].
  Either<L, R> flatMap<R>(Either<L, R> Function(A a, B b) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2));
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [Either]s.
extension EitherRecord3Extension<L, A, B, C>
    on (Either<L, A>, Either<L, B>, Either<L, C>) {
  /// Zips all three eithers into a single either containing a record of values.
  Either<L, (A, B, C)> zipped() {
    return $1.flatMap((a) => $2.flatMap((b) => $3.map((c) => (a, b, c))));
  }

  /// Transforms the zipped record of values using function [f] if all eithers are [Right].
  Either<L, R> map<R>(R Function(A a, B b, C c) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3));
  }

  /// Chains a new [Either] computation using function [f] if all eithers are [Right].
  Either<L, R> flatMap<R>(Either<L, R> Function(A a, B b, C c) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3));
  }
}

/// Extension methods for Dart [Record] tuples of size 4 containing [Either]s.
extension EitherRecord4Extension<L, A, B, C, D>
    on (Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>) {
  /// Zips all four eithers into a single either containing a record of values.
  Either<L, (A, B, C, D)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap((b) => $3.flatMap((c) => $4.map((d) => (a, b, c, d)))),
    );
  }

  /// Transforms the zipped record of values using function [f] if all eithers are [Right].
  Either<L, R> map<R>(R Function(A a, B b, C c, D d) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// Chains a new [Either] computation using function [f] if all eithers are [Right].
  Either<L, R> flatMap<R>(Either<L, R> Function(A a, B b, C c, D d) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4));
  }
}

/// Extension methods for Dart [Record] tuples of size 5 containing [Either]s.
extension EitherRecord5Extension<L, A, B, C, D, E>
    on (Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>) {
  /// Zips all five eithers into a single either containing a record of values.
  Either<L, (A, B, C, D, E)> zipped() {
    return $1.flatMap(
      (a) => $2.flatMap(
        (b) => $3.flatMap(
          (c) => $4.flatMap((d) => $5.map((e) => (a, b, c, d, e))),
        ),
      ),
    );
  }

  /// Transforms the zipped record of values using function [f] if all eithers are [Right].
  Either<L, R> map<R>(R Function(A a, B b, C c, D d, E e) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// Chains a new [Either] computation using function [f] if all eithers are [Right].
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
  /// Runs both async computations concurrently and zips their outcomes.
  TaskEither<L, (A, B)> zipped() {
    return TaskEither(() async {
      final (resA, resB) = await ($1.run(), $2.run()).wait;
      return resA.flatMap((a) => resB.map((b) => (a, b)));
    });
  }

  /// Runs both async computations concurrently, transforming their success values using [f].
  TaskEither<L, R> map<R>(R Function(A a, B b) f) {
    return zipped().map((t) => f(t.$1, t.$2));
  }

  /// Runs both async computations concurrently, chaining a new task using [f].
  TaskEither<L, R> flatMap<R>(TaskEither<L, R> Function(A a, B b) f) {
    return zipped().flatMap((t) => f(t.$1, t.$2));
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [TaskEither]s.
extension TaskEitherRecord3Extension<L, A, B, C>
    on (TaskEither<L, A>, TaskEither<L, B>, TaskEither<L, C>) {
  /// Runs all three async computations concurrently and zips their outcomes.
  TaskEither<L, (A, B, C)> zipped() {
    return TaskEither(() async {
      final (resA, resB, resC) = await ($1.run(), $2.run(), $3.run()).wait;
      return resA.flatMap(
        (a) => resB.flatMap((b) => resC.map((c) => (a, b, c))),
      );
    });
  }

  /// Runs all three async computations concurrently, transforming their success values using [f].
  TaskEither<L, R> map<R>(R Function(A a, B b, C c) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3));
  }

  /// Runs all three async computations concurrently, chaining a new task using [f].
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
  /// Runs all four async computations concurrently and zips their outcomes.
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

  /// Runs all four async computations concurrently, transforming their success values using [f].
  TaskEither<L, R> map<R>(R Function(A a, B b, C c, D d) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4));
  }

  /// Runs all four async computations concurrently, chaining a new task using [f].
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
  /// Runs all five async computations concurrently and zips their outcomes.
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

  /// Runs all five async computations concurrently, transforming their success values using [f].
  TaskEither<L, R> map<R>(R Function(A a, B b, C c, D d, E e) f) {
    return zipped().map((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }

  /// Runs all five async computations concurrently, chaining a new task using [f].
  TaskEither<L, R> flatMap<R>(
    TaskEither<L, R> Function(A a, B b, C c, D d, E e) f,
  ) {
    return zipped().flatMap((t) => f(t.$1, t.$2, t.$3, t.$4, t.$5));
  }
}
