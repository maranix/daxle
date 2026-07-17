import 'dart:developer';
import 'package:benchmark/benchmark_core.dart';
import 'package:daxle/daxle.dart';

// --- Memory Benchmarks ---
// These benchmarks are specifically designed to allocate heavily or retain objects.
// They are best run individually and observed in Dart DevTools.

class MemoryChurnOptionBenchmark extends Benchmark {
  MemoryChurnOptionBenchmark() : super('Memory Churn Option (GC Pressure)', iterations: 50000000);

  @override
  void run(int i) {
    // Generate lots of garbage
    final opt1 = Option<int>.some(i);
    final opt2 = opt1.map((v) => v + 1);
    final opt3 = opt2.flatMap((v) => Option<int>.some(v * 2));
    sinkBlackhole(opt3);
  }
}

class MemoryChurnNullableBenchmark extends Benchmark {
  MemoryChurnNullableBenchmark() : super('Memory Churn Nullable (GC Pressure)', iterations: 50000000);

  @override
  void run(int i) {
    // Generate lots of garbage (closures/ints might not generate as much as Option)
    int? v1 = i as int?;
    int? v2 = v1 != null ? v1 + 1 : null;
    int? v3 = v2 != null ? (v2 * 2) as int? : null;
    sinkBlackhole(v3);
  }
}

class MemoryRetentionEitherBenchmark extends Benchmark {
  final List<Either<String, int>> retained = [];
  
  MemoryRetentionEitherBenchmark() : super('Memory Retention Either (Heap Growth)', iterations: 10000000);

  @override
  void run(int i) {
    retained.add(Either<String, int>.right(i));
  }

  @override
  void teardown() {
    retained.clear(); // Clear so it can be GC'd eventually
    super.teardown();
  }
}

class MemoryRetentionExceptionBenchmark extends Benchmark {
  final List<Object> retained = [];
  
  MemoryRetentionExceptionBenchmark() : super('Memory Retention Exception (Heap Growth)', iterations: 10000000);

  @override
  void run(int i) {
    try {
      throw Exception(i.toString());
    } catch (e) {
      retained.add(e);
    }
  }

  @override
  void teardown() {
    retained.clear();
    super.teardown();
  }
}

void runMemoryBenchmarks() {
  print('========================================================================');
  print('Running Memory Benchmarks (Watch Dart DevTools)');
  print('========================================================================');
  
  final benchmarks = [
    MemoryChurnOptionBenchmark(),
    MemoryChurnNullableBenchmark(),
    MemoryRetentionEitherBenchmark(),
    MemoryRetentionExceptionBenchmark(),
  ];

  for (final benchmark in benchmarks) {
    debugger(message: 'Ready to run ${benchmark.name}. Connect DevTools now.');
    benchmark.measure();
  }
}
