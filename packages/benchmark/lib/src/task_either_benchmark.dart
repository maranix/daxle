import 'package:benchmark/benchmark_core.dart';
import 'package:daxle/daxle.dart';
import 'package:fpdart/fpdart.dart' as fp;

int _identity(int x) => x;
TaskEither<String, int> _rightIdentity(int x) => TaskEither.right(x);

// --- TaskEither Construction Benchmarks ---

class TaskEitherRightConstructionBenchmark extends AsyncBenchmark {
  TaskEitherRightConstructionBenchmark() : super('TaskEither.right Construction');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).run());
  }
}

class TaskEitherLeftConstructionBenchmark extends AsyncBenchmark {
  TaskEitherLeftConstructionBenchmark() : super('TaskEither.left Construction');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).run());
  }
}

class FutureSuccessConstructionBenchmark extends AsyncBenchmark {
  FutureSuccessConstructionBenchmark() : super('Future.value Construction');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await Future.value(i));
  }
}

class FutureErrorConstructionBenchmark extends AsyncBenchmark {
  FutureErrorConstructionBenchmark() : super('Future.error Construction');

  @override
  Future<void> run(int i) async {
    try {
      await Future.error(i.toString());
    } catch (e) {
      sinkBlackhole(e);
    }
  }
}

// --- TaskEither Identity Benchmarks (Abstraction Cost) ---

class TaskEitherRightIdentityMapBenchmark extends AsyncBenchmark {
  TaskEitherRightIdentityMapBenchmark() : super('TaskEither.right map(identity)');
  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).map(_identity).run());
  }
}

class TaskEitherLeftIdentityMapBenchmark extends AsyncBenchmark {
  TaskEitherLeftIdentityMapBenchmark() : super('TaskEither.left map(identity)');
  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).map(_identity).run());
  }
}

class TaskEitherRightIdentityFlatMapBenchmark extends AsyncBenchmark {
  TaskEitherRightIdentityFlatMapBenchmark() : super('TaskEither.right flatMap(identity)');
  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).flatMap(_rightIdentity).run());
  }
}

class TaskEitherLeftIdentityFlatMapBenchmark extends AsyncBenchmark {
  TaskEitherLeftIdentityFlatMapBenchmark() : super('TaskEither.left flatMap(identity)');
  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).flatMap(_rightIdentity).run());
  }
}

// --- TaskEither map Benchmarks ---

class TaskEitherRightMapBenchmark extends AsyncBenchmark {
  TaskEitherRightMapBenchmark() : super('TaskEither.right map');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).map((v) => v + 1).run());
  }
}

class TaskEitherLeftMapBenchmark extends AsyncBenchmark {
  TaskEitherLeftMapBenchmark() : super('TaskEither.left map');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).map((v) => v + 1).run());
  }
}

class FutureSuccessMapBenchmark extends AsyncBenchmark {
  FutureSuccessMapBenchmark() : super('Future.then (success)');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await Future.value(i).then((v) => v + 1));
  }
}

// --- TaskEither mapLeft Benchmarks ---

class TaskEitherRightMapLeftBenchmark extends AsyncBenchmark {
  TaskEitherRightMapLeftBenchmark() : super('TaskEither.right mapLeft');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).mapLeft((e) => '$e!').run());
  }
}

class TaskEitherLeftMapLeftBenchmark extends AsyncBenchmark {
  TaskEitherLeftMapLeftBenchmark() : super('TaskEither.left mapLeft');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).mapLeft((e) => '$e!').run());
  }
}

// --- TaskEither bimap Benchmarks ---

class TaskEitherRightBimapBenchmark extends AsyncBenchmark {
  TaskEitherRightBimapBenchmark() : super('TaskEither.right bimap');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).bimap((e) => '$e!', (v) => v + 1).run());
  }
}

// --- TaskEither flatMap Benchmarks ---

class TaskEitherRightFlatMapBenchmark extends AsyncBenchmark {
  TaskEitherRightFlatMapBenchmark() : super('TaskEither.right flatMap');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).flatMap((v) => TaskEither<String, int>.right(v + 1)).run());
  }
}

class TaskEitherLeftFlatMapBenchmark extends AsyncBenchmark {
  TaskEitherLeftFlatMapBenchmark() : super('TaskEither.left flatMap');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).flatMap((v) => TaskEither<String, int>.right(v + 1)).run());
  }
}

class FutureSuccessFlatMapBenchmark extends AsyncBenchmark {
  FutureSuccessFlatMapBenchmark() : super('Future flatMap (success)');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await Future.value(i).then((v) => Future.value(v + 1)));
  }
}

// --- TaskEither recover (orElse) Benchmarks ---

class TaskEitherLeftOrElseBenchmark extends AsyncBenchmark {
  TaskEitherLeftOrElseBenchmark() : super('TaskEither.left orElse');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).orElse((e) => TaskEither<String, int>.right(i)).run());
  }
}

// --- TaskEither ensure Benchmarks ---

class TaskEitherRightEnsureBenchmark extends AsyncBenchmark {
  TaskEitherRightEnsureBenchmark() : super('TaskEither.right ensure (pass)');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).ensure((v) => v >= 0, () => 'error').run());
  }
}

// --- TaskEither tap / tapLeft Benchmarks ---

class TaskEitherRightTapBenchmark extends AsyncBenchmark {
  TaskEitherRightTapBenchmark() : super('TaskEither.right tap');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.right(i).tap((v) => sinkBlackhole(v)).run());
  }
}

class TaskEitherLeftTapLeftBenchmark extends AsyncBenchmark {
  TaskEitherLeftTapLeftBenchmark() : super('TaskEither.left tapLeft');

