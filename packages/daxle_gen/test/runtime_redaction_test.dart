import 'package:test/test.dart';

import 'models_fixture.dart';

void main() {
  group('Sensitive Field Redaction (@redact / Redact)', () {
    final secretProfile = SecretProfile(
      'alice_wonderland',
      'super-secret-token-123',
      'mySecretPassword',
      '1234',
      'secret-data',
      ['4111-2222-3333-4444', '5555-6666-7777-8888'],
      {'REC-01', 'REC-02'},
      {'jwt': 'eyJhbGciOi...'},
    );

    final secretProfileWithNulls = SecretProfile(
      'bob_builder',
      'token-xyz',
      'short',
      null,
      null,
      [],
      {},
      {},
    );

    test('toString() masks sensitive fields and preserves nulls', () {
      final str = secretProfile.toString();
      expect(str, contains('publicUsername: alice_wonderland'));
      expect(str, contains('secretToken: [REDACTED]'));
      expect(str, contains('rawPassword: ****************')); // 16 asterisks
      expect(str, contains('optionalPin: [REDACTED]'));
      expect(
        str,
        contains('nullablePreserved: [[[[[[[[[[['),
      ); // 11 '[' from length 11
      expect(str, contains('creditCards: [REDACTED]'));
      expect(str, contains('recoveryCodes: [REDACTED]'));
      expect(str, contains('tokens: [REDACTED]'));

      // Invariant: raw secrets should not be leaked in toString
      expect(str, isNot(contains('super-secret-token-123')));
      expect(str, isNot(contains('mySecretPassword')));
      expect(str, isNot(contains('4111-2222-3333-4444')));
    });

    test('toString() preserves null values for nullable redacted fields', () {
      final str = secretProfileWithNulls.toString();
      expect(str, contains('publicUsername: bob_builder'));
      expect(str, contains('secretToken: [REDACTED]'));
      expect(str, contains('rawPassword: *****')); // 5 asterisks
      expect(str, contains('optionalPin: null'));
      expect(str, contains('nullablePreserved: null'));
    });

    test('toDebugMap() masks sensitive values while keeping unredacted fields intact', () {
      final debugMap = secretProfile.toDebugMap();

      expect(debugMap['publicUsername'], equals('alice_wonderland'));
      expect(debugMap['secretToken'], equals('[REDACTED]'));
      expect(debugMap['rawPassword'], equals('****************'));
      expect(debugMap['optionalPin'], equals('[REDACTED]'));
      expect(debugMap['nullablePreserved'], equals('[[[[[[[[[[['));
      expect(debugMap['creditCards'], equals(['[REDACTED]']));
      expect(debugMap['recoveryCodes'], equals(['[REDACTED]']));
      expect(debugMap['tokens'], equals('[REDACTED]'));
    });

    test('toDebugMap() handles empty collections and null values', () {
      final debugMap = secretProfileWithNulls.toDebugMap();

      expect(debugMap['publicUsername'], equals('bob_builder'));
      expect(debugMap['optionalPin'], isNull);
      expect(debugMap['nullablePreserved'], isNull);
      expect(debugMap['creditCards'], equals([]));
      expect(debugMap['recoveryCodes'], equals([]));
      expect(debugMap['tokens'], equals('[REDACTED]'));
    });

    test('toDebugMap(excludeNull: true) removes null redacted fields', () {
      final sparseDebug = secretProfileWithNulls.toDebugMap(excludeNull: true);
      expect(sparseDebug.containsKey('publicUsername'), isTrue);
      expect(sparseDebug.containsKey('optionalPin'), isFalse);
      expect(sparseDebug.containsKey('nullablePreserved'), isFalse);
    });

    test('deep and wholesale nested redaction in toDebugMap()', () {
      final account = AccountCredentials(
        'ACC-99',
        secretProfile,
        secretProfile,
      );

      final debugMap = account.toDebugMap();
      expect(debugMap['accountId'], equals('ACC-99'));

      // Deep redaction: profile is a map with masked internals
      final nestedProfile = debugMap['profile'] as Map<String, dynamic>;
      expect(nestedProfile['publicUsername'], equals('alice_wonderland'));
      expect(nestedProfile['secretToken'], equals('[REDACTED]'));
      expect(nestedProfile['rawPassword'], equals('****************'));

      // Wholesale redaction: wholesaleRedactedProfile is masked wholesale
      expect(debugMap['wholesaleRedactedProfile'], equals('[REDACTED]'));
    });

    test('Invariant: toMap() remains completely unaltered for wire serialization', () {
      final wireMap = secretProfile.toMap();

      // Original raw values preserved exactly
      expect(wireMap['publicUsername'], equals('alice_wonderland'));
      expect(wireMap['secretToken'], equals('super-secret-token-123'));
      expect(wireMap['rawPassword'], equals('mySecretPassword'));
      expect(wireMap['optionalPin'], equals('1234'));
      expect(wireMap['nullablePreserved'], equals('secret-data'));
      expect(
        wireMap['creditCards'],
        equals(['4111-2222-3333-4444', '5555-6666-7777-8888']),
      );
      expect(wireMap['recoveryCodes'], equals(['REC-01', 'REC-02']));
      expect(wireMap['tokens'], equals({'jwt': 'eyJhbGciOi...'}));

      // Round-trip deserialization from toMap() restores original values
      final restored = secretProfileFromMap(wireMap);
      expect(restored, equals(secretProfile));
    });
  });
}
