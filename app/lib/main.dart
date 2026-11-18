import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'services/api_client.dart';
import 'services/app_keys.dart';
import 'services/session.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init(); // loads the saved server address and login token
  ApiClient.instance.onUnauthorized = Session.instance.handleExpired;
  runApp(const StockwiseApp());
}

class StockwiseApp extends StatelessWidget {
  const StockwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stockwise',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      home: const AuthGate(),
    );
  }
}
