import 'package:benchmark/benchmark_core.dart';
import 'package:daxle/daxle.dart';

// --- Allocation Benchmarks ---

class AllocationOptionSomeBenchmark extends Benchmark {
  AllocationOptionSomeBenchmark() : super('Allocate Option.some');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i));
  }
}

class AllocationOptionNoneBenchmark extends Benchmark {
  AllocationOptionNoneBenchmark() : super('Allocate Option.none');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.none());
  }
}

class AllocationEitherRightBenchmark extends Benchmark {
  AllocationEitherRightBenchmark() : super('Allocate Either.right');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i));
  }
}

class AllocationEitherLeftBenchmark extends Benchmark {
  AllocationEitherLeftBenchmark() : super('Allocate Either.left');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()));
  }
}

class AllocationTaskEitherRightBenchmark extends Benchmark {
  AllocationTaskEitherRightBenchmark() : super('Allocate TaskEither.right');

  @override
  void run(int i) {
    sinkBlackhole(TaskEither<String, int>.right(i));
  }
}

class AllocationTaskEitherLeftBenchmark extends Benchmark {
  AllocationTaskEitherLeftBenchmark() : super('Allocate TaskEither.left');

  @override
  void run(int i) {
    sinkBlackhole(TaskEither<String, int>.left(i.toString()));
  }
}
