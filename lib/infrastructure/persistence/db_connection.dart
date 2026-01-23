import 'package:postgres/postgres.dart';
import 'dart:io';

class DbConnection {
  static Future<Connection> create() async {

    final String dbHost = Platform.environment['DB_HOST'] ?? 'localhost';

    return await Connection.open(
      Endpoint(
        host: dbHost,
        database: 'procurement_sql',
        username: 'user',
        password: 'password',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }
}