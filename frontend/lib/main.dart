import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const ForgeFit());
}

class ForgeFit extends StatelessWidget {
  const ForgeFit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForgeFit',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: Colors.black,

        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
        ),

        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF121212),
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),

        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}