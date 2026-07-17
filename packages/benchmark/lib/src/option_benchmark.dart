import 'package:benchmark/benchmark_core.dart';
import 'package:daxle/daxle.dart';
import 'package:fpdart/fpdart.dart' as fp;

int _identity(int x) => x;
Option<int> _someIdentity(int x) => Option.some(x);

// --- Option Construction Benchmarks ---

class OptionSomeConstructionBenchmark extends Benchmark {
  OptionSomeConstructionBenchmark() : super('Option.some Construction');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i));
  }
}

class OptionNoneConstructionBenchmark extends Benchmark {
  OptionNoneConstructionBenchmark() : super('Option.none Construction');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.none());
  }
}

class NullableConstructionBenchmark extends Benchmark {
  NullableConstructionBenchmark() : super('Nullable (T?) Construction');

  @override
  void run(int i) {
    sinkBlackhole(i as int?);
  }
}

class NullConstructionBenchmark extends Benchmark {
  NullConstructionBenchmark() : super('Nullable (null) Construction');

  @override
  void run(int i) {
    sinkBlackhole(null as int?);
  }
}

// --- Option Identity Benchmarks (Abstraction Cost) ---

class OptionIdentityMapBenchmark extends Benchmark {
  OptionIdentityMapBenchmark() : super('Option.some map(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i).map(_identity));
  }
}

class OptionIdentityFlatMapBenchmark extends Benchmark {
  OptionIdentityFlatMapBenchmark() : super('Option.some flatMap(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i).flatMap(_someIdentity));
  }
}

class OptionIdentityFoldBenchmark extends Benchmark {
  OptionIdentityFoldBenchmark() : super('Option.some fold(identity)');
  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i).fold(() => 0, _identity));
  }
}

// --- Option map Benchmarks ---

class OptionSomeMapBenchmark extends Benchmark {
  OptionSomeMapBenchmark() : super('Option.some map');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i).map((v) => v + 1));
  }
}

class OptionNoneMapBenchmark extends Benchmark {
  OptionNoneMapBenchmark() : super('Option.none map');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.none().map((v) => v + i));
  }
}

class NullableMapBenchmark extends Benchmark {
  NullableMapBenchmark() : super('Nullable (T?) map equiv');

  @override
  void run(int i) {
    final int? opt = i;
    sinkBlackhole(opt != null ? opt + 1 : null);
  }
}

class NullMapBenchmark extends Benchmark {
  NullMapBenchmark() : super('Nullable (null) map equiv');

  @override
  void run(int i) {
    final int? opt = null;
    sinkBlackhole(opt != null ? opt + i : null);
  }
}

// --- Option flatMap Benchmarks ---

class OptionSomeFlatMapBenchmark extends Benchmark {
  OptionSomeFlatMapBenchmark() : super('Option.some flatMap');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i).flatMap((v) => Option<int>.some(v + 1)));
  }
}

class OptionNoneFlatMapBenchmark extends Benchmark {
  OptionNoneFlatMapBenchmark() : super('Option.none flatMap');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.none().flatMap((v) => Option<int>.some(v + i)));
  }
}

class NullableFlatMapBenchmark extends Benchmark {
  NullableFlatMapBenchmark() : super('Nullable (T?) flatMap equiv');

  @override
  void run(int i) {
    final int? opt = i;
    sinkBlackhole(opt != null ? (opt + 1) as int? : null);
  }
}

// --- Option fold Benchmarks ---

class OptionSomeFoldBenchmark extends Benchmark {
  OptionSomeFoldBenchmark() : super('Option.some fold');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i).fold(() => 0, (v) => v + 1));
  }
}

class OptionNoneFoldBenchmark extends Benchmark {
  OptionNoneFoldBenchmark() : super('Option.none fold');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.none().fold(() => i, (v) => v + 1));
  }
}

class NullableFoldBenchmark extends Benchmark {
  NullableFoldBenchmark() : super('Nullable (T?) fold equiv');

  @override
  void run(int i) {
    final int? opt = i;
    sinkBlackhole(opt != null ? opt + 1 : i);
  }
}

// --- Option isSome / isNone Benchmarks ---

class OptionIsSomeBenchmark extends Benchmark {
  OptionIsSomeBenchmark() : super('Option isSome');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.some(i).isSome);
  }
}

class OptionIsNoneBenchmark extends Benchmark {
  OptionIsNoneBenchmark() : super('Option isNone');

  @override
  void run(int i) {
    sinkBlackhole(Option<int>.none().isNone);
  }
}

class NullableIsNotNullBenchmark extends Benchmark {
  NullableIsNotNullBenchmark() : super('Nullable != null');

  @override
  void run(int i) {
    final int? opt = i;
    sinkBlackhole(opt != null);
  }
}

class NullableIsNullBenchmark extends Benchmark {
  NullableIsNullBenchmark() : super('Nullable == null');

