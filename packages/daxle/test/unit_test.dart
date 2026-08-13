import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Unit', () {
    test('Unit is a singleton and has correct equality/hashCode', () {
      expect(unit, isA<Unit>());
      expect(unit.toString(), equals('()'));
      expect(unit, equals(unit));
      expect(unit.hashCode, equals(unit.hashCode));
    });
  });
}
