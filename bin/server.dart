import 'dart:io';
import 'dart:isolate';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart'; // Add this

// Internal Imports
import 'package:assignment_project_agri_pl/infrastructure/persistence/db_connection.dart';
import 'package:assignment_project_agri_pl/infrastructure/persistence/postgres_order_repository.dart';
import 'package:assignment_project_agri_pl/infrastructure/persistence/mongo_audit_service.dart'; // Add this
import 'package:assignment_project_agri_pl/infrastructure/concurrency/outbox_worker.dart';
import 'package:assignment_project_agri_pl/application/procurement_saga.dart';
import 'package:assignment_project_agri_pl/infrastructure/web/order_controller.dart';
import 'package:assignment_project_agri_pl/core/outbox/outbox_signal.dart';

void main(List<String> args) async {
  // 1. Initialize Postgres
  print('//Connecting to PostgreSQL...');
  final pgConnection = await DbConnection.create();

  // 2. Initialize MongoDB (P4: Polyglot Persistence)
  print('//Connecting to MongoDB...');
  final mongoDb = await Db.create('mongodb://localhost:27017/procurement_audit');
  await mongoDb.open();
  print(' Both Databases Connected.');

  // 3. Initialize Layers
  final repository = PostgresOrderRepository(pgConnection);
  final auditService = MongoAuditService(mongoDb);
  final saga = ProcurementSaga(repository, auditService);
  final orderController = OrderController(saga);

  // 4. Start Outbox Isolate
  final stopSignal = StopSignal();
  await Isolate.spawn(OutboxWorker.run, stopSignal);

  // 5. Setup Routes & Middleware
  final router = Router();
  router.get('/health', (Request rec) => Response.ok('{"status": "UP"}', headers: {'Content-Type': 'application/json'}));
  router.mount('/api', orderController.router);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  // 6. Start Server
  final server = await serve(handler, InternetAddress.anyIPv4, 8080);
  print(' Server live on http://${server.address.host}:${server.port}');
}