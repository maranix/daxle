import 'package:daxle_gen/daxle_gen.dart';
import 'package:daxle_gen/src/parser/generation_error.dart';
import 'package:test/test.dart';

void main() {
  const parser = DaxleAstParser();

  test('parses primary constructor class', () {
    const code = '''
import 'package:daxle/daxle.dart';

@serialize
@deserialize
class User(
  @SerializedValue('user_id')
  final String id,
  final String name,
  final Option<String> nickname, {
  final int age = 18,
});
''';

    final parsedFile = parser.parseContent(code);
    expect(parsedFile.classes.length, 1);
    final user = parsedFile.classes.first;
    expect(user.name, 'User');
    expect(user.isPrimaryConstructor, true);
    expect(user.shouldSerialize, true);
    expect(user.shouldDeserialize, true);

    expect(user.fields.length, 4);
    expect(user.fields[0].name, 'id');
    expect(user.fields[0].jsonKey, 'user_id');
    expect(user.fields[0].type.isString, true);

    expect(user.fields[1].name, 'name');
    expect(user.fields[1].jsonKey, 'name');

    expect(user.fields[2].name, 'nickname');
    expect(user.fields[2].type.isOption, true);
    expect(user.fields[2].type.singleTypeArgument?.isString, true);

    expect(user.fields[3].name, 'age');
    expect(user.fields[3].hasDefaultValue, true);
    expect(user.fields[3].defaultValueCode, '18');
  });

  test('parses legacy class with constructors and field annotations', () {
    const code = '''
import 'package:daxle/daxle.dart';

@serialize
@deserialize
class LegacyItem {
  @SerializedValue('item_id')
  final String id;

  @Fallback('unnamed')
  final String name;

  final DateTime createdAt;

  const LegacyItem({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
''';

    final parsedFile = parser.parseContent(code);
    expect(parsedFile.classes.length, 1);
    final item = parsedFile.classes.first;
    expect(item.name, 'LegacyItem');
    expect(item.isPrimaryConstructor, false);
    expect(item.fields.length, 3);
    expect(item.fields[0].name, 'id');
    expect(item.fields[0].jsonKey, 'item_id');
    expect(item.fields[1].name, 'name');
    expect(item.fields[1].config.fallbackCode, "'unnamed'");
    expect(item.fields[2].name, 'createdAt');
    expect(item.fields[2].type.isDateTime, true);
  });

  test('parses enum and enhanced enum', () {
    const code = '''
import 'package:daxle/daxle.dart';

@serializeEnum
@deserializeEnum
enum SimpleStatus { pending, active, completed }

@SerializeEnum(valueField: 'code')
@DeserializeEnum(valueField: 'code')
enum const Priority(final int code) {
  low(10),
  medium(20),
  high(30);
}
''';

    final parsedFile = parser.parseContent(code);
    expect(parsedFile.enums.length, 2);

    final status = parsedFile.enums[0];
    expect(status.name, 'SimpleStatus');
    expect(status.constants.map((c) => c.name).toList(), [
      'pending',
      'active',
      'completed',
    ]);
    expect(status.valueFieldName, isNull);

    final priority = parsedFile.enums[1];
    expect(priority.name, 'Priority');
    expect(priority.valueFieldName, 'code');
    expect(priority.constants[0].explicitValueCode, '10');
    expect(priority.constants[1].explicitValueCode, '20');
    expect(priority.constants[2].explicitValueCode, '30');
  });

  test('parses sealed class hierarchy', () {
    const code = '''
import 'package:daxle/daxle.dart';

@Serialize(discriminator: 'shape_type')
@Deserialize(discriminator: 'shape_type')
sealed class Shape {}

class Circle extends Shape {
  final double radius;
  Circle(this.radius);
}

class Square extends Shape {
  final double side;
  Square(this.side);
}
''';

    final parsedFile = parser.parseContent(code);
    expect(parsedFile.classes.length, 3);

    final shape = parsedFile.classes.first;
    expect(shape.name, 'Shape');
    expect(shape.isSealed, true);
    expect(shape.serialize?.discriminator, 'shape_type');
    expect(shape.deserialize?.discriminator, 'shape_type');

    final circle = parsedFile.classes[1];
    expect(circle.name, 'Circle');
    expect(circle.superclass, 'Shape');
  });

  test('parses sealed class hierarchy with implements and custom discriminator tag', () {
    const code = '''
import 'package:daxle/daxle.dart';

part 'vehicle.daxle.dart';

@Serialize(discriminator: 'v_type')
sealed class Vehicle {}

@SerializedValue('custom_car')
class Car implements Vehicle {
  final int wheels;
  Car(this.wheels);
}
''';

    final parsedFile = parser.parseContent(code);
    expect(parsedFile.partDirectives, ['vehicle.daxle.dart']);
    expect(parsedFile.hasDaxlePartDirective, true);

    final car = parsedFile.classes[1];
    expect(car.name, 'Car');
    expect(car.interfaces, contains('Vehicle'));
    expect(car.isSubclassOf('Vehicle'), true);
    expect(car.customDiscriminatorName, 'custom_car');
  });

  test('parses enhanced enum matching positional constructor parameter for valueField', () {
    const code = '''
import 'package:daxle/daxle.dart';

@SerializeEnum(valueField: 'code')
enum const MultiParam(final String label, final int code) {
  first('first_label', 101),
  second('second_label', 202);
}
''';

    final parsedFile = parser.parseContent(code);
    final enumEl = parsedFile.enums.first;
    expect(enumEl.constants[0].explicitValueCode, '101');
    expect(enumEl.constants[1].explicitValueCode, '202');
  });

  test('parses CaseStyle and ignoreFields on class and enum', () {
    const code = '''
import 'package:daxle/daxle.dart';

@Serialize(caseStyle: CaseStyle.snakeCase, ignoreFields: ['secretToken'])
@Deserialize(caseStyle: CaseStyle.snakeCase, ignoreFields: {'secretToken'})
class Account(
  final String accountId,
  final String secretToken,
);

@SerializeEnum(caseStyle: CaseStyle.kebabCase)
enum ItemCategory { bookItem, electronicDevice }
''';

    final parsedFile = parser.parseContent(code);
    final account = parsedFile.classes.first;
    expect(account.serialize?.caseStyle, CaseStyle.snakeCase);
    expect(account.serialize?.ignoreFields, contains('secretToken'));
    expect(account.deserialize?.ignoreFields, contains('secretToken'));

    expect(
      account.fields[0].resolvedSerializeKey(account.serialize?.caseStyle),
      'account_id',
    );
    expect(account.fields[1].isIgnoredForSerialize(account.serialize), true);

    final category = parsedFile.enums.first;
    expect(category.serialize?.caseStyle, CaseStyle.kebabCase);
    expect(category.constants[0].explicitValueCode, "'book-item'");
    expect(category.constants[1].explicitValueCode, "'electronic-device'");
  });

  test('parses enum constant annotations with SerializedValue, Fallback and ignore', () {
    const code = '''
import 'package:daxle/daxle.dart';

@Fallback(Status.standard)
@serializeEnum
@deserializeEnum
enum Status {
  @SerializedValue('in_progress')
  inProgress,

  @SerializedValue(101)
  codeEntry,

  @ignore
  internalTest,

  standard,
}
''';

    final parsedFile = parser.parseContent(code);
    final status = parsedFile.enums.first;
    expect(status.fallbackCaseCode, 'Status.standard');
    expect(status.constants.length, 4);

    final inProgress = status.constants[0];
    expect(inProgress.config.serializedKey, 'in_progress');
    expect(inProgress.resolvedSerializeValue(null), "'in_progress'");
    expect(inProgress.resolvedDeserializeValue(null), "'in_progress'");

    final codeEntry = status.constants[1];
    expect(codeEntry.config.serializedKey, '101');
    expect(codeEntry.resolvedSerializeValue(null), '101');
    expect(codeEntry.resolvedDeserializeValue(null), '101');

    final internalTest = status.constants[2];
    expect(internalTest.isIgnored, true);

    final standard = status.constants[3];
    expect(standard.resolvedSerializeValue(null), "'standard'");
    expect(standard.resolvedDeserializeValue(null), "'standard'");
  });

  test('throws InvalidGenerationSourceError when @ignore is paired with @SerializedValue', () {
    const code = '''
import 'package:daxle/daxle.dart';

@serialize
class BadModel {
  @ignore
  @SerializedValue('bad')
  final String badField;

  BadModel(this.badField);
}
''';

    expect(
      () => parser.parseContent(code),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });

  test(
    'throws InvalidGenerationSourceError when @ignore is paired with @Fallback',
    () {
      const code = '''
import 'package:daxle/daxle.dart';

@serialize
class BadModel {
  @ignore
  @Fallback('bad')
  final String badField;

  BadModel(this.badField);
}
''';

      expect(
        () => parser.parseContent(code),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    },
  );

  test('parses aliases on enum cases and class fields', () {
    const code = '''
import 'package:daxle/daxle.dart';

@serializeEnum
enum Status {
  @SerializedValue('pay_pending', aliases: ['pending', 'in_progress'])
  pending,
}

@serialize
class Order {
  @SerializedValue('order_status', aliases: ['status', 'state'])
  final Status status;

  Order(this.status);
}
''';

    final parsedFile = parser.parseContent(code);
    final statusEnum = parsedFile.enums.first;
    expect(statusEnum.constants.first.aliases, ['pending', 'in_progress']);

    final orderClass = parsedFile.classes.first;
    expect(orderClass.fields.first.aliases, ['status', 'state']);
  });

  test('parses @Flatten and @flatten with prefix', () {
    const code = '''
import 'package:daxle/daxle.dart';

class Address {
  final String street;
  Address(this.street);
}

@serialize
class Order {
  @Flatten(prefix: 'shipping_')
  final Address shippingAddress;

  @flatten
  final Address billingAddress;

  Order(this.shippingAddress, this.billingAddress);
}
''';

    final parsedFile = parser.parseContent(code);
    final orderClass = parsedFile.classes.firstWhere((c) => c.name == 'Order');
    expect(orderClass.fields[0].isFlattened, true);
    expect(orderClass.fields[0].flattenPrefix, 'shipping_');
    expect(orderClass.fields[1].isFlattened, true);
    expect(orderClass.fields[1].flattenPrefix, '');
  });

  test('throws InvalidGenerationSourceError on duplicate wire key or alias in enum', () {
    const code = '''
import 'package:daxle/daxle.dart';

@serializeEnum
enum ConflictEnum {
  @SerializedValue('same_val', aliases: ['alias1'])
  first,

  @SerializedValue('other_val', aliases: ['alias1'])
  second,
}
''';

    expect(
      () => parser.parseContent(code),
      throwsA(
        isA<InvalidGenerationSourceError>().having(
          (e) => e.message,
          'message',
          contains('Duplicate wire key or alias "alias1"'),
        ),
      ),
    );
  });

  test('throws InvalidGenerationSourceError on duplicate wire key or alias in class', () {
    const code = '''
import 'package:daxle/daxle.dart';

@serialize
class ConflictClass {
  @SerializedValue('shared_key')
  final String a;

  @SerializedValue('b_val', aliases: ['shared_key'])
  final String b;

  ConflictClass(this.a, this.b);
}
''';

    expect(
      () => parser.parseContent(code),
      throwsA(
        isA<InvalidGenerationSourceError>().having(
          (e) => e.message,
          'message',
          contains('Duplicate wire key or alias "shared_key"'),
        ),
      ),
    );
  });

  test('throws InvalidGenerationSourceError when @Flatten is used on primitive or collection types', () {
    const primitiveCode = '''
import 'package:daxle/daxle.dart';

@serialize
class BadPrimitive {
  @Flatten()
  final int count;

  BadPrimitive(this.count);
}
''';

    expect(
      () => parser.parseContent(primitiveCode),
      throwsA(
        isA<InvalidGenerationSourceError>().having(
          (e) => e.message,
          'message',
          contains('@Flatten cannot be used on field "count" of type "int"'),
        ),
      ),
    );

    const collectionCode = '''
import 'package:daxle/daxle.dart';

@serialize
class BadCollection {
  @flatten
  final List<String> items;

  BadCollection(this.items);
}
''';

    expect(
      () => parser.parseContent(collectionCode),
      throwsA(
        isA<InvalidGenerationSourceError>().having(
          (e) => e.message,
          'message',
          contains(
            '@Flatten cannot be used on field "items" of type "List<String>"',
          ),
        ),
      ),
    );
  });

  test(
    'throws InvalidGenerationSourceError when @ignore is paired with @Flatten',
    () {
      const code = '''
import 'package:daxle/daxle.dart';

class Address {
  final String street;
  Address(this.street);
}

@serialize
class BadModel {
  @ignore
  @Flatten(prefix: 'addr_')
  final Address address;

  BadModel(this.address);
}
''';

      expect(
        () => parser.parseContent(code),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    },
  );

  test('throws InvalidGenerationSourceError when @Flatten is paired with @SerializedValue', () {
    const code = '''
import 'package:daxle/daxle.dart';

class Address {
  final String street;
  Address(this.street);
}

@serialize
class BadModel {
  @SerializedValue('addr')
  @Flatten(prefix: 'addr_')
  final Address address;

  BadModel(this.address);
}
''';

    expect(
      () => parser.parseContent(code),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });

  test(
    'throws InvalidGenerationSourceError when class has member annotations but no root annotation',
    () {
      const code = '''
import 'package:daxle/daxle.dart';

class UnannotatedClass {
  @SerializedValue('my_field')
  final String myField;

  UnannotatedClass(this.myField);
}
''';

      expect(
        () => parser.parseContent(code),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('is not marked with any root annotation'),
          ),
        ),
      );
    },
  );

  test(
    'throws InvalidGenerationSourceError when enum has case annotations but no root annotation',
    () {
      const code = '''
import 'package:daxle/daxle.dart';

enum UnannotatedEnum {
  @SerializedValue('first_case')
  first,
  second,
}
''';

      expect(
        () => parser.parseContent(code),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('is not marked with any root annotation'),
          ),
        ),
      );
    },
  );
}
