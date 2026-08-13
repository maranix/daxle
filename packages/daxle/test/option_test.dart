import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Option', () {
    test('Some contains value and reports correct flags', () {
      final opt = Option.some(42);
      expect(opt.isSome, isTrue);
      expect(opt.isNone, isFalse);
      expect(opt.getOrElse(0), equals(42));
      expect(opt.toNullable(), equals(42));
    });

    test('None is empty and reports correct flags', () {
      final opt = const Option.none();
      expect(opt.isSome, isFalse);
      expect(opt.isNone, isTrue);
      expect(opt.getOrElse(0), equals(0));
      expect(opt.toNullable(), isNull);
    });

    test('Option(value) smart constructor maps null to None and non-null to Some', () {
      expect(Option<int>(null).isNone, isTrue);
      expect(Option(42).isSome, isTrue);
      expect(Option(42).getOrElse(0), equals(42));
    });

    test('map transforms Some and converts null returns to None', () {
      final some = Option.some(10).map((v) => v * 2);
      final none = const Option<int>.none().map((v) => v * 2);
      final nullMapped = Option.some('invalid').map((s) => int.tryParse(s));

      expect(some.getOrElse(0), equals(20));
      expect(none.isNone, isTrue);
      expect(nullMapped.isNone, isTrue);
    });

    test('flatMap chains computations', () {
      final some = Option.some(10).flatMap((v) => Option.some(v * 2));
      final none = Option.some(10).flatMap((v) => const Option<int>.none());

      expect(some.getOrElse(0), equals(20));
      expect(none.isNone, isTrue);
    });

    test('fold projects value correctly', () {
      final some = Option.some(42);
      final none = const Option<int>.none();

      expect(some.fold(() => 'none', (v) => 'some: $v'), equals('some: 42'));
      expect(none.fold(() => 'none', (v) => 'some: $v'), equals('none'));
    });

    test('Option.fromPredicate and filter', () {
      final opt1 = Option.fromPredicate(10, (v) => v > 5);
      final opt2 = Option.fromPredicate(3, (v) => v > 5);

      expect(opt1, equals(Option.some(10)));
      expect(opt2.isNone, isTrue);

      final filtered1 = Option.some(10).filter((v) => v > 5);
      final filtered2 = Option.some(3).filter((v) => v > 5);

      expect(filtered1, equals(Option.some(10)));
      expect(filtered2.isNone, isTrue);
    });

    test('get() retrieves value on Some and throws StateError on None', () {
      expect(Option.some(42).get(), equals(42));
      expect(() => const Option<int>.none().get(), throwsStateError);
    });

    test('Equality and hashCode', () {
      expect(Option.some(42), equals(Option.some(42)));
      expect(Option.some(42), isNot(equals(Option.some(43))));
      expect(const Option<int>.none(), equals(const Option<int>.none()));
      expect(Option.some(42).hashCode, equals(42.hashCode));
      expect(const Option<int>.none().hashCode, equals(0));
    });

    test('toString representation', () {
      expect(Option.some(42).toString(), equals('Some(42)'));
      expect(const Option<int>.none().toString(), equals('None'));
    });

    test('Pattern matching with Dart switch expressions', () {
      String describe(Option<int> opt) => switch (opt) {
            Some(value: final v) => 'Value: $v',
            None() => 'No value',
          };

      expect(describe(Option.some(42)), equals('Value: 42'));
      expect(describe(const Option<int>.none()), equals('No value'));
    });

    test('Chained map handles null returns mid-stream', () {
      final res = Option.some('invalid')
          .map((s) => int.tryParse(s)) // returns None
          .map((i) => i * 2); // remains None

      expect(res.isNone, isTrue);
    });
  });
}
