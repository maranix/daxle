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

    test('Option.fromNullable maps null to None and non-null to Some', () {
      expect(Option.fromNullable(null).isNone, isTrue);
      expect(Option.fromNullable(42).isSome, isTrue);
      expect(Option.fromNullable(42).getOrElse(0), equals(42));
    });

    test('Some throws ArgumentError if initialized with null', () {
      expect(() => Option.some(null as dynamic), throwsArgumentError);
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
  });
}
