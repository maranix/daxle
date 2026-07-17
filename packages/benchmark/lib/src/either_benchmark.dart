import 'package:benchmark/benchmark_core.dart';
import 'package:daxle/daxle.dart';
import 'package:fpdart/fpdart.dart' as fp;

int _identity(int x) => x;
String _identityLeft(String x) => x;
Either<String, int> _rightIdentity(int x) => Either.right(x);

// --- Either Construction Benchmarks ---

class EitherRightConstructionBenchmark extends Benchmark {
  EitherRightConstructionBenchmark() : super('Either.right Construction');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i));
  }
}

class EitherLeftConstructionBenchmark extends Benchmark {
  EitherLeftConstructionBenchmark() : super('Either.left Construction');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()));
  }
}

class BranchingRightConstructionBenchmark extends Benchmark {
  BranchingRightConstructionBenchmark() : super('Exception (Success) Construction');

  @override
  void run(int i) {
    sinkBlackhole(i);
  }
}

class BranchingLeftConstructionBenchmark extends Benchmark {
  BranchingLeftConstructionBenchmark() : super('Exception (Error) Construction');

  @override
  void run(int i) {
    sinkBlackhole(Exception(i.toString()));
  }
}

// --- Either Identity Benchmarks (Abstraction Cost) ---

class EitherRightIdentityMapBenchmark extends Benchmark {
  EitherRightIdentityMapBenchmark() : super('Either.right map(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).map(_identity));
  }
}

class EitherLeftIdentityMapBenchmark extends Benchmark {
  EitherLeftIdentityMapBenchmark() : super('Either.left map(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).map(_identity));
  }
}

class EitherRightIdentityMapLeftBenchmark extends Benchmark {
  EitherRightIdentityMapLeftBenchmark() : super('Either.right mapLeft(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).mapLeft(_identityLeft));
  }
}

class EitherLeftIdentityMapLeftBenchmark extends Benchmark {
  EitherLeftIdentityMapLeftBenchmark() : super('Either.left mapLeft(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).mapLeft(_identityLeft));
  }
}

class EitherRightIdentityBimapBenchmark extends Benchmark {
  EitherRightIdentityBimapBenchmark() : super('Either.right bimap(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).bimap(_identityLeft, _identity));
  }
}

class EitherLeftIdentityBimapBenchmark extends Benchmark {
  EitherLeftIdentityBimapBenchmark() : super('Either.left bimap(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).bimap(_identityLeft, _identity));
  }
}

class EitherRightIdentityFlatMapBenchmark extends Benchmark {
  EitherRightIdentityFlatMapBenchmark() : super('Either.right flatMap(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).flatMap(_rightIdentity));
  }
}

class EitherLeftIdentityFlatMapBenchmark extends Benchmark {
  EitherLeftIdentityFlatMapBenchmark() : super('Either.left flatMap(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).flatMap(_rightIdentity));
  }
}

class EitherRightIdentityFoldBenchmark extends Benchmark {
  EitherRightIdentityFoldBenchmark() : super('Either.right fold(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).fold((_) => 0, _identity));
  }
}

class EitherLeftIdentityFoldBenchmark extends Benchmark {
  EitherLeftIdentityFoldBenchmark() : super('Either.left fold(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).fold((_) => 0, _identity));
  }
}


// --- Either map Benchmarks ---

class EitherRightMapBenchmark extends Benchmark {
  EitherRightMapBenchmark() : super('Either.right map');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).map((v) => v + 1));
  }
}

class EitherLeftMapBenchmark extends Benchmark {
  EitherLeftMapBenchmark() : super('Either.left map');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).map((v) => v + 1));
  }
}

// --- Either mapLeft Benchmarks ---

class EitherRightMapLeftBenchmark extends Benchmark {
  EitherRightMapLeftBenchmark() : super('Either.right mapLeft');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).mapLeft((e) => '$e!'));
  }
}

class EitherLeftMapLeftBenchmark extends Benchmark {
  EitherLeftMapLeftBenchmark() : super('Either.left mapLeft');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).mapLeft((e) => '$e!'));
  }
}

// --- Either bimap Benchmarks ---

class EitherRightBimapBenchmark extends Benchmark {
  EitherRightBimapBenchmark() : super('Either.right bimap');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).bimap((e) => '$e!', (v) => v + 1));
  }
}

class EitherLeftBimapBenchmark extends Benchmark {
  EitherLeftBimapBenchmark() : super('Either.left bimap');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).bimap((e) => '$e!', (v) => v + 1));
  }
}

// --- Either flatMap Benchmarks ---

class EitherRightFlatMapBenchmark extends Benchmark {
  EitherRightFlatMapBenchmark() : super('Either.right flatMap');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).flatMap((v) => Either<String, int>.right(v + 1)));
  }
}

class EitherLeftFlatMapBenchmark extends Benchmark {
  EitherLeftFlatMapBenchmark() : super('Either.left flatMap');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).flatMap((v) => Either<String, int>.right(v + 1)));
  }
}

// --- Either fold Benchmarks ---

class EitherRightFoldBenchmark extends Benchmark {
  EitherRightFoldBenchmark() : super('Either.right fold');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.right(i).fold((e) => 0, (v) => v + 1));
  }
}

class EitherLeftFoldBenchmark extends Benchmark {
  EitherLeftFoldBenchmark() : super('Either.left fold');

  @override
  void run(int i) {
    sinkBlackhole(Either<String, int>.left(i.toString()).fold((e) => i, (v) => v + 1));
  }
}

