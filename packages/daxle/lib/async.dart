/// Curated asynchronous and reactive toolkit for Daxle.
///
/// Exports:
/// - [Concurrency]: Fine-grained worker limits (`sequential`, `unbounded`, `bounded(limit)`), [Concurrency.dispatch], [Concurrency.process], and [Concurrency.createPool].
/// - [Pool], [PoolResource]: Robust asynchronous resource pooling from `package:pool`.
/// - **Stream Transformation Utilities**: Reactive stream operators from `package:stream_transform` (`debounce`, `throttle`, `audit`, `buffer`, `combineLatest`, `merge`, `switchMap`, `scan`, `tap`, `whereType`).
/// - **Async Utilities**: Primitives from `package:async` ([FutureGroup], [AsyncCache], [AsyncMemoizer], [StreamZip], [StreamQueue], [StreamGroup], [StreamSplitter]).
library;

// Concurrency strategy & task dispatching
export 'src/util/concurrency.dart';

// Package:pool - resource pooling & throttling
export 'package:pool/pool.dart' show Pool, PoolResource;

// Package:stream_transform - reactive stream transformation operators
export 'package:stream_transform/stream_transform.dart';

// Package:async - futures, streams, and async cache primitives
export 'package:async/async.dart'
    show
        FutureGroup,
        AsyncCache,
        AsyncMemoizer,
        StreamZip,
        StreamQueue,
        StreamGroup,
        StreamSplitter;
