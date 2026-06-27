import 'dart:async';
import 'package:daxle/daxle.dart';

// Domain model
class Transaction {
  final String sku;
  final int quantity;
  final double price;

  const Transaction(this.sku, this.quantity, this.price);

  double get totalRevenue => quantity * price;

  @override
  String toString() =>
      'Transaction($sku, qty: $quantity, price: \$$price, rev: \$${totalRevenue.toStringAsFixed(2)})';
}

Future<void> runPipelinesDemo() async {
  print('=== Scenario 3: Lazy Operations Pipelines (Sync & Async) ===');

  // ---------------------------------------------------------------------------
  // 1. Sync Pipeline: Transaction Line Processing
  // ---------------------------------------------------------------------------
  print('\nProcessing single transaction record...');

  final rawLogLine = 'SKU-7789, 5, 29.99';

  final syncProcessingPipeline = Pipeline(() => rawLogLine)
      .pipe((line) {
        // Parse CSV
        final parts = line.split(',');
        if (parts.length != 3) {
          throw FormatException('Invalid record length: ${parts.length}');
        }
        return parts;
      })
      .pipe((parts) {
        // Convert and construct
        final sku = parts[0].trim();
        final qty = int.parse(parts[1].trim());
        final price = double.parse(parts[2].trim());
        return Transaction(sku, qty, price);
      })
      .tap((tx) {
        // Observational telemetry / logging
        print('  [Pipeline Telemetry] Transaction processed: $tx');
      })
      .pipe((tx) {
        // Apply 10% tax adjustment
        return Transaction(tx.sku, tx.quantity, tx.price * 1.10);
      })
      .recover((error, stackTrace) {
        // Recover from parsing errors
        print(
          '  [Pipeline Recovery] Failed parsing log. Emitting fallback transaction.',
        );
        return const Transaction('FALLBACK', 0, 0.0);
      })
      .finalize(() {
        // Resource cleanup
        print('  [Pipeline Cleanup] Transaction processing step complete.');
      });

  print('Evaluating pipeline (lazy execution starts now)...');
  final finalTx = syncProcessingPipeline.run();
  print('Resulting Transaction (after tax): $finalTx');

  // ---------------------------------------------------------------------------
  // 2. Async Pipeline: Concurrent Database Zipping
  // ---------------------------------------------------------------------------
  print('\nStarting concurrent database zipping query...');

  // Mock DB query tasks returning Futures
  Future<String> fetchUserConfig() async {
    await Future.delayed(const Duration(milliseconds: 60));
    return 'Theme: Dark, Locale: EN-US';
  }

  Future<int> fetchNotificationCount() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return 12;
  }

  final configPipeline = AsyncPipeline(() => fetchUserConfig());
  final notifyPipeline = AsyncPipeline(() => fetchNotificationCount());

  // Zip pipelines to run concurrently
  final dashboardPipeline = configPipeline
      .zip(notifyPipeline, (config, notificationsCount) {
        return 'DashboardData(Config: $config, New Alerts: $notificationsCount)';
      })
      .finalize(() {
        print('  [Async Pipeline Cleanup] Concurrency resources released.');
      });

  print('Evaluating async pipeline...');
  final dashboardData = await dashboardPipeline.run();
  print('Result: $dashboardData');

  print('\n--------------------------------------------------');
}
