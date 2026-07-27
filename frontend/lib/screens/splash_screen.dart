import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_state.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
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

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        appState.loadProfile(),
        appState.loadWorkouts(),
        Future.delayed(
          const Duration(seconds: 2),
        ),
      ]);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginScreen(),
        ),
      );
    } catch (error) {
      debugPrint(
        "Failed to initialize ForgeFit: "
        "$error",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't connect to ForgeFit. "
            "Check the backend and try again.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "ForgeFit",
          style: TextStyle(
            fontSize: 40,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}