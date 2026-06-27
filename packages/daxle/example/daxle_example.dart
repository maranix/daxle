import 'package:daxle/daxle.dart';

void main() async {
  print('=== Daxle v2.0.0 Example ===\n');

  // ---------------------------------------------------------------------------
  // 1. Option<T> - Safe Handling of Optional Values
  // ---------------------------------------------------------------------------
  print('--- 1. Option Examples ---');
  final Option<int> someValue = Option.some(42);
  final Option<int> noValue = Option.none();
  final Option<int> fromNullable = Option.of(null);

  print('someValue isSome: ${someValue.isSome}'); // true
  print('noValue isNone: ${noValue.isNone}'); // true
  print('fromNullable isNone: ${fromNullable.isNone}'); // true

  // Transforming options
  final Option<String> mapped = someValue.map((v) => 'The answer is $v');
  print('Mapped Option: $mapped'); // Some(The answer is 42)

  // Retrieving values safely
  final int value1 = someValue.getOrElse(0);
  final int value2 = noValue.getOrElse(0);
  print('someValue.getOrElse(0): $value1'); // 42
  print('noValue.getOrElse(0): $value2'); // 0

  // Pattern matching on Option
  final String matchingResult = switch (someValue) {
    Some(value: final v) => 'Found value: $v',
    None() => 'No value present',
  };
  print('Pattern match result: $matchingResult\n');

  // ---------------------------------------------------------------------------
  // 2. Either<L, R> - Represents Either Left (Failure) or Right (Success)
  // ---------------------------------------------------------------------------
  print('--- 2. Either Examples ---');
  Either<String, int> divide(int a, int b) {
    if (b == 0) {
      return const Left('Division by zero error');
    }
    return Right(a ~/ b);
  }

  final successResult = divide(10, 2);
  final failureResult = divide(10, 0);

  // Mapping success (Right)
  final mappedResult = successResult.map((v) => v * 10);
  print('mappedResult (Right): $mappedResult'); // Right(50)

  // Folding Either to extract the value
  final foldedSuccess = successResult.fold(
    (leftError) => 'Error: $leftError',
    (rightVal) => 'Success: $rightVal',
  );
  print('Folded success: $foldedSuccess'); // Success: 5

  final foldedFailure = failureResult.fold(
    (leftError) => 'Error: $leftError',
    (rightVal) => 'Success: $rightVal',
  );
  print('Folded failure: $foldedFailure'); // Error: Division by zero error

  // Pattern matching on Either
  final matchingEither = switch (failureResult) {
    Left(value: final err) => 'Failure branch: $err',
    Right(value: final val) => 'Success branch: $val',
  };
  print('Pattern match result on Either: $matchingEither\n');

  // ---------------------------------------------------------------------------
  // 3. TaskEither<L, R> - Lazy & Safe Asynchronous Computations
  // ---------------------------------------------------------------------------
  print('--- 3. TaskEither Examples ---');

  // A mock network request that can fail
  Future<String> fetchUserData(int userId) async {
    if (userId < 0) {
      throw ArgumentError('Invalid user ID');
    }
    return 'User #$userId';
  }

  // Wrap a Future with TaskEither.fromFuture to catch and map errors
  TaskEither<String, String> getUserTask(int id) {
    return TaskEither.fromFuture(
      () => fetchUserData(id),
      (error, stackTrace) => 'Failed to fetch user: $error',
    );
  }

  final successfulTask = getUserTask(42);
  final failingTask = getUserTask(-1);

  // Map and run successful task
  final userResult = await successfulTask
      .map((name) => '$name (Verified)')
      .run();
  print(
    'Successful TaskEither run result: $userResult',
  ); // Right(User #42 (Verified))

  // Run and fold failing task
  final foldedTaskMsg = await failingTask.fold(
    (error) => 'Recovered error: $error',
    (user) => 'Fetched user: $user',
  );
  print(
    'Failing TaskEither run & fold result: $foldedTaskMsg\n',
  ); // Recovered error: Failed to fetch user: Invalid user ID

  // ---------------------------------------------------------------------------
  // 4. Pipeline<T> - Deferred Synchronous Computation Pipeline
  // ---------------------------------------------------------------------------
  print('--- 4. Pipeline Examples ---');

  final syncPipeline = Pipeline(() => 10)
      .pipe((x) => x * 2)
      .tap((x) => print('  [Pipeline Tap] Current value: $x'))
      .pipe((x) => 'Value: $x')
      .finalize(
        () => print('  [Pipeline Finalize] Sync pipeline clean up complete.'),
      );

  print('Running sync pipeline...');
  final finalSyncVal = syncPipeline.run();
  print('Sync pipeline result: $finalSyncVal\n');

  // ---------------------------------------------------------------------------
  // 5. AsyncPipeline<T> - Deferred Asynchronous Computation Pipeline
  // ---------------------------------------------------------------------------
  print('--- 5. AsyncPipeline Examples ---');

  final asyncPipeline = AsyncPipeline(() => Future.value(100))
      .pipe((x) async => x + 50)
      .tap((x) => print('  [AsyncPipeline Tap] Progressed to: $x'))
      .pipe((x) => 'Total: $x')
      .finalize(
        () async => print(
          '  [AsyncPipeline Finalize] Async pipeline clean up complete.',
        ),
      );

  print('Running async pipeline...');
  final finalAsyncVal = await asyncPipeline.run();
  print('Async pipeline result: $finalAsyncVal\n');

  // Concurrently zipping two AsyncPipelines using Dart's concurrent .wait futures API
  final p1 = AsyncPipeline(
    () => Future.delayed(const Duration(milliseconds: 10), () => 5),
  );
  final p2 = AsyncPipeline(
    () => Future.delayed(const Duration(milliseconds: 20), () => 10),
  );

  final zipped = p1.zip(p2, (a, b) => a + b);
  final zipResult = await zipped.run();
  print('Zipped pipelines concurrent run result (5 + 10): $zipResult');
}
