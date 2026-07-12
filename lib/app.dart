import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

class MathMusicApp extends StatelessWidget {
  const MathMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数律华章',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A574),
          secondary: Color(0xFFE8C170),
          surface: Color(0xFF16213E),
        ),
        fontFamily: 'Georgia',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFFD4A574), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFFF8F4E6)),
          bodyMedium: TextStyle(color: Color(0xFFF8F4E6)),
        ),
      ),
      home: const GameScreen(),
    );
  }
}