// --- Either Pipeline Benchmarks ---

class EitherRightPipelineBenchmark extends Benchmark {
  EitherRightPipelineBenchmark() : super('Either.right pipeline');

  @override
  void run(int i) {
    final result = Either<String, int>.right(i)
        .map((v) => v + 1)
        .flatMap((v) => Either<String, int>.right(v * 2))
        .fold((e) => 0, (v) => v - 1);
    sinkBlackhole(result);
  }
}

class EitherLeftPipelineBenchmark extends Benchmark {
  EitherLeftPipelineBenchmark() : super('Either.left pipeline');

  @override
  void run(int i) {
    final result = Either<String, int>.left(i.toString())
        .map((v) => v + 1)
        .flatMap((v) => Either<String, int>.right(v * 2))
        .fold((e) => i, (v) => v - 1);
    sinkBlackhole(result);
  }
}

class ExceptionSuccessPipelineBenchmark extends Benchmark {
  ExceptionSuccessPipelineBenchmark() : super('Exception success pipeline');

  @override
  void run(int i) {
    int result;
    try {
      int v1 = i;
      int v2 = v1 + 1;
      int v3 = v2 * 2;
      result = v3 - 1;
    } catch (e) {
      result = 0;
    }
    sinkBlackhole(result);
  }
}

class ExceptionErrorPipelineBenchmark extends Benchmark {
  ExceptionErrorPipelineBenchmark() : super('Exception error pipeline');

  @override
  void run(int i) {
    int result;
    try {
      throw Exception(i.toString());
      // ignore: dead_code
      int v1 = i;
      int v2 = v1 + 1;
      int v3 = v2 * 2;
      result = v3 - 1;
    } catch (e) {
      result = i;
    }
    sinkBlackhole(result);
  }
}

// --- fpdart Either Benchmarks ---

class FpdartEitherRightConstructionBenchmark extends Benchmark {
  FpdartEitherRightConstructionBenchmark() : super('fpdart Either.right Construction');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.right(i)); }
}

class FpdartEitherLeftConstructionBenchmark extends Benchmark {
  FpdartEitherLeftConstructionBenchmark() : super('fpdart Either.left Construction');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.left(i.toString())); }
}

class FpdartEitherRightMapBenchmark extends Benchmark {
  FpdartEitherRightMapBenchmark() : super('fpdart Either.right map');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.right(i).map((v) => v + 1)); }
}

class FpdartEitherLeftMapBenchmark extends Benchmark {
  FpdartEitherLeftMapBenchmark() : super('fpdart Either.left map');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.left(i.toString()).map((v) => v + 1)); }
}

class FpdartEitherRightMapLeftBenchmark extends Benchmark {
  FpdartEitherRightMapLeftBenchmark() : super('fpdart Either.right mapLeft');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.right(i).mapLeft((e) => '$e!')); }
}

class FpdartEitherLeftMapLeftBenchmark extends Benchmark {
  FpdartEitherLeftMapLeftBenchmark() : super('fpdart Either.left mapLeft');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.left(i.toString()).mapLeft((e) => '$e!')); }
}

class FpdartEitherRightBimapBenchmark extends Benchmark {
  FpdartEitherRightBimapBenchmark() : super('fpdart Either.right bimap');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.right(i).bimap((e) => '$e!', (v) => v + 1)); }
}

class FpdartEitherLeftBimapBenchmark extends Benchmark {
  FpdartEitherLeftBimapBenchmark() : super('fpdart Either.left bimap');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.left(i.toString()).bimap((e) => '$e!', (v) => v + 1)); }
}

class FpdartEitherRightFlatMapBenchmark extends Benchmark {
  FpdartEitherRightFlatMapBenchmark() : super('fpdart Either.right flatMap');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.right(i).flatMap((v) => fp.Either<String, int>.right(v + 1))); }
}

class FpdartEitherLeftFlatMapBenchmark extends Benchmark {
  FpdartEitherLeftFlatMapBenchmark() : super('fpdart Either.left flatMap');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.left(i.toString()).flatMap((v) => fp.Either<String, int>.right(v + 1))); }
}

class FpdartEitherRightFoldBenchmark extends Benchmark {
  FpdartEitherRightFoldBenchmark() : super('fpdart Either.right fold');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.right(i).match((e) => 0, (v) => v + 1)); }
}

class FpdartEitherLeftFoldBenchmark extends Benchmark {
  FpdartEitherLeftFoldBenchmark() : super('fpdart Either.left fold');
  @override void run(int i) { sinkBlackhole(fp.Either<String, int>.left(i.toString()).match((e) => i, (v) => v + 1)); }
}

class FpdartEitherRightPipelineBenchmark extends Benchmark {
  FpdartEitherRightPipelineBenchmark() : super('fpdart Either.right pipeline');

  @override
  void run(int i) {
    final result = fp.Either<String, int>.right(i)
        .map((v) => v + 1)
        .flatMap((v) => fp.Either<String, int>.right(v * 2))
        .match((e) => 0, (v) => v - 1);
    sinkBlackhole(result);
  }
}

class FpdartEitherLeftPipelineBenchmark extends Benchmark {
  FpdartEitherLeftPipelineBenchmark() : super('fpdart Either.left pipeline');

  @override
  void run(int i) {
    final result = fp.Either<String, int>.left(i.toString())
        .map((v) => v + 1)
        .flatMap((v) => fp.Either<String, int>.right(v * 2))
        .match((e) => i, (v) => v - 1);
    sinkBlackhole(result);
  }
}
