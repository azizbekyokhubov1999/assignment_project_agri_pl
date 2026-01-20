import 'dart:io';
import 'dart:isolate';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';


import 'package:assignment_project_agri_pl/infrastructure/persistence/db_connection.dart';
import 'package:assignment_project_agri_pl/infrastructure/persistence/postgres_order_repository.dart';
import 'package:assignment_project_agri_pl/infrastructure/concurrency/outbox_worker.dart';
import 'package:assignment_project_agri_pl/application/procurement_saga.dart';
import 'package:assignment_project_agri_pl/infrastructure/web/order_controller.dart';
import 'package:assignment_project_agri_pl/core/outbox/outbox_signal.dart';

void main(List<String> args) async {
  // Initialize Database Connection
  print(' Connecting to PostgreSQL...');
  final connection = await DbConnection.create();
  print(' Database Connected.');

  //  Initialize Layers (Dependency Injection)
  final repository = PostgresOrderRepository(connection);
  final saga = ProcurementSaga(repository);
  final orderController = OrderController(saga);

  //  Start the Outbox Relay in a separate Isolate
  // This satisfies the Concurrency requirement.
  final stopSignal = StopSignal();
  await Isolate.spawn(OutboxWorker.run, stopSignal);

  //  Define Routes
  final router = Router();

  //  Operability - Health Check Endpoint
  router.get('/health', (Request rec) {
    return Response.ok('{"status": "UP", "database": "CONNECTED"}',
        headers: {'Content-Type': 'application/json'});
  });

  // Mount our Order API
  router.mount('/api', orderController.router);

  // Setup Middleware Observability/Logging
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  //  Start the Server
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);

  print(' Procurement Backend running on http://${server.address.host}:${server.port}');
}