  @override
  Future<void> run(int i) async {
    sinkBlackhole(await TaskEither<String, int>.left(i.toString()).tapLeft((e) => sinkBlackhole(e)).run());
  }
}

// --- TaskEither sequence / traverse Benchmarks ---
// Reduced iterations for sequence/traverse since they do more work per run.

class TaskEitherSequenceBenchmark extends AsyncBenchmark {
  TaskEitherSequenceBenchmark() : super('TaskEither sequence (10 items)', iterations: 10000);

  @override
  Future<void> run(int i) async {
    final List<TaskEither<String, int>> tasks = List.generate(10, (j) => TaskEither<String, int>.right(i + j));
    sinkBlackhole(await TaskEither.sequence(tasks).run());
  }
}

class TaskEitherTraverseBenchmark extends AsyncBenchmark {
  TaskEitherTraverseBenchmark() : super('TaskEither traverse (10 items)', iterations: 10000);

  @override
  Future<void> run(int i) async {
    final List<int> items = List.generate(10, (j) => i + j);
    sinkBlackhole(await TaskEither.traverse(items, (int j) => TaskEither<String, int>.right(j)).run());
  }
}

// --- TaskEither Composition Pipeline ---

class TaskEitherPipelineBenchmark extends AsyncBenchmark {
  TaskEitherPipelineBenchmark() : super('TaskEither pipeline (success)', iterations: 10000);

  @override
  Future<void> run(int i) async {
    final result = await TaskEither<String, int>.right(i)
        .map((v) => v + 1)
        .flatMap((v) => TaskEither<String, int>.right(v * 2))
        .orElse((e) => TaskEither<String, int>.right(0))
        .fold((l) => 0, (r) => r - 1);
    sinkBlackhole(result);
  }
}

class FuturePipelineBenchmark extends AsyncBenchmark {
  FuturePipelineBenchmark() : super('Future pipeline (success)', iterations: 10000);

  @override
  Future<void> run(int i) async {
    try {
      final v1 = await Future.value(i);
      final v2 = v1 + 1;
      final v3 = await Future.value(v2 * 2);
      sinkBlackhole(v3 - 1);
    } catch (e) {
      sinkBlackhole(0);
    }
  }
}

// --- fpdart TaskEither Benchmarks ---

class FpdartTaskEitherRightConstructionBenchmark extends AsyncBenchmark {
  FpdartTaskEitherRightConstructionBenchmark() : super('fpdart TaskEither.of Construction');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.of(i).run()); }
}

class FpdartTaskEitherLeftConstructionBenchmark extends AsyncBenchmark {
  FpdartTaskEitherLeftConstructionBenchmark() : super('fpdart TaskEither.left Construction');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.left(i.toString()).run()); }
}

class FpdartTaskEitherRightMapBenchmark extends AsyncBenchmark {
  FpdartTaskEitherRightMapBenchmark() : super('fpdart TaskEither.of map');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.of(i).map((v) => v + 1).run()); }
}

class FpdartTaskEitherLeftMapBenchmark extends AsyncBenchmark {
  FpdartTaskEitherLeftMapBenchmark() : super('fpdart TaskEither.left map');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.left(i.toString()).map((v) => v + 1).run()); }
}

class FpdartTaskEitherRightMapLeftBenchmark extends AsyncBenchmark {
  FpdartTaskEitherRightMapLeftBenchmark() : super('fpdart TaskEither.of mapLeft');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.of(i).mapLeft((e) => '$e!').run()); }
}

class FpdartTaskEitherLeftMapLeftBenchmark extends AsyncBenchmark {
  FpdartTaskEitherLeftMapLeftBenchmark() : super('fpdart TaskEither.left mapLeft');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.left(i.toString()).mapLeft((e) => '$e!').run()); }
}

class FpdartTaskEitherRightBimapBenchmark extends AsyncBenchmark {
  FpdartTaskEitherRightBimapBenchmark() : super('fpdart TaskEither.of bimap');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.of(i).bimap((e) => '$e!', (v) => v + 1).run()); }
}

class FpdartTaskEitherRightFlatMapBenchmark extends AsyncBenchmark {
  FpdartTaskEitherRightFlatMapBenchmark() : super('fpdart TaskEither.of flatMap');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.of(i).flatMap((v) => fp.TaskEither<String, int>.of(v + 1)).run()); }
}

class FpdartTaskEitherLeftFlatMapBenchmark extends AsyncBenchmark {
  FpdartTaskEitherLeftFlatMapBenchmark() : super('fpdart TaskEither.left flatMap');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.left(i.toString()).flatMap((v) => fp.TaskEither<String, int>.of(v + 1)).run()); }
}

class FpdartTaskEitherLeftOrElseBenchmark extends AsyncBenchmark {
  FpdartTaskEitherLeftOrElseBenchmark() : super('fpdart TaskEither.left orElse');
  @override Future<void> run(int i) async { sinkBlackhole(await fp.TaskEither<String, int>.left(i.toString()).alt(() => fp.TaskEither<String, int>.of(i)).run()); }
}

class FpdartTaskEitherPipelineBenchmark extends AsyncBenchmark {
  FpdartTaskEitherPipelineBenchmark() : super('fpdart TaskEither pipeline (success)', iterations: 10000);

  @override
  Future<void> run(int i) async {
    final result = await fp.TaskEither<String, int>.of(i)
        .map((v) => v + 1)
        .flatMap((v) => fp.TaskEither<String, int>.of(v * 2))
        .alt(() => fp.TaskEither<String, int>.of(0))
        .match((l) => 0, (r) => r - 1)
        .run();
    sinkBlackhole(result);
  }
}
