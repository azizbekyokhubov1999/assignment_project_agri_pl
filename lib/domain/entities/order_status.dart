enum OrderStatus {
  pending,      // Order created, but inventory not reserved yet
  reserved,     // Inventory confirmed
  completed,    // Payment successful
  failed,       // Something went wrong
  compensated   // Saga rolled back (Undo successful)
}