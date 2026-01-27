import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../application/procurement_saga.dart';
import '../../domain/entities/order.dart';
import '../monitoring/custom_metrics.dart';
import '../monitoring/custom_metrics.dart'; // Make sure this import is there



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
        saga.execute(newOrder);


        CustomMetrics.ordersCreated.labels([
          payload['supplierId'].toString(),
          'general'
        ]).inc();

        CustomMetrics.ordersPlaced.labels(['General']).inc();
        CustomMetrics.pendingOrders.inc();

        httpRequestsTotal.labels(['POST', '/orders', '200']).inc();

        return Response.ok(
          jsonEncode({
            'message': 'Order processing started',
            'orderId': newOrder.id,
            'status': 'Pending'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        httpRequestsTotal.labels(['POST', '/orders', '500']).inc();
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    return router;
  }
}