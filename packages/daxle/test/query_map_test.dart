import 'dart:collection';

import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

enum _TestStatus { active, inactive, pending }

void main() {
  final Map<String, dynamic> sampleMap = {
    'services': {
      'server': {
        'host': 'https://api.production.internal',
        'port': 8080,
        'active': true,
        'metadata': {
          'datacenter': {
            'region': {
              'zone': {
                'rack': {
                  'unit': 42,
                },
              },
            },
          },
        },
      },
      'database': null,
    },
    'numbers': [10, 20, 30],
    'matrix': [
      [1, 2, 3],
      [4, 5, 6],
    ],
    'users': [
      {
        'id': 1,
        'name': 'Alice',
        'tags': ['admin', 'dev'],
        'settings': {
          'theme': 'dark',
          'notifications': {'email': true, 'sms': false},
        },
      },
      {
        'id': 2,
        'name': 'Bob',
        'tags': <String>[],
        'settings': null,
      },
    ],
    'collision': {
      '0': 'string_zero',
      0: 'int_zero',
    },
    'emptyMap': <String, dynamic>{},
    'emptyList': <dynamic>[],
  };

  /*
  group('QueryMap - get', () {
    group('Dot Notation Traversal (Maps Only)', () {
      test('extracts shallow and nested fields', () {
        final query = QueryMap(sampleMap);
        expect(
          query.get<String>('services.server.host'),
          'https://api.production.internal',
        );
        expect(query.get<int>('services.server.port'), 8080);
        expect(query.get<bool>('services.server.active'), isTrue);
      });

      test('extracts deeply nested fields (6+ levels deep)', () {
        final query = QueryMap(sampleMap);
        expect(
          query.get<int>(
            'services.server.metadata.datacenter.region.zone.rack.unit',
          ),
          42,
        );
      });

      test(
        'does NOT support list traversal with dot notation (returns null)',
        () {
          final query = QueryMap(sampleMap);
          // Arrays cannot be traversed with dot notation; bracket notation is required
          expect(query.get<int>('numbers.0'), isNull);
          expect(query.get<int>('numbers.2'), isNull);
          expect(query.get<String>('users.0.name'), isNull);
          expect(query.get<String>('users.0.tags.1'), isNull);
          expect(
            query.get<bool>('users.0.settings.notifications.email'),
            isNull,
          );
        },
      );
    });

    group('Bracket Notation Traversal (Arrays & Lists)', () {
      test('extracts elements from simple lists', () {
        final query = QueryMap(sampleMap);
        expect(query.get<int>('numbers[0]'), 10);
        expect(query.get<int>('numbers[1]'), 20);
        expect(query.get<int>('numbers[2]'), 30);
      });

      test('extracts mixed bracket and dot notation paths', () {
        final query = QueryMap(sampleMap);
        expect(query.get<String>('users[0].name'), 'Alice');
        expect(query.get<String>('users[0].tags[0]'), 'admin');
        expect(query.get<String>('users[0].tags[1]'), 'dev');
        expect(query.get<String>('users[0].settings.theme'), 'dark');
        expect(query.get<bool>('users[0].settings.notifications.sms'), isFalse);
      });
    });

    group('Key List / Iterable Traversal', () {
      test('extracts values using List<Object> paths with bracket notation on list fields', () {
        final query = QueryMap(sampleMap);
        expect(
          query.get<String>(['services', 'server', 'host']),
          'https://api.production.internal',
        );
        expect(query.get<int>(['numbers[1]']), 20);
        expect(query.get<String>(['users[0]', 'tags[1]']), 'dev');
        expect(
          query.get<bool>(['users[0]', 'settings', 'notifications', 'email']),
          isTrue,
        );
      });

      test('returns null if separate integer index is passed in key list for list', () {
        final query = QueryMap(sampleMap);
        // Individual indexing notation ['numbers', 1] is invalid
        expect(query.get<int>(['numbers', 1]), isNull);
        expect(query.get<int>(['numbers', '1']), isNull);
      });

      test('handles custom Iterable paths', () {
        final query = QueryMap(sampleMap);
        final path = const ['services', 'server', 'port'];
        expect(query.get<int>(path), 8080);
      });
    });

    group('Non-String Keys and Map Collisions', () {
      test('handles integer keys using key lists only', () {
        final query = QueryMap({
          'cluster': {
            101: {'ip': '10.0.0.101', 'status': 'UP'},
            102: {'ip': '10.0.0.102', 'status': 'DOWN'},
          },
        });
        expect(query.get<String>(['cluster', 101, 'ip']), '10.0.0.101');
        expect(query.get<String>('cluster.101.status'), isNull);
        expect(query.get<String>('cluster.102.ip'), isNull);
      });

      test('distinguishes between string "0" and int 0 when both exist', () {
        final query = QueryMap(sampleMap);
        // Direct key list lookup
        expect(query.get<String>(['collision', '0']), 'string_zero');
        expect(query.get<String>(['collision', 0]), 'int_zero');
      });

      test('supports boolean and custom object keys in key lists', () {
        final query = QueryMap({
          'flags': {
            true: 'enabled',
            false: 'disabled',
          },
        });
        expect(query.get<String>(['flags', true]), 'enabled');
        expect(query.get<String>(['flags', false]), 'disabled');
      });
    });

    group('Null Values & Missing Path Safety', () {
      test('returns null for missing keys at any depth', () {
        final query = QueryMap(sampleMap);
        expect(query.get<String>('nonexistent'), isNull);
        expect(query.get<String>('services.server.nonexistent'), isNull);
        expect(query.get<String>('services.nonexistent.deep'), isNull);
      });

      test('returns null when intermediate node is null', () {
        final query = QueryMap(sampleMap);
        // database is null
        expect(query.get<String>('services.database.name'), isNull);
        expect(query.get<int>('services.database.port.value'), isNull);
        // users[1].settings is null
        expect(query.get<String>('users[1].settings.theme'), isNull);
      });

      test(
        'returns null for leaf null values regardless of generic type nullability',
        () {
          final query = QueryMap(sampleMap);
          expect(query.get<String>('services.database'), isNull);
          expect(query.get<String?>('services.database'), isNull);
          expect(query.get<Object?>('services.database'), isNull);
        },
      );

      test(
        'returns null when attempting to traverse into non-map/non-list primitives',
        () {
          final query = QueryMap(sampleMap);
          // server.host is a String, not a Map
          expect(query.get<String>('services.server.host.extra'), isNull);
          // server.port is an int
          expect(query.get<String>('services.server.port.extra'), isNull);
          // server.active is a bool
          expect(query.get<String>('services.server.active[0]'), isNull);
        },
      );
    });

    group('Array Bounds & Malformed Index Safety', () {
      test('returns null for positive out-of-bounds index', () {
        final query = QueryMap(sampleMap);
        // numbers length is 3 (indices 0..2)
        expect(query.get<int>('numbers[3]'), isNull);
        expect(query.get<int>('numbers[99]'), isNull);
        expect(query.get<int>(['numbers[3]']), isNull);
      });

      test('returns null for negative list indices', () {
        final query = QueryMap(sampleMap);
        expect(query.get<int>('numbers[-1]'), isNull);
        expect(query.get<int>(['numbers[-1]']), isNull);
      });

      test('returns null when indexing into empty collections', () {
        final query = QueryMap(sampleMap);
        expect(query.get<dynamic>('emptyList[0]'), isNull);
        expect(query.get<dynamic>('emptyMap.foo'), isNull);
        expect(query.get<String>('users[1].tags[0]'), isNull);
      });

      test(
        'returns null for malformed bracket patterns without throwing FormatException',
        () {
          final query = QueryMap(sampleMap);
          expect(query.get<int>('numbers]'), isNull);
          expect(query.get<int>('numbers['), isNull);
          expect(query.get<int>('numbers[]'), isNull);
          expect(query.get<int>('numbers[abc]'), isNull);
          expect(query.get<int>('numbers[1.5]'), isNull);
        },
      );
    });

    group('Type Matching and Subtyping', () {
      test('returns value when queried with exact type', () {
        final query = QueryMap(sampleMap);
        expect(query.get<String>('services.server.host'), isA<String>());
        expect(query.get<int>('services.server.port'), isA<int>());
        expect(query.get<bool>('services.server.active'), isA<bool>());
      });

      test('returns value when queried with supertype', () {
        final query = QueryMap(sampleMap);
        expect(query.get<num>('services.server.port'), 8080);
        expect(
          query.get<Object>('services.server.host'),
          'https://api.production.internal',
        );
      });

      test('returns null on type mismatch without throwing TypeError', () {
        final query = QueryMap(sampleMap);
        expect(query.get<int>('services.server.host'), isNull);
        expect(query.get<String>('services.server.port'), isNull);
        expect(query.get<List<int>>('services.server.host'), isNull);
        expect(query.get<Map<String, dynamic>>('numbers'), isNull);
      });

      test('extracts nested collection objects with accurate types', () {
        final query = QueryMap(sampleMap);
        final serverMap = query.get<Map>('services.server');
        expect(serverMap, isNotNull);
        expect(serverMap?['port'], 8080);

        final numList = query.get<List>('numbers');
        expect(numList, [10, 20, 30]);
      });
    });

    group('Path Argument Edge Cases', () {
      test('empty string or empty list returns root map if type matches', () {
        final query = QueryMap(sampleMap);
        expect(query.get<Map>(''), sampleMap);
        expect(query.get<Map>([]), sampleMap);
        expect(query.get<String>(''), isNull);
      });

      test('throws ArgumentError for invalid path parameter types', () {
        final query = QueryMap(sampleMap);
        expect(() => query.get<String>(123), throwsArgumentError);
        expect(() => query.get<String>(true), throwsArgumentError);
        expect(() => query.get<String>(DateTime(2026)), throwsArgumentError);
      });

      test('handles leading, trailing, or consecutive dots gracefully', () {
        final query = QueryMap(sampleMap);
        expect(
          query.get<String>('.services.server.host'),
          'https://api.production.internal',
        );
        expect(
          query.get<String>('services.server.host.'),
          'https://api.production.internal',
        );
        expect(
          query.get<String>('services..server..host'),
          'https://api.production.internal',
        );
      });
    });

    group('Option Integration', () {
      test(
        'integrates cleanly with Option smart constructor and chaining',
        () {
          final query = QueryMap(sampleMap);
          final hostOpt = Option(query.get<String>('services.server.host'));
          expect(hostOpt.isSome, isTrue);
          expect(hostOpt.get(), 'https://api.production.internal');

          final fallback = Option(query.get<String>('services.missing'))
              .getOrElse(() => 'https://fallback.domain');
          expect(fallback, 'https://fallback.domain');
        },
      );
    });
  });
  */

  group('QueryMap - has', () {
    group('Dot Notation Traversal (Maps Only)', () {
      test('verifies shallow and nested key existence', () {
        final query = QueryMap(sampleMap);
        expect(query.has('services'), isTrue);
        expect(query.has('services.server'), isTrue);
        expect(query.has('services.server.host'), isTrue);
        expect(query.has('services.server.port'), isTrue);
        expect(query.has('services.server.active'), isTrue);
      });

      test('verifies deeply nested fields (6+ levels deep)', () {
        final query = QueryMap(sampleMap);
        expect(
          query.has(
            'services.server.metadata.datacenter.region.zone.rack.unit',
          ),
          isTrue,
        );
        expect(
          query.has('services.server.metadata.datacenter.region.zone.rack'),
          isTrue,
        );
        expect(
          query.has('services.server.metadata.datacenter.region.zone'),
          isTrue,
        );
        expect(
          query.has('services.server.metadata.datacenter.region'),
          isTrue,
        );
        expect(query.has('services.server.metadata.datacenter'), isTrue);
        expect(query.has('services.server.metadata'), isTrue);
      });

      test(
        'returns false for nonexistent keys at root, shallow, intermediate, and deep levels',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has('nonexistent'), isFalse);
          expect(query.has('services.nonexistent'), isFalse);
          expect(query.has('services.server.nonexistent'), isFalse);
          expect(query.has('services.server.metadata.nonexistent'), isFalse);
          expect(
            query.has(
              'services.server.metadata.datacenter.region.zone.rack.unit.nonexistent',
            ),
            isFalse,
          );
        },
      );

      test(
        'does NOT support list traversal with dot notation (returns false)',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has('numbers.0'), isFalse);
          expect(query.has('numbers.1'), isFalse);
          expect(query.has('numbers.2'), isFalse);
          expect(query.has('users.0.name'), isFalse);
          expect(query.has('users.0.tags.1'), isFalse);
          expect(query.has('users.0.settings.notifications.email'), isFalse);
        },
      );
    });

    group('Bracket Notation Traversal (Arrays & Lists)', () {
      test('verifies existence of elements in simple 1D lists', () {
        final query = QueryMap(sampleMap);
        expect(query.has('numbers[0]'), isTrue);
        expect(query.has('numbers[1]'), isTrue);
        expect(query.has('numbers[2]'), isTrue);
      });

      test('verifies mixed bracket and dot notation paths', () {
        final query = QueryMap(sampleMap);
        expect(query.has('users[0].name'), isTrue);
        expect(query.has('users[0].tags[0]'), isTrue);
        expect(query.has('users[0].tags[1]'), isTrue);
        expect(query.has('users[0].settings.theme'), isTrue);
        expect(query.has('users[0].settings.notifications.email'), isTrue);
        expect(query.has('users[0].settings.notifications.sms'), isTrue);
        expect(query.has('users[1].id'), isTrue);
        expect(query.has('users[1].name'), isTrue);
        expect(query.has('users[1].tags'), isTrue);
        expect(query.has('users[1].settings'), isTrue);
      });

      test(
        'returns false for missing properties or out-of-bounds in nested list objects',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has('users[0].address'), isFalse);
          expect(query.has('users[0].settings.notifications.push'), isFalse);
          expect(query.has('users[0].tags[2]'), isFalse);
          expect(query.has('users[1].tags[0]'), isFalse);
          expect(query.has('users[2].name'), isFalse);
          expect(query.has('users[99]'), isFalse);
        },
      );
    });

    group('Key List / Iterable Traversal', () {
      test(
        'verifies existence using List<Object> paths with bracket notation on list fields',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has(['services']), isTrue);
          expect(query.has(['services', 'server']), isTrue);
          expect(query.has(['services', 'server', 'host']), isTrue);
          expect(query.has(['services', 'server', 'port']), isTrue);
          expect(query.has(['numbers[0]']), isTrue);
          expect(query.has(['numbers[1]']), isTrue);
          expect(query.has(['numbers[2]']), isTrue);
          expect(query.has(['numbers[3]']), isFalse);
          expect(query.has(['users[0]', 'tags[0]']), isTrue);
          expect(query.has(['users[0]', 'tags[1]']), isTrue);
          expect(query.has(['users[0]', 'tags[2]']), isFalse);
          expect(
            query.has(['users[0]', 'settings', 'notifications', 'email']),
            isTrue,
          );
        },
      );

      test(
        'returns false when passing individual integer or string indices for lists in key lists',
        () {
          final query = QueryMap(sampleMap);
          // Individual indexing notation like ['numbers', 0] is invalid; ['numbers[0]'] must be used
          expect(query.has(['numbers', 0]), isFalse);
          expect(query.has(['numbers', 1]), isFalse);
          expect(query.has(['numbers', '0']), isFalse);
          expect(query.has(['numbers', '1']), isFalse);
          expect(query.has(['users', 0]), isFalse);
          expect(query.has(['users', 0, 'tags', 0]), isFalse);
        },
      );

      test(
        'handles custom Iterable paths (const list, Set, map generator)',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has(const ['services', 'server', 'port']), isTrue);
          expect(query.has({'services', 'server', 'port'}), isTrue);
          expect(
            query.has(['services', 'server', 'port'].map((s) => s)),
            isTrue,
          );
        },
      );

      test('handles empty List / Iterable path (returns true for root)', () {
        final query = QueryMap(sampleMap);
        expect(query.has([]), isTrue);
        expect(query.has(<String>[]), isTrue);
      });

      test(
        'handles keys containing dots or brackets when passed via key list',
        () {
          final specialKeysQuery = QueryMap({
            'config.with.dots': {
              'nested[key]': 123,
              'a.b.c': null,
            },
          });
          expect(
            specialKeysQuery.has(['config.with.dots', 'nested[key]']),
            isTrue,
          );
          expect(specialKeysQuery.has(['config.with.dots', 'a.b.c']), isTrue);
          expect(
            specialKeysQuery.has(['config.with.dots', 'nonexistent']),
            isFalse,
          );
        },
      );
    });

    group('Null Values & Existence vs Absence (Core has Semantics)', () {
      test('returns true for explicit null leaf values in maps', () {
        final query = QueryMap(sampleMap);
        // 'services.database' is explicitly null
        expect(query.has('services.database'), isTrue);
        expect(query.has(['services', 'database']), isTrue);
        expect(query.has('users[1].settings'), isTrue);
        expect(query.has(['users[1]', 'settings']), isTrue);

        final singleNull = QueryMap({'key': null});
        expect(singleNull.has('key'), isTrue);

        final nestedNull = QueryMap({
          'outer': {'inner': null},
        });
        expect(nestedNull.has('outer.inner'), isTrue);
        expect(nestedNull.has(['outer', 'inner']), isTrue);
      });

      test(
        'returns false when attempting to traverse deeper past a null intermediate map value',
        () {
          final query = QueryMap(sampleMap);
          // database is null, so properties under database do not exist
          expect(query.has('services.database.url'), isFalse);
          expect(query.has('services.database.host'), isFalse);
          expect(query.has(['services', 'database', 'url']), isFalse);
          // users[1].settings is null
          expect(query.has('users[1].settings.theme'), isFalse);
          expect(query.has('users[1].settings.notifications'), isFalse);
          expect(query.has(['users[1]', 'settings', 'theme']), isFalse);
        },
      );

      test('returns true for explicit null elements in lists', () {
        final nullListQuery = QueryMap({
          'items': [null, 42, null],
        });
        expect(nullListQuery.has('items[0]'), isTrue);
        expect(nullListQuery.has('items[1]'), isTrue);
        expect(nullListQuery.has('items[2]'), isTrue);
        expect(nullListQuery.has('items[3]'), isFalse);
        expect(nullListQuery.has(['items[0]']), isTrue);
        expect(nullListQuery.has(['items[1]']), isTrue);
        expect(nullListQuery.has(['items[2]']), isTrue);
        expect(nullListQuery.has(['items[3]']), isFalse);
      });

      test(
        'returns false when attempting to traverse deeper past a null list element',
        () {
          final nullListQuery = QueryMap({
            'items': [
              null,
              {'name': 'valid'},
            ],
          });
          expect(nullListQuery.has('items[0].name'), isFalse);
          expect(nullListQuery.has(['items[0]', 'name']), isFalse);
          expect(nullListQuery.has('items[1].name'), isTrue);
          expect(nullListQuery.has(['items[1]', 'name']), isTrue);
        },
      );

      test(
        'returns true for falsy, zero, or empty values (non-null primitives)',
        () {
          final falsyQuery = QueryMap({
            'boolFalse': false,
            'zeroInt': 0,
            'zeroDouble': 0.0,
            'emptyStr': '',
            'emptyList': <dynamic>[],
            'emptyMap': <String, dynamic>{},
          });
          expect(falsyQuery.has('boolFalse'), isTrue);
          expect(falsyQuery.has('zeroInt'), isTrue);
          expect(falsyQuery.has('zeroDouble'), isTrue);
          expect(falsyQuery.has('emptyStr'), isTrue);
          expect(falsyQuery.has('emptyList'), isTrue);
          expect(falsyQuery.has('emptyMap'), isTrue);
        },
      );
    });

    group('Non-String Keys and Map Collisions', () {
      test('handles integer map keys using key lists only', () {
        final clusterQuery = QueryMap({
          'cluster': {
            101: {'ip': '10.0.0.101', 'status': 'UP'},
            102: {'ip': '10.0.0.102', 'status': 'DOWN'},
          },
        });
        // Key lists preserve the exact integer key type
        expect(clusterQuery.has(['cluster', 101]), isTrue);
        expect(clusterQuery.has(['cluster', 101, 'ip']), isTrue);
        expect(clusterQuery.has(['cluster', 101, 'status']), isTrue);
        expect(clusterQuery.has(['cluster', 103, 'ip']), isFalse);

        // String dot notation paths treat '101' as a String, which does not match int 101
        expect(clusterQuery.has('cluster.101.ip'), isFalse);
        expect(clusterQuery.has('cluster.102.status'), isFalse);
        expect(clusterQuery.has('cluster.103.ip'), isFalse);
      });

      test(
        'distinguishes between string "0" and int 0 when both exist in map',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has(['collision', '0']), isTrue);
          expect(query.has(['collision', 0]), isTrue);
          expect(query.has(['collision', 1]), isFalse);
          expect(query.has(['collision', '1']), isFalse);
        },
      );

      test(
        'supports boolean, enum, and custom object keys in key lists',
        () {
          final boolMap = QueryMap({
            'flags': {
              true: 'enabled',
              false: 'disabled',
            },
          });
          expect(boolMap.has(['flags', true]), isTrue);
          expect(boolMap.has(['flags', false]), isTrue);
          expect(boolMap.has(['flags', 'true']), isFalse);

          final enumMap = QueryMap({
            _TestStatus.active: {'count': 10},
            _TestStatus.inactive: null,
          });
          expect(enumMap.has([_TestStatus.active, 'count']), isTrue);
          expect(enumMap.has([_TestStatus.inactive]), isTrue);
          expect(enumMap.has([_TestStatus.pending]), isFalse);
        },
      );
    });

    group('Array Bounds & Malformed Index Safety', () {
      test('returns false for positive out-of-bounds index', () {
        final query = QueryMap(sampleMap);
        expect(query.has('numbers[3]'), isFalse);
        expect(query.has('numbers[99]'), isFalse);
        expect(query.has(['numbers[3]']), isFalse);
        expect(query.has(['numbers[99]']), isFalse);
      });

      test(
        'returns false for negative list indices in string and list paths',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has('numbers[-1]'), isFalse);
          expect(query.has('numbers[-10]'), isFalse);
          expect(query.has(['numbers[-1]']), isFalse);
        },
      );

      test('returns false when indexing into empty collections', () {
        final query = QueryMap(sampleMap);
        expect(query.has('emptyList[0]'), isFalse);
        expect(query.has(['emptyList[0]']), isFalse);
        expect(query.has('emptyMap.foo'), isFalse);
        expect(query.has(['emptyMap', 'foo']), isFalse);
        expect(query.has('users[1].tags[0]'), isFalse);
      });

      test(
        'returns false for malformed bracket patterns without throwing FormatException',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has('numbers]'), isFalse);
          expect(query.has('numbers['), isFalse);
          expect(query.has('numbers[]'), isFalse);
          expect(query.has('numbers[abc]'), isFalse);
          expect(query.has('numbers[1.5]'), isFalse);
          expect(query.has('numbers[ 0 ]'), isFalse);
          expect(query.has('numbers[0'), isFalse);
          expect(query.has('numbers0]'), isFalse);
          expect(query.has('numbers[[0]]'), isFalse);
          expect(query.has('numbers[0]junk'), isFalse);
          expect(query.has('numbers[0]abc'), isFalse);
        },
      );

      test(
        'returns false for malformed array syntax at root or intermediate positions',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has('[0]'), isFalse);
          expect(query.has('.[0]'), isFalse);
          expect(query.has('services.[0].host'), isFalse);
        },
      );
    });

    group(
      'Primitive Traversal Safety (Attempting to traverse into non-containers)',
      () {
        test(
          'returns false when attempting to traverse into string primitives',
          () {
            final query = QueryMap(sampleMap);
            expect(query.has('services.server.host.extra'), isFalse);
            expect(query.has('services.server.host[0]'), isFalse);
            expect(query.has(['services', 'server', 'host', 'extra']), isFalse);
          },
        );

        test(
          'returns false when attempting to traverse into numeric primitives',
          () {
            final query = QueryMap(sampleMap);
            expect(query.has('services.server.port.value'), isFalse);
            expect(query.has('services.server.port[0]'), isFalse);
            expect(query.has(['services', 'server', 'port', 'value']), isFalse);
          },
        );

        test(
          'returns false when attempting to traverse into boolean primitives',
          () {
            final query = QueryMap(sampleMap);
            expect(query.has('services.server.active.enabled'), isFalse);
            expect(query.has('services.server.active[0]'), isFalse);
            expect(
              query.has(['services', 'server', 'active', 'enabled']),
              isFalse,
            );
          },
        );

        test(
          'returns false when attempting to traverse into list primitives with bracket notation',
          () {
            final query = QueryMap(sampleMap);
            // numbers[0] is int 10
            expect(query.has(['numbers[0]', 'extra']), isFalse);
          },
        );
      },
    );

    group('Path Argument Edge Cases', () {
      test(
        'empty string or empty list returns true for root map',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has(''), isTrue);
          expect(query.has([]), isTrue);

          final emptyQuery = QueryMap({});
          expect(emptyQuery.has(''), isTrue);
          expect(emptyQuery.has([]), isTrue);
        },
      );

      test('throws ArgumentError for invalid path parameter types', () {
        final query = QueryMap(sampleMap);
        expect(() => query.has(123), throwsArgumentError);
        expect(() => query.has(true), throwsArgumentError);
        expect(() => query.has(3.14), throwsArgumentError);
        expect(() => query.has(DateTime(2026)), throwsArgumentError);
        expect(() => query.has(Object()), throwsArgumentError);
      });

      test(
        'handles leading, trailing, or consecutive dots gracefully',
        () {
          final query = QueryMap(sampleMap);
          expect(query.has('.services.server.host'), isTrue);
          expect(query.has('services.server.host.'), isTrue);
          expect(query.has('services..server..host'), isTrue);
          expect(query.has('.nonexistent.'), isFalse);
        },
      );
    });

    group('Special Characters, Unicode, and Whitespace in Keys', () {
      test(
        'handles keys with whitespace, dashes, underscores, symbols, and unicode',
        () {
          final specialQuery = QueryMap({
            'user-name': 'Alice',
            'user_age': 30,
            'spaced key': {'sub key': 123},
            '🚀': {'status': 'active'},
            'привет': 'мир',
            r'$schema': 'https://json-schema.org',
          });
          expect(specialQuery.has('user-name'), isTrue);
          expect(specialQuery.has('user_age'), isTrue);
          expect(specialQuery.has(['spaced key', 'sub key']), isTrue);
          expect(specialQuery.has('🚀.status'), isTrue);
          expect(specialQuery.has('привет'), isTrue);
          expect(specialQuery.has(r'$schema'), isTrue);
          expect(specialQuery.has('🚀.missing'), isFalse);
          expect(specialQuery.has('user-name.invalid'), isFalse);
        },
      );
    });

    group('Heterogeneous and Deep Real-World Data Structures', () {
      test('traverses complex nested structures with arrays of objects', () {
        final complexQuery = QueryMap({
          'departments': [
            {
              'name': 'Engineering',
              'teams': [
                {
                  'teamName': 'Core',
                  'leads': [
                    {'name': 'Dev', 'active': true, 'notes': null},
                  ],
                },
              ],
            },
          ],
        });
        expect(complexQuery.has('departments[0].name'), isTrue);
        expect(
          complexQuery.has('departments[0].teams[0].leads[0].active'),
          isTrue,
        );
        expect(
          complexQuery.has('departments[0].teams[0].leads[0].notes'),
          isTrue,
        );
        expect(
          complexQuery.has('departments[0].teams[0].leads[0].notes.details'),
          isFalse,
        );
        expect(
          complexQuery.has('departments[0].teams[0].leads[1].name'),
          isFalse,
        );
        expect(complexQuery.has('departments[1].name'), isFalse);
      });

      test('works with Sets and Queues within the map structure', () {
        final iterableQuery = QueryMap({
          'tags': {'admin', 'dev'},
          'queue': Queue.of([100, 200, 300]),
        });
        expect(iterableQuery.has('tags[0]'), isTrue);
        expect(iterableQuery.has('tags[1]'), isTrue);
        expect(iterableQuery.has('tags[2]'), isFalse);
        expect(iterableQuery.has('queue[0]'), isTrue);
        expect(iterableQuery.has('queue[2]'), isTrue);
        expect(iterableQuery.has('queue[3]'), isFalse);
      });
    });
  });
}