  @override
  void run(int i) {
    final int? opt = null;
    sinkBlackhole(opt == null);
  }
}

// --- Option Pipeline Benchmarks ---

class OptionSomePipelineBenchmark extends Benchmark {
  OptionSomePipelineBenchmark() : super('Option.some pipeline');

  @override
  void run(int i) {
    final result = Option<int>.some(i)
        .map((v) => v + 1)
        .flatMap((v) => Option<int>.some(v * 2))
        .fold(() => 0, (v) => v - 1);
    sinkBlackhole(result);
  }
}

class OptionNonePipelineBenchmark extends Benchmark {
  OptionNonePipelineBenchmark() : super('Option.none pipeline');

  @override
  void run(int i) {
    final result = Option<int>.none()
        .map((v) => v + 1)
        .flatMap((v) => Option<int>.some(v * 2))
        .fold(() => i, (v) => v - 1);
    sinkBlackhole(result);
  }
}

class NullablePipelineBenchmark extends Benchmark {
  NullablePipelineBenchmark() : super('Nullable pipeline equiv');

  @override
  void run(int i) {
    int? v1 = i as int?;
    int? v2 = v1 != null ? v1 + 1 : null;
    int? v3 = v2 != null ? (v2 * 2) as int? : null;
    int result = v3 != null ? v3 - 1 : 0;
    sinkBlackhole(result);
  }
}

class NullPipelineBenchmark extends Benchmark {
  NullPipelineBenchmark() : super('Null pipeline equiv');

  @override
  void run(int i) {
    int? v1 = null as int?;
    int? v2 = v1 != null ? v1 + 1 : null;
    int? v3 = v2 != null ? (v2 * 2) as int? : null;
    int result = v3 != null ? v3 - 1 : i;
    sinkBlackhole(result);
  }
}

// --- fpdart Option Benchmarks ---

class FpdartOptionSomeConstructionBenchmark extends Benchmark {
  FpdartOptionSomeConstructionBenchmark() : super('fpdart Option.of');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.of(i)); }
}

class FpdartOptionNoneConstructionBenchmark extends Benchmark {
  FpdartOptionNoneConstructionBenchmark() : super('fpdart Option.none');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.none()); }
}

class FpdartOptionSomeMapBenchmark extends Benchmark {
  FpdartOptionSomeMapBenchmark() : super('fpdart Option.of map');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.of(i).map((v) => v + 1)); }
}

class FpdartOptionNoneMapBenchmark extends Benchmark {
  FpdartOptionNoneMapBenchmark() : super('fpdart Option.none map');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.none().map((v) => v + i)); }
}

class FpdartOptionSomeFlatMapBenchmark extends Benchmark {
  FpdartOptionSomeFlatMapBenchmark() : super('fpdart Option.of flatMap');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.of(i).flatMap((v) => fp.Option<int>.of(v + 1))); }
}

class FpdartOptionNoneFlatMapBenchmark extends Benchmark {
  FpdartOptionNoneFlatMapBenchmark() : super('fpdart Option.none flatMap');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.none().flatMap((v) => fp.Option<int>.of(v + i))); }
}

class FpdartOptionSomeFoldBenchmark extends Benchmark {
  FpdartOptionSomeFoldBenchmark() : super('fpdart Option.of fold');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.of(i).match(() => 0, (v) => v + 1)); }
}

class FpdartOptionNoneFoldBenchmark extends Benchmark {
  FpdartOptionNoneFoldBenchmark() : super('fpdart Option.none fold');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.none().match(() => i, (v) => v + 1)); }
}

class FpdartOptionIsSomeBenchmark extends Benchmark {
  FpdartOptionIsSomeBenchmark() : super('fpdart Option.of isSome');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.of(i).isSome()); }
}

class FpdartOptionIsNoneBenchmark extends Benchmark {
  FpdartOptionIsNoneBenchmark() : super('fpdart Option.none isNone');
  @override void run(int i) { sinkBlackhole(fp.Option<int>.none().isNone()); }
}

class FpdartOptionSomePipelineBenchmark extends Benchmark {
  FpdartOptionSomePipelineBenchmark() : super('fpdart Option.of pipeline');

  @override
  void run(int i) {
    final result = fp.Option<int>.of(i)
        .map((v) => v + 1)
        .flatMap((v) => fp.Option<int>.of(v * 2))
        .match(() => 0, (v) => v - 1);
    sinkBlackhole(result);
  }
}

class FpdartOptionNonePipelineBenchmark extends Benchmark {
  FpdartOptionNonePipelineBenchmark() : super('fpdart Option.none pipeline');

  @override
  void run(int i) {
    final result = fp.Option<int>.none()
        .map((v) => v + 1)
        .flatMap((v) => fp.Option<int>.of(v * 2))
        .match(() => i, (v) => v - 1);
    sinkBlackhole(result);
  }
}
