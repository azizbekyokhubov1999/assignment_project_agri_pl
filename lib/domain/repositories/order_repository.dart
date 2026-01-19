import '../entities/order.dart';
import '../entities/order_status.dart';

abstract class OrderRepository {
  Future<void> saveOrder(Order order);
  Future<Order?> getOrderById(String id);
  Future<void> updateOrderStatus(String id, OrderStatus status);
}