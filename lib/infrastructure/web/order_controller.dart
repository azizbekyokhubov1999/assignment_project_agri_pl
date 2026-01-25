import 'dart:convert';
import 'package:prometheus_client/format.dart' as format;
import 'package:prometheus_client/prometheus_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../application/procurement_saga.dart';
import '../../domain/entities/order.dart';
import '../monitoring/metrics.dart';



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
        // to keep latency low
        saga.execute(newOrder);

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
    router.get('/metrics', (Request request) async {
      final metrics = await CollectorRegistry.defaultRegistry.collectMetricFamilySamples();
      final buffer = StringBuffer();
      format.write004(buffer, metrics);

      return Response.ok(
          buffer.toString(),
          headers: {'Content-Type': format.contentType}
      );
    });
    return router;
  }
}