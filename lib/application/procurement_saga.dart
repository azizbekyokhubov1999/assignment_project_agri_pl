import '../domain/entities/order.dart';
import '../domain/entities/order_status.dart';
import '../domain/repositories/order_repository.dart';

class ProcurementSaga {
  final OrderRepository repository;

  ProcurementSaga(this.repository);

  /// This function manages the multi-step "workflow" of an order.
  Future<void> execute(Order order) async {
    try {
      print('🛠️ [Saga] Starting workflow for Order: ${order.id}');

      // Step 1: Persist the initial order (Status: Pending)
      // This also triggers our Transactional Outbox!
      await repository.saveOrder(order);
      print(' [Saga] Step 1: Order saved to Postgres.');

      // Step 2: Simulate an Inventory Check
      // In a real system, this might be a call to a separate Inventory microservice.
      bool inventoryAvailable = _mockInventoryCheck(order);

      if (!inventoryAvailable) {
        throw Exception('INSUFFICIENT_STOCK');
      }

      await repository.updateOrderStatus(order.id, OrderStatus.reserved);
      print(' [Saga] Step 2: Inventory reserved successfully.');

      // Step 3: Finalize Order
      // Here you would normally trigger the Payment gateway.
      await repository.updateOrderStatus(order.id, OrderStatus.completed);
      print('🏁 [Saga] Workflow complete. Order status: COMPLETED');

    } catch (e) {
      print('[Saga] Error detected: $e');
      await _compensate(order.id);
    }
  }

  /// P3: The Compensating Transaction (The "Undo" logic)
  Future<void> _compensate(String orderId) async {
    print('🔄 [Saga] INITIATING COMPENSATION: Rolling back Order $orderId');
    // We update the status to 'compensated' so the business knows this failed
    // and was safely rolled back.
    await repository.updateOrderStatus(orderId, OrderStatus.compensated);
  }

  /// A mock check: Orders over $1,000,000 fail due to "stock" or "credit" limits.
  bool _mockInventoryCheck(Order order) {
    return order.totalAmount < 1000000;
  }
}