import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

sealed class TestState {
  const TestState();
}

final class StateIdle extends TestState {
  const StateIdle();
}

final class StateBooting extends TestState {
  const StateBooting();
}

final class StateProgress extends TestState {
  final int count;
  const StateProgress(this.count);
}

final class StateReady extends TestState {
  const StateReady();
}

final class StateFailure extends TestState {
  const StateFailure();
}

void main() {
  group('StateMachine & Flow annotations', () {
    test('instantiates StateMachine and Flow objects', () {
      const machine = StateMachine([
        Flow(from: StateIdle, to: StateBooting),
        Flow(from: StateBooting, to: StateReady),
      ]);

      expect(machine.flows.length, 2);
      expect(machine.flows[0].from, StateIdle);
      expect(machine.flows[0].to, StateBooting);
      expect(machine.flows[0].using, isNull);
    });
  });

  group('TransitionScope', () {
    late TestState activeState;
    late List<TestState> emitted;
    late bool isActive;
    final allowed = <Type, Set<Type>>{
      StateIdle: {StateBooting},
      StateBooting: {StateProgress, StateReady, StateFailure},
      StateProgress: {StateProgress, StateReady, StateFailure},
      StateFailure: {StateIdle},
      StateReady: {},
    };

    setUp(() {
      activeState = const StateBooting();
      emitted = [];
      isActive = true;
    });

    TransitionScope<TestState> createScope() {
      return TransitionScope<TestState>(
        getActiveState: () => activeState,
        setActiveState: (next) => activeState = next,
        isStillActive: () => isActive,
        allowedTransitions: allowed,
        emit: emitted.add,
      );
    }

    test('permits valid transitions and updates active state', () {
      final scope = createScope();
      expect(scope.isCurrent, isTrue);

      scope.transit(const StateProgress(1));
      expect(activeState, isA<StateProgress>());
      expect(emitted, [isA<StateProgress>()]);

      scope.transit(const StateProgress(2));
      expect(emitted.length, 2);

      scope.transit(const StateReady());
      expect(activeState, isA<StateReady>());
      expect(emitted.length, 3);
    });

    test('throws InvalidFlowException for disallowed target', () {
      final scope = createScope();

      expect(
        () => scope.transit(const StateIdle()),
        throwsA(
          isA<InvalidFlowException>().having(
            (e) => e.toString(),
            'toString()',
            contains('Transition from StateBooting to StateIdle is not permitted'),
          ),
        ),
      );
    });

    test('drops transit calls silently when isCurrent is false', () {
      final scope = createScope();
      isActive = false;
      expect(scope.isCurrent, isFalse);

      scope.transit(const StateReady());
      expect(emitted, isEmpty);
      expect(activeState, isA<StateBooting>());
    });
  });
}
