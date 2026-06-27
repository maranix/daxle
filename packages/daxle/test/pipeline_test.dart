import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Pipeline', () {
    test('sync pipeline successfully processes', () {
      final pipeline = Pipeline(
        () => 5,
      ).pipe((x) => x * 2).tap((x) {}).pipe((x) => 'value: $x');

      expect(pipeline.run(), equals('value: 10'));
    });

    test('recover handles exceptions', () {
      final pipeline = Pipeline<int>(
        () => throw Exception('error'),
      ).recover((e, st) => 42);

      expect(pipeline.run(), equals(42));
    });

    test('recoverWith chains fallback pipeline', () {
      final pipeline = Pipeline<int>(
        () => throw Exception('error'),
      ).recoverWith((e, st) => Pipeline(() => 42));

      expect(pipeline.run(), equals(42));
    });

    test('flatMap and zip', () {
      final p1 = Pipeline(() => 5);
      final p2 = Pipeline(() => 10);

      final zipped = p1.zip(p2, (a, b) => a + b);
      expect(zipped.run(), equals(15));
    });

    test('finalize is executed', () {
      var finalized = false;
      final pipeline = Pipeline(() => 5).finalize(() => finalized = true);

      expect(pipeline.run(), equals(5));
      expect(finalized, isTrue);
    });

    test('mapError translates exceptions', () {
      final pipeline = Pipeline<int>(
        () => throw Exception('original'),
      ).mapError((e, st) => ArgumentError('mapped'));

      expect(() => pipeline.run(), throwsA(isA<ArgumentError>()));
    });
  });

  group('AsyncPipeline', () {
    test('async pipeline successfully processes', () async {
      final pipeline = AsyncPipeline(
        () => Future.value(5),
      ).pipe((x) async => x * 2).tap((x) {}).pipe((x) => 'value: $x');

      expect(await pipeline.run(), equals('value: 10'));
    });

    test('recover handles exceptions', () async {
      final pipeline = AsyncPipeline<int>(
        () => throw Exception('error'),
      ).recover((e, st) => 42);

      expect(await pipeline.run(), equals(42));
    });

    test('zip processes concurrently', () async {
      final p1 = AsyncPipeline(() => Future.value(5));
      final p2 = AsyncPipeline(() => Future.value(10));

      final zipped = p1.zip(p2, (a, b) => a + b);
      expect(await zipped.run(), equals(15));
    });

    test('finalize is executed', () async {
      var finalized = false;
      final pipeline = AsyncPipeline(
        () => 5,
      ).finalize(() async => finalized = true);

      expect(await pipeline.run(), equals(5));
      expect(finalized, isTrue);
    });
  });
}
