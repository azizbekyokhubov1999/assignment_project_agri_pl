enum CircuitState { closed, open, halfOpen }

class CircuitBreaker {
  CircuitState state = CircuitState.closed;
  int failureCount = 0;
  final int threshold; // Number of failures
  final Duration resetTimeout;
  DateTime? _lastFailureTime;

  CircuitBreaker({this.threshold = 3, this.resetTimeout = const Duration(seconds: 30)});

  Future<T> call<T>(Future<T> Function() action) async {
    // 1. Check if we should try to "close" the circuit again
    if (state == CircuitState.open && _lastFailureTime != null) {
      if (DateTime.now().difference(_lastFailureTime!) > resetTimeout) {
        print(' [CircuitBreaker] Testing connection (Half-Open)...');
        state = CircuitState.halfOpen;
      }
    }

    // 2. If open, don't even try the action
    if (state == CircuitState.open) {
      throw Exception('Circuit is OPEN. Action blocked for resilience.');
    }

    try {
      T result = await action();
      // If successful, reset
      if (state == CircuitState.halfOpen) {
        print(' [CircuitBreaker] Service recovered. Closing circuit.');
      }
      failureCount = 0;
      state = CircuitState.closed;
      return result;
    } catch (e) {
      failureCount++;
      _lastFailureTime = DateTime.now();

      if (failureCount >= threshold) {
        state = CircuitState.open;
        print(' [CircuitBreaker] Threshold reached. Circuit is now OPEN.');
      }
      rethrow;
    }
  }
}