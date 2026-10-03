import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

import 'models_fixture.dart';

void main() {
  group('EqualsAndHashCode generator', () {
    test(
      'equals and hashCode on ComplexModel with all fields and collections',
      () {
        final now = DateTime.now();
        final uri = Uri.parse('https://example.com');
        final duration = const Duration(seconds: 5);
        final score = BigInt.from(1234567890);

        final model1 = ComplexModel(
          'm1',
          10,
          4.5,
          true,
          now,
          uri,
          score,
          duration,
          'tag1',
          QueryMap({'k': 'v'}),
          ['a', 'b', 'c'],
          {1, 2, 3},
          {'x': 100, 'y': 200},
          Status.active,
          Priority.high,
          role: 'admin',
          secretToken: 'secret',
          customEpoch: now,
        );

        final model2 = ComplexModel(
          'm1',
          10,
          4.5,
          true,
          now,
          uri,
          score,
          duration,
          'tag1',
          QueryMap({'k': 'v'}),
          ['a', 'b', 'c'],
          {1, 2, 3},
          {'x': 100, 'y': 200},
          Status.active,
          Priority.high,
          role: 'admin',
          secretToken: 'secret',
          customEpoch: now,
        );

        final modelDifferent = ComplexModel(
          'm2',
          10,
          4.5,
          true,
          now,
          uri,
          score,
          duration,
          'tag1',
          QueryMap({'k': 'v'}),
          ['a', 'b', 'c'],
          {1, 2, 3},
          {'x': 100, 'y': 200},
          Status.active,
          Priority.high,
          role: 'admin',
          customEpoch: now,
        );

        // Reflexive
        expect(model1 == model1, isTrue);
        // Symmetric & equal
        expect(model1 == model2, isTrue);
        expect(model2 == model1, isTrue);
        expect(model1.hashCode, equals(model2.hashCode));

        // Different field
        expect(model1 == modelDifferent, isFalse);
      },
    );

    test('deep collection equality detects differences', () {
      final now = DateTime.now();
      final uri = Uri.parse('https://example.com');
      final duration = const Duration(seconds: 5);
      final score = BigInt.from(100);

      final base = ComplexModel(
        'id1',
        1,
        1.0,
        true,
        now,
        uri,
        score,
        duration,
        null,
        QueryMap({}),
        ['item1'],
        {1},
        {'key': 1},
        Status.pending,
        Priority.low,
      );

      final differentList = ComplexModel(
        'id1',
        1,
        1.0,
        true,
        now,
        uri,
        score,
        duration,
        null,
        QueryMap({}),
        ['item1', 'extra'],
        {1},
        {'key': 1},
        Status.pending,
        Priority.low,
      );

      expect(base == differentList, isFalse);

      final differentSet = ComplexModel(
        'id1',
        1,
        1.0,
        true,
        now,
        uri,
        score,
        duration,
        null,
        QueryMap({}),
        ['item1'],
        {2},
        {'key': 1},
        Status.pending,
        Priority.low,
      );

      expect(base == differentSet, isFalse);

      final differentMap = ComplexModel(
        'id1',
        1,
        1.0,
        true,
        now,
        uri,
        score,
        duration,
        null,
        QueryMap({}),
        ['item1'],
        {1},
        {'key': 2},
        Status.pending,
        Priority.low,
      );

      expect(base == differentMap, isFalse);
    });

    test('single feature model (EqualsOnlyModel)', () {
      final a = EqualsOnlyModel('abc', 42);
      final b = EqualsOnlyModel('abc', 42);
      final c = EqualsOnlyModel('abc', 99);

      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
      expect(a == c, isFalse);
    });

    test(
      'ignored fields on CaseStyledModel are ignored for equality and hashCode',
      () {
        final a = CaseStyledModel('John Doe', 3, internalSecret: 'secret_1');
        final b = CaseStyledModel('John Doe', 3, internalSecret: 'secret_2');
        final c = CaseStyledModel('Jane Doe', 3, internalSecret: 'secret_1');

        expect(a == b, isTrue);
        expect(a.hashCode, equals(b.hashCode));
        expect(a == c, isFalse);
      },
    );

    test(
      'large model with > 20 fields handles nested Object.hash correctly',
      () {
        final m1 = LargeModel(
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
        );

        final m2 = LargeModel(
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
        );

        final mDifferent = LargeModel(
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          999,
        );

        expect(m1 == m2, isTrue);
        expect(m1.hashCode, equals(m2.hashCode));
        expect(m1 == mDifferent, isFalse);
      },
    );
  });

  group('Stringify generator', () {
    test('class toString output', () {
      final single = StringifyOnlyModel('Hello World');
      expect(
        single.toString(),
        equals('StringifyOnlyModel(title: Hello World)'),
      );

      final caseStyled = CaseStyledModel('Alice', 5, internalSecret: 'hidden');
      expect(
        caseStyled.toString(),
        equals('CaseStyledModel(userFullName: Alice, loginAttemptCount: 5)'),
      );
      expect(caseStyled.toString(), isNot(contains('internalSecret')));

      final equalsOnly = EqualsOnlyModel('id1', 123);
      // Not annotated with @stringify, uses default
      expect(equalsOnly.toString(), contains('EqualsOnlyModel'));
    });

    test('enum toString output with @stringify', () {
      expect(Status.pending.toString(), equals('Status.pending'));
      expect(Status.active.toString(), equals('Status.active'));
      expect(Status.completed.toString(), equals('Status.completed'));
    });
  });

  group('CopyWith generator', () {
    test('standard copyWith updates single and multiple fields', () {
      final original = ComplexModel(
        'id1',
        10,
        3.5,
        false,
        DateTime(2025, 1, 1),
        Uri.parse('https://example.com'),
        BigInt.from(50),
        const Duration(seconds: 1),
        null,
        QueryMap({}),
        ['dart'],
        {1},
        {'a': 1},
        Status.pending,
        Priority.low,
        role: 'user',
        customEpoch: DateTime(2025, 1, 1),
      );

      final modified = original.copyWith(
        count: 20,
        role: 'superadmin',
        isActive: true,
      );

      expect(modified.id, equals('id1'));
      expect(modified.count, equals(20));
      expect(modified.role, equals('superadmin'));
      expect(modified.isActive, isTrue);
      expect(modified.rating, equals(3.5));
    });

    test('copyWith returns identical instance when no values are modified (instance reuse)', () {
      final original = ComplexModel(
        'id1',
        10,
        3.5,
        false,
        DateTime(2025, 1, 1),
        Uri.parse('https://example.com'),
        BigInt.from(50),
        const Duration(seconds: 1),
        null,
        QueryMap({}),
        ['dart'],
        {1},
        {'a': 1},
        Status.pending,
        Priority.low,
      );

      // Calling copyWith with null/omitted arguments returns `this`
      final copy = original.copyWith();
      expect(identical(copy, original), isTrue);

      // Calling copyWith with identical field values returns `this`
      final copyIdentical = original.copyWith(
        id: original.id,
        count: original.count,
        isActive: original.isActive,
      );
      expect(identical(copyIdentical, original), isTrue);
    });

    test('copyWithNull sets nullable fields to null', () {
      final original = ComplexModel(
        'id1',
        10,
        3.5,
        false,
        DateTime(2025, 1, 1),
        Uri.parse('https://example.com'),
        BigInt.from(50),
        const Duration(seconds: 1),
        null,
        QueryMap({}),
        ['dart'],
        {1},
        {'a': 1},
        Status.pending,
        Priority.low,
        customEpoch: DateTime(2025, 1, 1),
      );

      expect(original.customEpoch, isNotNull);

      // Explicitly nullify customEpoch
      final nullified = original.copyWithNull(customEpoch: true);
      expect(nullified.customEpoch, isNull);
      expect(nullified.id, equals('id1'));
      expect(nullified.count, equals(10));

      // Calling with false returns `this`
      final notNullified = original.copyWithNull(customEpoch: false);
      expect(identical(notNullified, original), isTrue);
    });
  });
}
