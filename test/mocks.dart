import 'package:mocktail/mocktail.dart';
import 'package:assignment_project_agri_pl/domain/repositories/order_repository.dart';
import 'package:assignment_project_agri_pl/domain/entities/order.dart';
import 'package:assignment_project_agri_pl/domain/services/audit_service.dart';

// This allows us to "pretend" to be the database
class MockOrderRepository extends Mock implements OrderRepository {}
class MockAuditService extends Mock implements AuditService {}