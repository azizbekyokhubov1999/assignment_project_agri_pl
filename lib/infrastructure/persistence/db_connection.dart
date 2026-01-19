import 'package:postgres/postgres.dart';

class DbConnection {
  static Future<Connection> create() async {
    return await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'procurement_sql',
        username: 'user',
        password: 'password',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }
}