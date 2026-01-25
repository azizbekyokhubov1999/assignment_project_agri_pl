import 'package:prometheus_client/prometheus_client.dart';

// This is the source of truth for your metrics
final httpRequestsTotal = Counter(
  name: 'http_requests_total',
  help: 'Total number of HTTP requests.',
  labelNames: ['method', 'path', 'status'],
);