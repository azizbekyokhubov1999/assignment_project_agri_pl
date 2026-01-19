import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../application/procurement_saga.dart';
import '../../domain/entities/order.dart';

class OrderController {
  final ProcurementSaga saga;

  OrderController(this.saga);

  Router get router {
    final router = Router();

    // Endpoint: POST /orders
    router.post('/orders', (Request request) async {
      try {
        final payload = jsonDecode(await request.readAsString());

        final newOrder = Order(
          supplierId: payload['supplierId'],
          totalAmount: (payload['totalAmount'] as num).toDouble(),
          items: (payload['items'] as List).cast<String>(),
        );

        // We trigger the Saga (it runs asynchronously)
        // We don't await the WHOLE saga before responding to the user
        // to keep latency low (P4).
        saga.execute(newOrder);

        return Response.ok(
          jsonEncode({
            'message': 'Order processing started',
            'orderId': newOrder.id,
            'status': 'Pending'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    return router;
  }
}