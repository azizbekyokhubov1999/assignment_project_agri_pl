import 'package:postgres/postgres.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

class PostgresOrderRepository implements OrderRepository {
  final Connection connection;

  PostgresOrderRepository(this.connection);

  @override
  Future<void> saveOrder(Order order) async {
    // Advanced Reliability - Transactional Outbox Pattern
    // We wrap the Order insert and the Outbox insert in a single transaction.
    await connection.runTx((session) async {
      // 1. Insert the Order
      await session.execute(
        Sql.named('INSERT INTO orders (id, supplier_id, total_amount, items, status, version) '
            'VALUES (@id, @s_id, @amt, @items, @status, @v)'),
        parameters: {
          'id': order.id,
          's_id': order.supplierId,
          'amt': order.totalAmount,
          'items': order.items,
          'status': order.status.name,
          'version': order.version,
        },
      );

      // 2. Insert the Outbox Message (to be picked up by our background worker later)
      await session.execute(
        Sql.named('INSERT INTO outbox_messages (id, payload) VALUES (@id, @payload)'),
        parameters: {
          'id': order.id,
          'payload': order.toJson(),
        },
      );
    });
  }

  @override
  Future<Order?> getOrderById(String id) async {
    final result = await connection.execute(
      Sql.named('SELECT * FROM orders WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    // Map database columns back to our Domain Entity
    return Order(
      id: row[0] as String,
      supplierId: row[1] as String,
      totalAmount: (row[2] as num).toDouble(),
      items: (row[3] as List).cast<String>(),
      status: OrderStatus.values.byName(row[4] as String),
      version: row[5] as int,
    );
  }

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    // Data Versioning - We increment the version every time the status changes
    await connection.execute(
      Sql.named('UPDATE orders SET status = @status, version = version + 1 WHERE id = @id'),
      parameters: {
        'id': id,
        'status': status.name,
      },
    );
  }
}