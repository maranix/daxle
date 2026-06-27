import 'option.dart';
import 'either.dart';
import 'task_either.dart';

/// Extension methods for Dart [Record] tuples of size 2 containing [Option]s.
extension OptionRecord2Extension<A, B> on (Option<A>, Option<B>) {
  /// Zips both options into a single option containing a record of values.
  ///
  /// Returns [Some] if both options are [Some], otherwise returns [None].
  Option<(A, B)> zipped() {
    return $1.flatMap((a) => $2.map((b) => (a, b)));
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [Option]s.
extension OptionRecord3Extension<A, B, C> on (Option<A>, Option<B>, Option<C>) {
  /// Zips all three options into a single option containing a record of values.
  ///
  /// Returns [Some] if all options are [Some], otherwise returns [None].
  Option<(A, B, C)> zipped() {
    return $1.flatMap((a) => $2.flatMap((b) => $3.map((c) => (a, b, c))));
  }
}

/// Extension methods for Dart [Record] tuples of size 2 containing [Either]s.
extension EitherRecord2Extension<L, A, B> on (Either<L, A>, Either<L, B>) {
  /// Zips both eithers into a single either containing a record of values.
  ///
  /// Returns [Right] if both eithers are [Right], otherwise returns the first [Left].
  Either<L, (A, B)> zipped() {
    return $1.flatMap((a) => $2.map((b) => (a, b)));
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [Either]s.
extension EitherRecord3Extension<L, A, B, C>
    on (Either<L, A>, Either<L, B>, Either<L, C>) {
  /// Zips all three eithers into a single either containing a record of values.
  ///
  /// Returns [Right] if all eithers are [Right], otherwise returns the first [Left].
  Either<L, (A, B, C)> zipped() {
    return $1.flatMap((a) => $2.flatMap((b) => $3.map((c) => (a, b, c))));
  }
}

/// Extension methods for Dart [Record] tuples of size 2 containing [TaskEither]s.
extension TaskEitherRecord2Extension<L, A, B>
    on (TaskEither<L, A>, TaskEither<L, B>) {
  /// Runs both async computations concurrently and zips their outcomes.
  ///
  /// Returns [Right] if both tasks succeed, otherwise returns the first [Left] failure.
  TaskEither<L, (A, B)> zipped() {
    return TaskEither(() async {
      final (resA, resB) = await ($1.run(), $2.run()).wait;
      return resA.flatMap((a) => resB.map((b) => (a, b)));
    });
  }
}

/// Extension methods for Dart [Record] tuples of size 3 containing [TaskEither]s.
extension TaskEitherRecord3Extension<L, A, B, C>
    on (TaskEither<L, A>, TaskEither<L, B>, TaskEither<L, C>) {
  /// Runs all three async computations concurrently and zips their outcomes.
  ///
  /// Returns [Right] if all tasks succeed, otherwise returns the first [Left] failure.
  TaskEither<L, (A, B, C)> zipped() {
    return TaskEither(() async {
      final (resA, resB, resC) = await ($1.run(), $2.run(), $3.run()).wait;
      return resA.flatMap(
        (a) => resB.flatMap((b) => resC.map((c) => (a, b, c))),
      );
    });
  }
}
