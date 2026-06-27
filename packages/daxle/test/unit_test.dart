import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Unit', () {
    test('Unit is a singleton', () {
      expect(unit, isA<Unit>());
      expect(unit.toString(), equals('()'));
    });
  });
}
