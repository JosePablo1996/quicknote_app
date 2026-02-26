import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Cargar tema guardado al iniciar
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error cargando tema: $e');
      _isDarkMode = false;
    }
  }

  // Cambiar tema y guardar preferencia
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    // Guardar en SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      print('Error guardando tema: $e');
    }
    
    notifyListeners();
  }

  // Establecer tema específico y guardar
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      print('Error guardando tema: $e');
    }
    
    notifyListeners();
  }

  // Tema claro
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0.5,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    dividerColor: Colors.grey[200],
  );

  // Tema oscuro
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
      elevation: 0.5,
    ),
    cardTheme: CardThemeData(
      color: Colors.grey[850],
      elevation: 2,
      shadowColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      titleLarge: const TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.grey[300]),
    ),
    dividerColor: Colors.grey[800],
  );
}