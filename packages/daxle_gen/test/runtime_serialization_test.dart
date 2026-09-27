import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

import 'models_fixture.dart';

void main() {
  group('Enum mapping and conversion', () {
    test('standard enum', () {
      expect(statusToValue(Status.pending), 'pending');
      expect(statusToValue(Status.active), 'active');
      expect(statusToValue(Status.completed), 'completed');

      expect(statusFromValue('pending'), Status.pending);
      expect(statusFromValue('active'), Status.active);
      expect(statusFromValue('completed'), Status.completed);

      expect(() => statusFromValue('invalid'), throwsArgumentError);
    });

    test('enhanced enum with valueField', () {
      expect(priorityToValue(Priority.low), 10);
      expect(priorityToValue(Priority.medium), 20);
      expect(priorityToValue(Priority.high), 30);

      expect(priorityFromValue(10), Priority.low);
      expect(priorityFromValue(20), Priority.medium);
      expect(priorityFromValue(30), Priority.high);

      expect(() => priorityFromValue(999), throwsArgumentError);
    });
  });

  group('Primary constructor model (ComplexModel)', () {
    test('round-trip serialization with all types', () {
      final now = DateTime.utc(2026, 9, 26, 12, 0, 0);
      final model = ComplexModel(
        'mod-123',
        42,
        9.85,
        true,
        now,
        Uri.parse('https://daxle.dev'),
        BigInt.from(987654321),
        const Duration(milliseconds: 500),
        const Some('nickname-val'),
        const QueryMap({'env': 'prod', 'version': 4}),
        ['dart', 'daxle'],
        {1, 2, 3},
        {'math': 100, 'cs': 95},
        Status.active,
        Priority.high,
        role: 'admin',
        secretToken: 'shh-secret',
        customEpoch: DateTime.fromMillisecondsSinceEpoch(1600000000000),
      );

      final map = complexModelToMap(model);

      expect(map['id'], 'mod-123');
      expect(map['count'], 42);
      expect(map['rating'], 9.85);
      expect(map['isActive'], true);
      expect(map['createdAt'], now.toIso8601String());
      expect(map['website'], 'https://daxle.dev');
      expect(map['score'], '987654321');
      expect(map['timeout'], 500000);
      expect(map['optionalTag'], 'nickname-val');
      expect(map['metadata'], {'env': 'prod', 'version': 4});
      expect(map['tags'], ['dart', 'daxle']);
      expect(map['numbers'], [1, 2, 3]);
      expect(map['scores'], {'math': 100, 'cs': 95});
      expect(map['status'], 'active');
      expect(map['priority'], 30);
      expect(map['role'], 'admin');
      // Ignored field must not be serialized
      expect(map.containsKey('secretToken'), false);
      // Custom epoch converter
      expect(map['customEpoch'], 1600000000000);

      // Deserialization round-trip
      final restored = complexModelFromMap(map);

      expect(restored.id, model.id);
      expect(restored.count, model.count);
      expect(restored.rating, model.rating);
      expect(restored.isActive, model.isActive);
      expect(restored.createdAt, model.createdAt);
      expect(restored.website, model.website);
      expect(restored.score, model.score);
      expect(restored.timeout, model.timeout);
      expect(restored.optionalTag, model.optionalTag);
      expect(restored.metadata.get<String>('env'), 'prod');
      expect(restored.metadata.get<int>('version'), 4);
      expect(restored.tags, model.tags);
      expect(restored.numbers, model.numbers);
      expect(restored.scores, model.scores);
      expect(restored.status, model.status);
      expect(restored.priority, model.priority);
      expect(restored.role, 'admin');
      expect(restored.secretToken, ''); // default because ignored
      expect(restored.customEpoch, model.customEpoch);
    });

    test('handles Option.none and default fallbacks', () {
      final now = DateTime.utc(2026, 9, 26);
      final json = <String, dynamic>{
        'id': 'mod-456',
        'count': 1,
        'rating': 3.5,
        'isActive': false,
        'createdAt': now.toIso8601String(),
        'website': 'https://example.com',
        'score': '123',
        'timeout': 1000,
        'optionalTag': null,
        'metadata': <Object?, Object?>{},
        'tags': <dynamic>[],
        'numbers': <dynamic>[],
        'scores': <String, dynamic>{},
        'status': 'pending',
        'priority': 10,
        // 'role' omitted: should fallback to default 'guest'
        'customEpoch': null,
      };

      final restored = complexModelFromMap(json);
      expect(restored.optionalTag, const None<String>());
      expect(restored.role, 'guest');
      expect(restored.customEpoch, isNull);

      final map = complexModelToMap(restored);
      expect(map['optionalTag'], isNull);
      expect(map['role'], 'guest');
      expect(map['customEpoch'], isNull);
      expect(map.containsKey('customEpoch'), true);

      final sparseMap = complexModelToMap(restored, excludeNull: true);
      expect(sparseMap.containsKey('customEpoch'), false);
    });
  });

  group('Nested Models and Containers', () {
    test('explicitly serializes and deserializes nested objects', () {
      final now = DateTime.utc(2026, 1, 1);
      final inner = ComplexModel(
        'inner-1',
        10,
        5.0,
        true,
        now,
        Uri.parse('https://inner.com'),
        BigInt.from(1),
        const Duration(seconds: 1),
        const None(),
        const QueryMap({}),
        [],
        {},
        {},
        Status.completed,
        Priority.low,
      );

      final container = NestedContainer(
        containerId: 'c-1',
        model: inner,
        optionalModel: null,
      );

      final map = nestedContainerToMap(container);
      expect(map['containerId'], 'c-1');
      expect(map['model'], isA<Map<String, dynamic>>());
      expect(map['model']['id'], 'inner-1');
      expect(map['optionalModel'], isNull);
      expect(map.containsKey('optionalModel'), true);

      final sparseMap = nestedContainerToMap(container, excludeNull: true);
      expect(sparseMap.containsKey('optionalModel'), false);

      final restored = nestedContainerFromMap(map);
      expect(restored.containerId, 'c-1');
      expect(restored.model.id, 'inner-1');
      expect(restored.optionalModel, isNull);
    });

    test('serializes present optional nested model', () {
      final now = DateTime.utc(2026, 1, 1);
      final inner = ComplexModel(
        'inner-1',
        10,
        5.0,
        true,
        now,
        Uri.parse('https://inner.com'),
        BigInt.from(1),
        const Duration(seconds: 1),
        const None(),
        const QueryMap({}),
        [],
        {},
        {},
        Status.completed,
        Priority.low,
      );

      final container = NestedContainer(
        containerId: 'c-2',
        model: inner,
        optionalModel: inner,
      );

      final map = nestedContainerToMap(container);
      expect(map['optionalModel'], isA<Map<String, dynamic>>());
      expect(map['optionalModel']['id'], 'inner-1');

      final restored = nestedContainerFromMap(map);
      expect(restored.optionalModel, isNotNull);
      expect(restored.optionalModel!.id, 'inner-1');
    });
  });

  group('Sealed Class Polymorphism', () {
    test('serializes and deserializes Circle', () {
      final Shape circle = Circle(4.5);
      final map = shapeToMap(circle);

      expect(map['shape_type'], 'Circle');
      expect(map['radius'], 4.5);

      final restored = shapeFromMap(map);
      expect(restored, isA<Circle>());
      expect((restored as Circle).radius, 4.5);
    });

    test('serializes and deserializes Square', () {
      final Shape square = Square(10.0);
      final map = shapeToMap(square);

      expect(map['shape_type'], 'Square');
      expect(map['side'], 10.0);

      final restored = shapeFromMap(map);
      expect(restored, isA<Square>());
      expect((restored as Square).side, 10.0);
    });

    test('throws FormatException on unknown discriminator', () {
      expect(
        () => shapeFromMap({'shape_type': 'Triangle', 'base': 5}),
        throwsFormatException,
      );
    });
  });

  group('Enhanced Enum with positional parameter matching', () {
    test('matches valueField to non-first positional parameter', () {
      expect(multiParamEnumToValue(MultiParamEnum.first), 101);
      expect(multiParamEnumToValue(MultiParamEnum.second), 202);
      expect(multiParamEnumFromValue(101), MultiParamEnum.first);
      expect(multiParamEnumFromValue(202), MultiParamEnum.second);
    });
  });

  group('Sealed Class Polymorphism with implements and custom tags', () {
    test('serializes and deserializes Car with custom discriminator tag', () {
      final Vehicle car = Car(5);
      final map = vehicleToMap(car);
      expect(map['vehicle_type'], 'car_v1');
      expect(map['seats'], 5);

      final restored = vehicleFromMap(map);
      expect(restored, isA<Car>());
      expect((restored as Car).seats, 5);
    });

    test('serializes and deserializes Bike', () {
      final Vehicle bike = Bike(true);
      final map = vehicleToMap(bike);
      expect(map['vehicle_type'], 'Bike');
      expect(map['hasPedals'], true);

      final restored = vehicleFromMap(map);
      expect(restored, isA<Bike>());
      expect((restored as Bike).hasPedals, true);
    });
  });

  group('Custom JSON wire key mapping (@SerializedValue)', () {
    test('uses wire_key bidirectionally for fromJson and toMap', () {
      final model = customKeyModelFromMap({'wire_key': 'secret-token'});
      expect(model.key, 'secret-token');

      final map = customKeyModelToMap(model);
      expect(map['wire_key'], 'secret-token');
      expect(map.containsKey('key'), false);
    });
  });

  group('Nullable Converter Model', () {
    test('handles null without throwing NullThrownError', () {
      final model = NullableConverterModel(null);
      final map = nullableConverterModelToMap(model);
      expect(map['nullableConvertedInt'], isNull);
      expect(map.containsKey('nullableConvertedInt'), true);

      final sparseMap = nullableConverterModelToMap(model, excludeNull: true);
      expect(sparseMap.containsKey('nullableConvertedInt'), false);

      final restored = nullableConverterModelFromMap(map);
      expect(restored.nullableConvertedInt, isNull);
    });

    test('round-trips converted non-null values', () {
      final model = NullableConverterModel(42);
      final map = nullableConverterModelToMap(model);
      expect(map['nullableConvertedInt'], '42');

      final restored = nullableConverterModelFromMap(map);
      expect(restored.nullableConvertedInt, 42);
    });
  });

  group('Deep Collections Model', () {
    test('round-trips nested matrix and map of lists', () {
      final model = DeepCollectionsModel(
        [
          [1, 2],
          [3, 4, 5],
        ],
        {
          'letters': ['a', 'b'],
          'words': ['hello', 'world'],
        },
      );

      final map = deepCollectionsModelToMap(model);
      expect(map['matrix'], [
        [1, 2],
        [3, 4, 5],
      ]);
      expect(map['mappedLists']['letters'], ['a', 'b']);

      final restored = deepCollectionsModelFromMap(map);
      expect(restored.matrix, model.matrix);
      expect(restored.mappedLists, model.mappedLists);
    });
  });

  group('CaseStyle & ignoreFields', () {
    test('transforms keys to snake_case and ignores ignored fields', () {
      final model = CaseStyledModel('John Doe', 3, internalSecret: 'sensitive');
      final map = caseStyledModelToMap(model);

      expect(map['user_full_name'], 'John Doe');
      expect(map['login_attempt_count'], 3);
      expect(map.containsKey('internal_secret'), false);
      expect(map.containsKey('internalSecret'), false);

      final restored = caseStyledModelFromMap({
        'user_full_name': 'Jane Doe',
        'login_attempt_count': 5,
        'internal_secret': 'attacker_input',
      });

      expect(restored.userFullName, 'Jane Doe');
      expect(restored.loginAttemptCount, 5);
      expect(restored.internalSecret, 'secret'); // default fallback preserved
    });

    test('transforms enum keys using kebab-case', () {
      expect(themeModeToValue(ThemeMode.lightTheme), 'light-theme');
      expect(themeModeToValue(ThemeMode.darkTheme), 'dark-theme');
      expect(themeModeToValue(ThemeMode.systemDefault), 'system-default');

      expect(themeModeFromValue('light-theme'), ThemeMode.lightTheme);
      expect(themeModeFromValue('dark-theme'), ThemeMode.darkTheme);
      expect(themeModeFromValue('system-default'), ThemeMode.systemDefault);
      expect(() => themeModeFromValue('unknown-theme'), throwsArgumentError);
    });

    test('supports @SerializedValue and @ignore on enum entries', () {
      // 1. Serialization name override, ignore, and custom wire value
      expect(annotatedEnumToValue(AnnotatedEnum.inProgress), 'in_progress');
      expect(
        () => annotatedEnumToValue(AnnotatedEnum.internalSecret),
        throwsA(isA<TypeError>()),
      );
      expect(annotatedEnumToValue(AnnotatedEnum.archived), 'archived_val');

      // 2. Deserialization name override, custom wire value, and unknown value error
      expect(annotatedEnumFromValue('in_progress'), AnnotatedEnum.inProgress);
      expect(
        () => annotatedEnumFromValue('internalSecret'),
        throwsArgumentError,
      );
      expect(annotatedEnumFromValue('archived_val'), AnnotatedEnum.archived);
      expect(
        () => annotatedEnumFromValue('unknown_status_val'),
        throwsArgumentError,
      );
      expect(() => annotatedEnumFromValue(null), throwsArgumentError);
      expect(() => annotatedEnumFromValue(999), throwsArgumentError);
    });
  });

  group('Reference Usage: @Fallback, @SerializedValue, @ignore (Account & AccountType)', () {
    test('enum fail-fast by default vs enum @Fallback', () {
      // Normal enum fails fast on unknown
      expect(() => themeModeFromValue('non_existent'), throwsArgumentError);

      // AccountType has @Fallback(AccountType.standard)
      expect(accountTypeFromValue('std'), AccountType.standard);
      expect(accountTypeFromValue('prem'), AccountType.premium);
      expect(
        accountTypeFromValue('unrecognized_payload_string'),
        AccountType.standard,
      );
      expect(
        accountTypeFromValue('internalTest'),
        AccountType.standard,
      ); // @ignore stripped from cases
      expect(accountTypeFromValue(null), AccountType.standard);

      // toValue ignores internalTest
      expect(accountTypeToValue(AccountType.standard), 'std');
      expect(accountTypeToValue(AccountType.premium), 'prem');
      expect(
        () => accountTypeToValue(AccountType.internalTest),
        throwsA(isA<TypeError>()),
      );
    });

    test('field default injection via @Fallback on class', () {
      // missing loginCount and acc_type fallback
      final json = <String, dynamic>{
        'id': 'acc_001',
        'acc_type': 'prem',
      };
      final account = accountFromMap(json);
      expect(account.id, 'acc_001');
      expect(account.type, AccountType.premium);
      expect(account.loginCount, 0); // fallback injected
    });

    test('total exclusion of @ignore members across all generated logic', () {
      final timer1 = Stopwatch()..start();
      final timer2 = Stopwatch();
      final acc1 = Account(
        id: 'acc_001',
        type: AccountType.standard,
        loginCount: 5,
        sessionTimer: timer1,
      );
      final acc2 = Account(
        id: 'acc_001',
        type: AccountType.standard,
        loginCount: 5,
        sessionTimer: timer2,
      );

      // 1. Omitted from serialization toMap
      final map = accountToMap(acc1);
      expect(map, {
        'id': 'acc_001',
        'acc_type': 'std',
        'loginCount': 5,
      });
      expect(map.containsKey('sessionTimer'), false);

      // 2. Excluded from == and hashCode
      expect(acc1 == acc2, true);
      expect(acc1.hashCode, acc2.hashCode);

      // 3. Excluded from toString()
      expect(
        acc1.toString(),
        'Account(id: acc_001, type: AccountType.standard, loginCount: 5)',
      );
      expect(acc1.toString().contains('sessionTimer'), false);

      // 4. Excluded from copyWith parameters
      final updated = acc1.copyWith(id: 'acc_002');
      expect(updated.id, 'acc_002');
      expect(updated.sessionTimer, timer1); // preserved from this.sessionTimer
    });
  });

  group('Default Discriminator Sealed Hierarchy (Event)', () {
    test('serializes and deserializes with default type discriminator', () {
      final Event login = LoginEvent('user_123');
      final loginMap = eventToMap(login);
      expect(loginMap, {
        'userId': 'user_123',
        'type': 'LoginEvent',
      });

      final restoredLogin = eventFromMap(loginMap);
      expect(restoredLogin, isA<LoginEvent>());
      expect((restoredLogin as LoginEvent).userId, 'user_123');

      final Event logout = LogoutEvent();
      final logoutMap = eventToMap(logout);
      expect(logoutMap, {
        'type': 'LogoutEvent',
      });

      final restoredLogout = eventFromMap(logoutMap);
      expect(restoredLogout, isA<LogoutEvent>());
    });

    test('throws FormatException on missing or invalid default discriminator with source', () {
      final missingTypeJson = {'userId': 'user_123'};
      try {
        eventFromMap(missingTypeJson);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(e.message, contains("Missing required discriminator 'type'"));
        expect(e.source, same(missingTypeJson));
      }

      final unknownTypeJson = {'type': 'UnknownEvent'};
      try {
        eventFromMap(unknownTypeJson);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains("Unknown Event discriminator: 'UnknownEvent'"),
        );
        expect(e.source, same(unknownTypeJson));
      }
    });
  });

  group('Switch-based pattern matching JSON shape and type validation', () {
    test('throws FormatException referring to missing field and passes json source', () {
      final input1 = {'id': 'only_id'};
      try {
        complexModelFromMap(input1);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains("Missing required field 'count' for ComplexModel"),
        );
        expect(e.source, same(input1));
      }

      final input2 = <String, dynamic>{};
      try {
        nestedContainerFromMap(input2);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains("Missing required field 'containerId' for NestedContainer"),
        );
        expect(e.source, same(input2));
      }

      final input3 = {'containerId': 'c1'};
      try {
        nestedContainerFromMap(input3);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains("Missing required field 'model' for NestedContainer"),
        );
        expect(e.source, same(input3));
      }
    });

    test('throws FormatException referring to field with invalid type and passes json source', () {
      final input1 = {'radius': 'not_a_number'};
      try {
        circleFromMap(input1);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains(
            "Invalid type for field 'radius' on Circle: expected num, got String",
          ),
        );
        expect(e.source, same(input1));
      }

      final input2 = {'seats': 'four'};
      try {
        carFromMap(input2);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains(
            "Invalid type for field 'seats' on Car: expected num, got String",
          ),
        );
        expect(e.source, same(input2));
      }
    });

    test('throws FormatException when a required field is explicitly null with type failure message and source', () {
      final input1 = {'radius': null};
      try {
        circleFromMap(input1);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains(
            "Invalid type for field 'radius' on Circle: expected num, got Null",
          ),
        );
        expect(e.source, same(input1));
      }

      final input2 = {'seats': null};
      try {
        carFromMap(input2);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains(
            "Invalid type for field 'seats' on Car: expected num, got Null",
          ),
        );
        expect(e.source, same(input2));
      }
    });

    test('throws FormatException when a required enum/object field is explicitly null and passes source', () {
      final validMap = {
        'id': 'mod-123',
        'count': 42,
        'rating': 9.85,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'website': 'https://daxle.dev',
        'score': '987654321',
        'timeout': 500000,
        'metadata': {'env': 'prod'},
        'tags': ['dart'],
        'numbers': [1],
        'scores': {'math': 100},
        'status': null,
        'priority': 30,
      };
      try {
        complexModelFromMap(validMap);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains(
            "Invalid type for field 'status' on ComplexModel: expected non-null value, got Null",
          ),
        );
        expect(e.source, same(validMap));
      }
    });

    test('deserializes nested model with Map<dynamic, dynamic> and propagates inner FormatException with source', () {
      final innerJson = <dynamic, dynamic>{
        'id': 'nested-1',
        'count': 10,
        'rating': 4.5,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'website': 'https://daxle.dev',
        'score': '123',
        'timeout': 100,
        'metadata': {'k': 'v'},
        'tags': ['a'],
        'numbers': [1],
        'scores': {'s': 1},
        'status': 'active',
        'priority': 10,
      };
      final outer = <String, dynamic>{
        'containerId': 'c1',
        'model': innerJson,
      };
      final container = nestedContainerFromMap(outer);
      expect(container.containerId, 'c1');
      expect(container.model.id, 'nested-1');

      // Failure in nested model propagates inner FormatException and inner source:
      final invalidInner = <String, dynamic>{
        'id': 'nested-2',
        // missing count
      };
      final outerWithInvalidInner = <String, dynamic>{
        'containerId': 'c2',
        'model': invalidInner,
      };
      try {
        nestedContainerFromMap(outerWithInvalidInner);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(
          e.message,
          contains("Missing required field 'count' for ComplexModel"),
        );
        expect(e.source, invalidInner);
      }
    });

    test('throws FormatException on null discriminator as unknown discriminator and passes source', () {
      final nullTypeJson = {'type': null, 'userId': 'u1'};
      try {
        eventFromMap(nullTypeJson);
        fail('should have thrown FormatException');
      } on FormatException catch (e) {
        expect(e.message, contains("Unknown Event discriminator: 'null'"));
        expect(e.source, same(nullTypeJson));
      }
    });
  });

  group(
    'Reference Usage: @SerializedValue aliases, @Flatten, dynamic null handling',
    () {
      test(
        'PaymentStatus enum deserializes from canonical val or any alias and serializes strictly to canonical',
        () {
          expect(paymentStatusFromValue('pay_pending'), PaymentStatus.pending);
          expect(paymentStatusFromValue('pending'), PaymentStatus.pending);
          expect(paymentStatusFromValue('PAY_PENDING'), PaymentStatus.pending);
          expect(paymentStatusFromValue('in_progress'), PaymentStatus.pending);

          expect(paymentStatusFromValue('pay_success'), PaymentStatus.success);
          expect(paymentStatusFromValue('success'), PaymentStatus.success);
          expect(paymentStatusFromValue('completed'), PaymentStatus.success);

          expect(paymentStatusFromValue('pay_failed'), PaymentStatus.failed);
          expect(paymentStatusFromValue('failed'), PaymentStatus.failed);
          expect(paymentStatusFromValue('error'), PaymentStatus.failed);

          expect(
            () => paymentStatusFromValue('unknown_status'),
            throwsArgumentError,
          );

          expect(paymentStatusToValue(PaymentStatus.pending), 'pay_pending');
          expect(paymentStatusToValue(PaymentStatus.success), 'pay_success');
          expect(paymentStatusToValue(PaymentStatus.failed), 'pay_failed');
        },
      );

      test(
        'Incoming Payload A (canonical keys and values) parses correctly',
        () {
          final payloadA = <String, dynamic>{
            'id': 'ord_101',
            'order_status': 'pay_pending',
            'notes': null,
            'shipping_street': '123 Market St',
            'shipping_apt': null,
            'shipping_city': 'Austin',
          };

          final orderA = Order.fromMap(payloadA);
          expect(orderA.id, 'ord_101');
          expect(orderA.status, PaymentStatus.pending);
          expect(orderA.notes, isNull);
          expect(orderA.shippingAddress.street, '123 Market St');
          expect(orderA.shippingAddress.apt, isNull);
          expect(orderA.shippingAddress.city, 'Austin');
        },
      );

      test(
        'Incoming Payload B (legacy/alternative aliases) parses correctly',
        () {
          final payloadB = <String, dynamic>{
            'id': 'ord_101',
            'status': 'in_progress',
            'shipping_street': '123 Market St',
            'shipping_city': 'Austin',
          };

          final orderB = Order.fromMap(payloadB);
          expect(orderB.id, 'ord_101');
          expect(orderB.status, PaymentStatus.pending);
          expect(orderB.notes, isNull);
          expect(orderB.shippingAddress.street, '123 Market St');
          expect(orderB.shippingAddress.apt, isNull);
          expect(orderB.shippingAddress.city, 'Austin');
        },
      );

      test(
        'Standard Serialization (order.toMap()) preserves explicit null keys',
        () {
          final order = Order(
            id: 'ord_101',
            status: PaymentStatus.pending,
            notes: null,
            shippingAddress: Address(
              street: '123 Market St',
              apt: null,
              city: 'Austin',
            ),
          );

          final json = order.toMap();
          expect(json, {
            'id': 'ord_101',
            'order_status': 'pay_pending',
            'notes': null,
            'shipping_street': '123 Market St',
            'shipping_apt': null,
            'shipping_city': 'Austin',
          });
        },
      );

      test(
        'Sparse / PATCH Serialization (order.toMap(excludeNull: true)) strips nulls across root and child',
        () {
          final order = Order(
            id: 'ord_101',
            status: PaymentStatus.pending,
            notes: null,
            shippingAddress: Address(
              street: '123 Market St',
              apt: null,
              city: 'Austin',
            ),
          );

          final json = order.toMap(excludeNull: true);
          expect(json, {
            'id': 'ord_101',
            'order_status': 'pay_pending',
            'shipping_street': '123 Market St',
            'shipping_city': 'Austin',
          });
        },
      );

      test(
        'Throws FormatException when required field and all aliases are missing',
        () {
          final invalidPayload = <String, dynamic>{
            'id': 'ord_101',
            // missing order_status, status, and state
            'shipping_street': '123 Market St',
            'shipping_city': 'Austin',
          };

          expect(
            () => Order.fromMap(invalidPayload),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                contains("Missing required field 'order_status' for Order"),
              ),
            ),
          );
        },
      );
    },
  );
}
