/// Operability - A shared signal to gracefully shut down
/// background workers (Isolates) across the system.
class StopSignal {
  bool shouldStop = false;

  void trigger() {
    shouldStop = true;
  }
}