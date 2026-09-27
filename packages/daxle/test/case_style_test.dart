import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('CaseStyle', () {
    test('transforms correctly across all styles', () {
      const input = 'userIdentifier';

      expect(CaseStyle.none.transform(input), 'userIdentifier');
      expect(CaseStyle.snakeCase.transform(input), 'user_identifier');
      expect(CaseStyle.kebabCase.transform(input), 'user-identifier');
      expect(CaseStyle.pascalCase.transform(input), 'UserIdentifier');
      expect(CaseStyle.screamingSnakeCase.transform(input), 'USER_IDENTIFIER');
      expect(CaseStyle.lowerCase.transform(input), 'useridentifier');
      expect(CaseStyle.upperCase.transform(input), 'USERIDENTIFIER');
      expect(CaseStyle.camelCase.transform(input), 'userIdentifier');
    });

    test('handles snake_case and kebab-case inputs', () {
      expect(CaseStyle.camelCase.transform('created_at_time'), 'createdAtTime');
      expect(CaseStyle.pascalCase.transform('created_at_time'), 'CreatedAtTime');
      expect(CaseStyle.kebabCase.transform('created_at_time'), 'created-at-time');
      expect(CaseStyle.screamingSnakeCase.transform('status-code'), 'STATUS_CODE');
    });

    test('handles empty input and none style', () {
      expect(CaseStyle.snakeCase.transform(''), '');
      expect(CaseStyle.none.transform('anything'), 'anything');
    });
  });
}
