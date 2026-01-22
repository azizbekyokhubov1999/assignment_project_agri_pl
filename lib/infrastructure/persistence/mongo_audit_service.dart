import 'package:mongo_dart/mongo_dart.dart';
import '../../domain/services/audit_service.dart';
import '../../core/resilience/circuit_breaker.dart';

class MongoAuditService implements AuditService {
  final Db db;
  late DbCollection _collection;
  final _breaker = CircuitBreaker(threshold: 2); // Fails after 2 tries

  MongoAuditService(this.db) {
    _collection = db.collection('audit_logs');
  }

  @override
  Future<void> logAction(String orderId, String action, Map<String, dynamic> details) async {
    try {
      // We wrap the database call in the breaker
      await _breaker.call(() => _collection.insertOne({
        'orderId': orderId,
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      // If the breaker is OPEN or Mongo fails, we just log to console
      // but we DON'T throw the error so the Saga can continue!
      print(' [Audit Resiliency] MongoDB logging failed or blocked. System staying alive.');
    }
  }
}