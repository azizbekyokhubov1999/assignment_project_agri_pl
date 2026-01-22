import 'package:assignment_project_agri_pl/core/resilience/circuit_breaker.dart';
import 'package:test/test.dart';

void main() {
  test('Circuit Breaker should stop trying after 2 failures', () async {
    // Create a breaker that trips after 2 fails
    final breaker = CircuitBreaker(threshold: 2);
    int callCount = 0;

    // A function that ALWAYS fails
    Future<void> failingAction() async {
      callCount++;
      throw Exception('DB Error');
    }

    // Attempt 1: Should fail and increment callCount
    try { await breaker.call(failingAction); } catch (_) {}

    // Attempt 2: Should fail and increment callCount
    try { await breaker.call(failingAction); } catch (_) {}

    // Attempt 3: The Circuit is now OPEN.
    // It should NOT call failingAction again.
    try { await breaker.call(failingAction); } catch (_) {}

    print('Total times we actually tried the DB: $callCount');
    expect(callCount, equals(2)); // It stopped at 2!
    expect(breaker.state, CircuitState.open);
  });
}