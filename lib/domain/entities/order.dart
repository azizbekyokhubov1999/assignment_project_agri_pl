import 'package:uuid/uuid.dart';
import 'order_status.dart';

class Order {
  final String id;
  final String supplierId;
  final double totalAmount;
  final List<String> items;
  final OrderStatus status;
  final int version; // For P4: Data Versioning / Optimistic Locking

  Order({
    String? id,
    required this.supplierId,
    required this.totalAmount,
    required this.items,
    this.status = OrderStatus.pending,
    this.version = 1,
  }) : id = id ?? const Uuid().v4();

  // Method to create a copy with changed values (Immutability)
  Order copyWith({OrderStatus? status, int? version}) {
    return Order(
      id: id,
      supplierId: supplierId,
      totalAmount: totalAmount,
      items: items,
      status: status ?? this.status,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'supplierId': supplierId,
    'totalAmount': totalAmount,
    'items': items,
    'status': status.name,
    'version': version,
  };
}