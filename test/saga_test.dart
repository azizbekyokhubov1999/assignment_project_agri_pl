import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:assignment_project_agri_pl/application/procurement_saga.dart';
import 'package:assignment_project_agri_pl/domain/entities/order.dart';
import 'package:assignment_project_agri_pl/domain/entities/order_status.dart';
import 'mocks.dart';

// 1. Create a "Fake" for types that mocktail needs to handle as 'any()'
class OrderFake extends Fake implements Order {}

void main() {
  late MockOrderRepository mockRepo;
  late MockAuditService mockAudit;
  late ProcurementSaga saga;

  // 2. This runs ONCE before all tests in this file
  setUpAll(() {
    registerFallbackValue(OrderFake());
    registerFallbackValue(OrderStatus.pending);
  });

  setUp(() {
    mockRepo = MockOrderRepository();
    mockAudit = MockAuditService(); // Initialize

    // Inject both mocks
    saga = ProcurementSaga(mockRepo, mockAudit);

    // Setup default mock behavior for Audit
    when(() => mockAudit.logAction(any(), any(), any())).thenAnswer((_) async => {});
  });

  test('Saga should complete successfully for normal amounts', () async {
    final order = Order(supplierId: 'test', totalAmount: 500.0, items: ['A']);

    // Setup mock responses
    when(() => mockRepo.saveOrder(any())).thenAnswer((_) async => {});
    when(() => mockRepo.updateOrderStatus(any(), any())).thenAnswer((_) async => {});

    await saga.execute(order);

    // Verify successful completion
    verify(() => mockRepo.updateOrderStatus(order.id, OrderStatus.completed)).called(1);
  });

  test('Saga should trigger Compensation when amount is too high', () async {
    final highValueOrder = Order(supplierId: 'rich', totalAmount: 2000000.0, items: ['Gold']);

    when(() => mockRepo.saveOrder(any())).thenAnswer((_) async => {});
    when(() => mockRepo.updateOrderStatus(any(), any())).thenAnswer((_) async => {});

    await saga.execute(highValueOrder);

    // Verify compensation was triggered
    verify(() => mockRepo.updateOrderStatus(highValueOrder.id, OrderStatus.compensated)).called(1);
  });
}