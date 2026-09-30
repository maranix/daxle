import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Redact annotation', () {
    test('default constructor values', () {
      const annotation = Redact();
      expect(annotation.mask, equals('[REDACTED]'));
      expect(annotation.preserveLength, isFalse);
    });

    test('custom constructor values', () {
      const annotation = Redact(mask: '***', preserveLength: true);
      expect(annotation.mask, equals('***'));
      expect(annotation.preserveLength, isTrue);
    });

    test('global redact constant matches default Redact', () {
      expect(redact.mask, equals('[REDACTED]'));
      expect(redact.preserveLength, isFalse);
    });
  });
}
