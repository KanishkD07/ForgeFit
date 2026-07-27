import 'package:flutter/material.dart';

import '../services/app_state.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen
    extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  final AppState appState =
      AppState.instance;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    // Keep splash visible briefly.
    final minimumSplash =
        Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    bool authenticated = false;

    try {
      final hasSession =
          await appState
              .restoreSession();

      if (hasSession) {
        try {
          await Future.wait([
            appState.loadProfile(),
            appState.loadWorkouts(),
          ]);

          authenticated = true;
        } catch (error) {
          debugPrint(
            'Stored session is invalid: '
            '$error',
          );

          await appState.logout();
        }
      }
    } catch (error) {
      debugPrint(
        'Failed to restore session: '
        '$error',
      );

      await appState.logout();
    }

    await minimumSplash;

    if (!mounted) return;

    if (authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DashboardScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 72,
              color: Colors.red,
            ),

            SizedBox(
              height: 18,
            ),

            Text(
              'ForgeFit',
              style: TextStyle(
                fontSize: 40,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 24,
            ),

            SizedBox(
              width: 24,
              height: 24,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}