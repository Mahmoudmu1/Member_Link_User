import 'package:flutter/material.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Member Link',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF0844F4), // Custom blue as the primary color
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF0844F4),
          onPrimary: Colors.white,
          primaryContainer: const Color(
              0xFF4D73FF), // A lighter shade of primary for containers
          secondary: Colors.blue[600]!, // Use a complementary blue as secondary
          onSecondary: Colors.white,
          surface: Colors.blue[50]!,
          onSurface: Colors.black87,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0844F4),
          brightness: Brightness.dark,
        ).copyWith(
          primary:
              const Color(0xFF4D73FF), // Lighter primary color for dark mode
          onPrimary: Colors.black87,

          primaryContainer:
              const Color(0xFF0844F4), // Darker primary container color
          secondary: Colors.blue[200]!,
          onSecondary: Colors.black87,
          surface: Colors.blueGrey[800]!,
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.black87,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
