import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Importar el splash screen
// import 'screens/note_list_screen.dart'; // Ya no es necesario aquí

void main() {
  runApp(const QuickNoteApp());
}

class QuickNoteApp extends StatelessWidget {
  const QuickNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(), // 👈 Ahora inicia con SplashScreen
    );
  }
}