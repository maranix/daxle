import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Result.ok / Ok holds value and reports correct flags', () {
      final Result<int, String> res = Result.ok(42);
      expect(res.isOk, isTrue);
      expect(res.isErr, isFalse);
      expect(res.unwrap(), equals(42));
      expect(res.expect('should not throw'), equals(42));
      expect(res.getOrElse((e) => 0), equals(42));
      expect(res, equals(const Ok<int, String>(42)));
      expect(res.toString(), equals('Ok(42)'));
    });

    test('Result.err / Err holds error and reports correct flags', () {
      final st = StackTrace.current;
      final Result<int, String> res = Result.err('error', st);
      expect(res.isOk, isFalse);
      expect(res.isErr, isTrue);
      expect(() => res.unwrap(), throwsA(equals('error')));
      expect(() => res.expect('oops'), throwsA(isA<StateError>()));
      expect(res.getOrElse((e) => 0), equals(0));
      expect(res, equals(Err<int, String>('error', st)));
      expect(res.toString(), contains('Err(error, stackTrace:'));
    });

    test('Result.from catches errors and returns Err', () {
      final resSuccess = Result.from<int, String>(() => 42);
      final resFailure = Result.from<int, String>(
        () => throw Exception('err'),
        onError: (e) => e.toString(),
      );

      expect(resSuccess, equals(const Ok<int, String>(42)));
      expect(resFailure.isErr, isTrue);
      expect(
        resFailure.fold(onOk: (v) => '', onErr: (e, st) => e),
        equals('Exception: err'),
      );
    });

    test('Result.fromAsync catches errors asynchronously', () async {
      final resSuccess = await Result.fromAsync<int, String>(() async => 42);
      final resFailure = await Result.fromAsync<int, String>(
        () async => throw Exception('err'),
        onError: (e) => e.toString(),
      );

      expect(resSuccess, equals(const Ok<int, String>(42)));
      expect(resFailure.isErr, isTrue);
    });

    test('map and mapErr transform correctly', () {
      final Result<int, String> ok = const Result.ok(10);
      final Result<int, String> err = const Result.err('oops');

      expect(ok.map((v) => v * 2), equals(const Ok<int, String>(20)));
      expect(err.map((v) => v * 2), equals(const Err<int, String>('oops')));

      expect(ok.mapErr((e) => '$e!'), equals(const Ok<int, String>(10)));
      expect(err.mapErr((e) => '$e!'), equals(const Err<int, String>('oops!')));
    });

    test('flatMap chains computations', () {
      final Result<int, String> ok = const Result.ok(10);
      final Result<int, String> err = const Result.err('oops');

      expect(ok.flatMap((v) => Ok(v * 2)), equals(const Ok<int, String>(20)));
      expect(
        err.flatMap((v) => Ok(v * 2)),
        equals(const Err<int, String>('oops')),
      );
    });

    test('fold projects values', () {
      final Result<int, String> ok = const Result.ok(42);
      final Result<int, String> err = const Result.err('oops');

      expect(
        ok.fold(onOk: (v) => 'S: $v', onErr: (e, st) => 'F: $e'),
        equals('S: 42'),
      );
      expect(
        err.fold(onOk: (v) => 'S: $v', onErr: (e, st) => 'F: $e'),
        equals('F: oops'),
      );
    });

    test('orElse fallback', () {
      final Result<int, String> ok = const Result.ok(10);
      final Result<int, String> err = const Result.err('oops');

      expect(
        ok.orElse((e, st) => const Ok(42)),
        equals(const Ok<int, String>(10)),
      );
      expect(
        err.orElse((e, st) => const Ok(42)),
        equals(const Ok<int, String>(42)),
      );
    });

    test('toOption and toEither conversions', () {
      final Result<int, String> ok = const Result.ok(42);
      final Result<int, String> err = const Result.err('oops');

      expect(ok.toOption(), equals(Option.some(42)));
      expect(err.toOption(), equals(Option.none()));

      expect(ok.toEither(), equals(const Right<String, int>(42)));
      expect(err.toEither(), equals(const Left<String, int>('oops')));
    });

    test('result() extension on sync and async functions', () async {
      int syncSuccess() => 42;
      int syncError() => throw 'oops';
      Future<int> asyncSuccess() async => 42;
      Future<int> asyncError() async => throw 'oops';

      expect(syncSuccess.result<String>(), equals(const Ok<int, String>(42)));
      expect(
        syncError.result<String>(),
        equals(const Err<int, String>('oops')),
      );

      expect(
        await asyncSuccess.result<String>(),
        equals(const Ok<int, String>(42)),
      );
      expect(
        await asyncError.result<String>(),
        equals(const Err<int, String>('oops')),
      );
    });
  });
}
