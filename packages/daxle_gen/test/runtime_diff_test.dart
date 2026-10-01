import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

import 'models_fixture.dart';

void main() {
  group('Model Delta Diffing (.diff() & DiffGenerator)', () {
    final now = DateTime.utc(2026, 1, 1, 12, 0, 0);
    final baseModel = ComplexModel(
      'model-01',
      42,
      4.5,
      true,
      now,
      Uri.parse('https://example.com'),
      BigInt.from(1000),
      const Duration(seconds: 30),
      'v1',
      const QueryMap({'env': 'prod'}),
      ['alpha', 'beta'],
      {1, 2, 3},
      {'cpu': 80, 'mem': 60},
      Status.active,
      Priority.high,
      role: 'admin',
      customEpoch: now,
    );

    test('identical instances yield empty map', () {
      final delta = baseModel.diff(baseModel);
      expect(delta, isEmpty);
    });

    test('equal instances with identical values yield empty map', () {
      final clone = ComplexModel(
        'model-01',
        42,
        4.5,
        true,
        now,
        Uri.parse('https://example.com'),
        BigInt.from(1000),
        const Duration(seconds: 30),
        'v1',
        const QueryMap({'env': 'prod'}),
        ['alpha', 'beta'],
        {1, 2, 3},
        {'cpu': 80, 'mem': 60},
        Status.active,
        Priority.high,
        role: 'admin',
        customEpoch: now,
      );

      expect(baseModel.diff(clone), isEmpty);
    });

    test('primitive scalar changes emit new serialized values', () {
      final updated = baseModel.copyWith(
        count: 99,
        rating: 5.0,
        isActive: false,
        role: 'superadmin',
      );

      final delta = baseModel.diff(updated);
      expect(delta, equals({
        'count': 99,
        'rating': 5.0,
        'isActive': false,
        'role': 'superadmin',
      }));
    });

    test('explicit null transitions: non-null -> null and null -> non-null', () {
      final withNullTag = baseModel.copyWithNull(optionalTag: true);
      final deltaToNull = baseModel.diff(withNullTag);
      expect(deltaToNull, equals({'optionalTag': null}));

      final deltaFromNull = withNullTag.diff(baseModel);
      expect(deltaFromNull, equals({'optionalTag': 'v1'}));
    });

    test('custom converters normalize correctly in delta map', () {
      final newDate = DateTime.utc(2026, 6, 1, 0, 0, 0);
      final updated = baseModel.copyWith(customEpoch: newDate);

      final delta = baseModel.diff(updated);
      expect(delta['customEpoch'], equals(newDate.millisecondsSinceEpoch));
    });

    test('deep collection equality prevents false positives', () {
      final sameCollections = baseModel.copyWith(
        tags: ['alpha', 'beta'],
        numbers: {1, 2, 3},
        scores: {'cpu': 80, 'mem': 60},
      );

      expect(baseModel.diff(sameCollections), isEmpty);
    });

    test('collection mutations emit updated serialized collections', () {
      final mutatedCollections = baseModel.copyWith(
        tags: ['alpha', 'gamma'],
        numbers: {1, 2, 4},
        scores: {'cpu': 95, 'mem': 60},
      );

      final delta = baseModel.diff(mutatedCollections);
      expect(delta, equals({
        'tags': ['alpha', 'gamma'],
        'numbers': [1, 2, 4],
        'scores': {'cpu': 95, 'mem': 60},
      }));
    });

    group('nested models', () {
      final nestedA = NestedContainer(
        containerId: 'nested-01',
        model: baseModel,
        optionalModel: null,
      );

      test('nested model with deep: true emits minimal recursive delta', () {
        final updatedBase = baseModel.copyWith(count: 100);
        final nestedB = NestedContainer(
          containerId: 'nested-01',
          model: updatedBase,
          optionalModel: null,
        );

        final delta = nestedA.diff(nestedB, deep: true);
        expect(delta, equals({
          'model': {'count': 100},
        }));
      });

      test('nested model with deep: false replaces entire child model', () {
        final updatedBase = baseModel.copyWith(count: 100);
        final nestedB = NestedContainer(
          containerId: 'nested-01',
          model: updatedBase,
          optionalModel: null,
        );

        final delta = nestedA.diff(nestedB, deep: false);
        expect(delta.containsKey('model'), isTrue);
        expect(delta['model'], isA<Map<String, dynamic>>());
        final childMap = delta['model'] as Map<String, dynamic>;
        expect(childMap['count'], equals(100));
        expect(childMap['id'], equals('model-01'));
      });

      test('nested model null to non-null emits full child toMap', () {
        final nestedWithOptional = NestedContainer(
          containerId: 'nested-01',
          model: baseModel,
          optionalModel: baseModel,
        );

        final delta = nestedA.diff(nestedWithOptional);
        expect(delta.containsKey('optionalModel'), isTrue);
        expect(delta['optionalModel'], equals(baseModel.toMap()));
      });

      test('nested model non-null to null emits null', () {
        final nestedWithOptional = NestedContainer(
          containerId: 'nested-01',
          model: baseModel,
          optionalModel: baseModel,
        );

        final delta = nestedWithOptional.diff(nestedA);
        expect(delta, equals({'optionalModel': null}));
      });
    });

    group('sealed class polymorphism diffing', () {
      final circle1 = Circle(10.0) as Shape;
      final circle2 = Circle(25.0) as Shape;
      final square = Square(15.0) as Shape;

      test('same subtype diffs fields', () {
        final delta = circle1.diff(circle2);
        expect(delta, equals({'radius': 25.0}));
      });

      test('identical subtype returns empty map', () {
        expect(circle1.diff(circle1), isEmpty);
      });

      test('different subtype returns full new instance toMap', () {
        final delta = circle1.diff(square);
        expect(delta, equals(square.toMap()));
      });
    });
  });
}
