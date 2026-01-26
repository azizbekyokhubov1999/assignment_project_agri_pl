import 'package:prometheus_client/prometheus_client.dart';

// This is the source of truth for your metrics
final httpRequestsTotal = Counter(
  name: 'http_requests_total',
  help: 'Total number of HTTP requests.',
  labelNames: ['method', 'path', 'status'],
);


class CustomMetrics {
  static final ordersCreated = Counter(
      name: 'agri_orders_created_total',
      help: 'Total number of procurement orders created',
      labelNames: ['supplier', 'product_category']
  );

  // Saga pattern Transaction holatlari un
  static final sagaTransactions = Counter(
      name: 'agri_saga_transactions_total',
      help: 'Total number of saga transactions',
      labelNames: ['status', 'step']
  );

  //Database operation duration un
  static final dbOperationDuration = Histogram(
      name: 'agri_db_operation_duration_seconds',
      help: 'Database operation duration in seconds',
      labelNames: ['operation', 'database'], // operation: insert/update/delete
      buckets: [0.1, 0.5, 1.0, 2.0, 5.0]
  );

  //Active orders un
  static final activeOrders = Gauge(
      name: 'agri_active_orders',
      help: 'Number of currently active orders',
      labelNames: ['status'] // pending/processing/completed
  );

  //Audit log entries un
  static final auditLogsWritten = Counter(
      name: 'agri_audit_logs_written_total',
      help: 'Total audit log entries written to MongoDB',
      labelNames: ['action_type']
  );
}