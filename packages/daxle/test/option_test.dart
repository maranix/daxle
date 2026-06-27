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
      final opt = Option.none();
      expect(opt.isSome, isFalse);
      expect(opt.isNone, isTrue);
      expect(opt.getOrElse(0), equals(0));
      expect(opt.toNullable(), isNull);
    });

    test('Option.of maps null to None and non-null to Some', () {
      expect(Option.of(null).isNone, isTrue);
      expect(Option.of(42).isSome, isTrue);
      expect(Option.of(42).getOrElse(0), equals(42));
    });

    test('map transforms Some and leaves None unchanged', () {
      final some = Option.some(10).map((v) => v * 2);
      final none = Option<int>.none().map((v) => v * 2);

      expect(some.getOrElse(0), equals(20));
      expect(none.isNone, isTrue);
    });

    test('flatMap chains computations', () {
      final some = Option.some(10).flatMap((v) => Option.some(v * 2));
      final none = Option.some(10).flatMap((v) => Option<int>.none());

      expect(some.getOrElse(0), equals(20));
      expect(none.isNone, isTrue);
    });

    test('fold projects value correctly', () {
      final some = Option.some(42);
      final none = Option<int>.none();

      expect(some.fold(() => 'none', (v) => 'some: $v'), equals('some: 42'));
      expect(none.fold(() => 'none', (v) => 'some: $v'), equals('none'));
    });

    test('equality checks', () {
      expect(Option.some(42), equals(Option.some(42)));
      expect(Option.some(42), isNot(equals(Option.some(43))));
      expect(Option.none(), equals(Option.none()));
      expect(Option.some(42), isNot(equals(Option.none())));
    });
  });
}
