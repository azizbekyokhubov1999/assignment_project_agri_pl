import 'dart:async';
import 'package:postgres/postgres.dart';
import '../persistence/db_connection.dart';
import '../../core/outbox/outbox_signal.dart';

class OutboxWorker {
  /// This is the entry point for the Isolate.
  /// It must be a top-level function or a static method.
  static Future<void> run(StopSignal signal) async {
    print('[Outbox Isolate] Worker started on a separate thread.');

    // We create a new connection for this Isolate
    // because Isolates cannot share memory/objects with the main thread.
    final connection = await DbConnection.create();

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (signal.shouldStop) {
        print('[Outbox Isolate] Shutting down...');
        await connection.close();
        timer.cancel();
        return;
      }

      try {
        // 1. Fetch unprocessed messages (P3: Advanced Reliability)
        final result = await connection.execute(
            'SELECT id, payload FROM outbox_messages WHERE processed = false LIMIT 5'
        );

        if (result.isEmpty) return;

        for (final row in result) {
          final id = row[0] as String;
          final payload = row[1] as Map<String, dynamic>;

          print('[Outbox Isolate] RELAYING MESSAGE: Order $id for Supplier ${payload['supplierId']}');

          // 2. Mark as processed in the database
          await connection.execute(
            Sql.named('UPDATE outbox_messages SET processed = true WHERE id = @id'),
            parameters: {'id': id},
          );
        }
      } catch (e) {
        print('[Outbox Isolate] Error: $e');
      }
    });
  }
}

