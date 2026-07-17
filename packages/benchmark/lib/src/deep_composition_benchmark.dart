import 'package:benchmark/benchmark_core.dart';
import 'package:daxle/daxle.dart';
import 'package:fpdart/fpdart.dart' as fp;

// --- Deep Composition Benchmarks ---
// These test if the compiler can inline the chained calls or if object/closure overhead accumulates.

class DeepOptionMapBenchmark extends Benchmark {
  DeepOptionMapBenchmark() : super('Deep Option.map (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    Option<int> opt = Option<int>.some(i);
    for (int j = 0; j < 1000; j++) {
      opt = opt.map((v) => v + 1);
    }
    sinkBlackhole(opt);
  }
}

class FpdartDeepOptionMapBenchmark extends Benchmark {
  FpdartDeepOptionMapBenchmark() : super('fpdart Deep Option.map (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    fp.Option<int> opt = fp.Option<int>.of(i);
    for (int j = 0; j < 1000; j++) {
      opt = opt.map((v) => v + 1);
    }
    sinkBlackhole(opt);
  }
}

class DeepOptionFlatMapBenchmark extends Benchmark {
  DeepOptionFlatMapBenchmark() : super('Deep Option.flatMap (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    Option<int> opt = Option<int>.some(i);
    for (int j = 0; j < 1000; j++) {
      opt = opt.flatMap((v) => Option<int>.some(v + 1));
    }
    sinkBlackhole(opt);
  }
}

class FpdartDeepOptionFlatMapBenchmark extends Benchmark {
  FpdartDeepOptionFlatMapBenchmark() : super('fpdart Deep Option.flatMap (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    fp.Option<int> opt = fp.Option<int>.of(i);
    for (int j = 0; j < 1000; j++) {
      opt = opt.flatMap((v) => fp.Option<int>.of(v + 1));
    }
    sinkBlackhole(opt);
  }
}

class DeepNullableMapBenchmark extends Benchmark {
  DeepNullableMapBenchmark() : super('Deep Nullable (T?) map equiv (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    int? val = i;
    for (int j = 0; j < 1000; j++) {
      val = val != null ? val + 1 : null;
    }
    sinkBlackhole(val);
  }
}

class DeepEitherMapBenchmark extends Benchmark {
  DeepEitherMapBenchmark() : super('Deep Either.map (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    Either<String, int> e = Either<String, int>.right(i);
    for (int j = 0; j < 1000; j++) {
      e = e.map((v) => v + 1);
    }
    sinkBlackhole(e);
  }
}

class FpdartDeepEitherMapBenchmark extends Benchmark {
  FpdartDeepEitherMapBenchmark() : super('fpdart Deep Either.map (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    fp.Either<String, int> e = fp.Either<String, int>.right(i);
    for (int j = 0; j < 1000; j++) {
      e = e.map((v) => v + 1);
    }
    sinkBlackhole(e);
  }
}

class DeepEitherFlatMapBenchmark extends Benchmark {
  DeepEitherFlatMapBenchmark() : super('Deep Either.flatMap (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    Either<String, int> e = Either<String, int>.right(i);
    for (int j = 0; j < 1000; j++) {
      e = e.flatMap((v) => Either<String, int>.right(v + 1));
    }
    sinkBlackhole(e);
  }
}

class FpdartDeepEitherFlatMapBenchmark extends Benchmark {
  FpdartDeepEitherFlatMapBenchmark() : super('fpdart Deep Either.flatMap (1000 chained)', iterations: 100000);

  @override
  void run(int i) {
    fp.Either<String, int> e = fp.Either<String, int>.right(i);
    for (int j = 0; j < 1000; j++) {
      e = e.flatMap((v) => fp.Either<String, int>.right(v + 1));
    }
    sinkBlackhole(e);
  }
}

class DeepTaskEitherMapBenchmark extends AsyncBenchmark {
  DeepTaskEitherMapBenchmark() : super('Deep TaskEither.map (100 chained)', iterations: 1000);

  @override
  Future<void> run(int i) async {
    TaskEither<String, int> task = TaskEither<String, int>.right(i);
    for (int j = 0; j < 100; j++) {
      task = task.map((v) => v + 1);
    }
    sinkBlackhole(await task.run());
  }
}

class FpdartDeepTaskEitherMapBenchmark extends AsyncBenchmark {
  FpdartDeepTaskEitherMapBenchmark() : super('fpdart Deep TaskEither.map (100 chained)', iterations: 1000);

  @override
  Future<void> run(int i) async {
    fp.TaskEither<String, int> task = fp.TaskEither<String, int>.right(i);
    for (int j = 0; j < 100; j++) {
      task = task.map((v) => v + 1);
    }
    sinkBlackhole(await task.run());
  }
}

class DeepFutureMapBenchmark extends AsyncBenchmark {
  DeepFutureMapBenchmark() : super('Deep Future.then (100 chained)', iterations: 1000);

  @override
  Future<void> run(int i) async {
    Future<int> future = Future.value(i);
    for (int j = 0; j < 100; j++) {
      future = future.then((v) => v + 1);
    }
    sinkBlackhole(await future);
  }
}

class DeepTaskEitherFlatMapBenchmark extends AsyncBenchmark {
  DeepTaskEitherFlatMapBenchmark() : super('Deep TaskEither.flatMap (100 chained)', iterations: 1000);

  @override
  Future<void> run(int i) async {
    TaskEither<String, int> task = TaskEither<String, int>.right(i);
    for (int j = 0; j < 100; j++) {
      task = task.flatMap((v) => TaskEither<String, int>.right(v + 1));
    }
    sinkBlackhole(await task.run());
  }
}

class FpdartDeepTaskEitherFlatMapBenchmark extends AsyncBenchmark {
  FpdartDeepTaskEitherFlatMapBenchmark() : super('fpdart Deep TaskEither.flatMap (100 chained)', iterations: 1000);

  @override
  Future<void> run(int i) async {
    fp.TaskEither<String, int> task = fp.TaskEither<String, int>.right(i);
    for (int j = 0; j < 100; j++) {
      task = task.flatMap((v) => fp.TaskEither<String, int>.right(v + 1));
    }
    sinkBlackhole(await task.run());
  }
}
