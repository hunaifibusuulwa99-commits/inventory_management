import 'package:flutter/material.dart';

import '../services/session.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

/// Decides what to show: splash (checking login), login, or the main app.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    Session.instance.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Session.instance,
      builder: (context, _) {
        final session = Session.instance;
        switch (session.status) {
          case AuthStatus.checking:
            return const SplashScreen();
          case AuthStatus.unreachable:
            return SplashScreen(error: session.error ?? 'Check your connection and try again.');
          case AuthStatus.loggedOut:
            return const LoginScreen();
          case AuthStatus.loggedIn:
            return const HomeShell();
        }
      },
    );
  }
}
