/// Reliability Pattern - A generic interface for anything
/// that can be sent through the Transactional Outbox.
abstract class OutboxEvent {
  String get id;
  Map<String, dynamic> toJson();
  DateTime get createdAt;
}