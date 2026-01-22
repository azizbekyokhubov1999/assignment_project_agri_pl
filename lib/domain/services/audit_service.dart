abstract class AuditService {
  Future<void> logAction(String orderId, String action, Map<String, dynamic> details);
}