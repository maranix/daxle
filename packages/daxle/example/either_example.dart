import 'package:daxle/daxle.dart';

// Standard Dart: throws runtime exceptions requiring try-catch callers
int divideStandard(int a, int b) {
  if (b == 0) throw ArgumentError('Cannot divide by zero');
  return a ~/ b;
}

// Daxle: failures represented explicitly as values
Either<String, int> divide(int a, int b) {
  if (b == 0) return const .left('Cannot divide by zero');
  return .right(a ~/ b);
}

void main() {
  print('--- Either Demo ---');

  // Handle divide using Either
  final result = divide(10, 0);
  final message = switch (result) {
    Left(value: final err) => 'Division failed: $err',
    Right(value: final val) => 'Result: $val',
  };
  print(message);
}
