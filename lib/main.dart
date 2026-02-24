import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/security_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/app_lock_screen.dart';
import 'screens/auth_method_selector.dart';
import 'screens/note_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: Consumer2<ThemeProvider, SecurityProvider>(
        builder: (context, themeProvider, securityProvider, child) {
          return MaterialApp(
            title: 'QuickNote',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: FutureBuilder(
              future: Future.delayed(const Duration(seconds: 2)),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SplashScreen();
                }
                
                // Si hay seguridad configurada y la app está bloqueada
                if (securityProvider.currentMethod != SecurityMethod.none && 
                    securityProvider.isLocked) {
                  
                  // Si hay múltiples métodos disponibles, mostrar selector
                  if (securityProvider.hasMultipleMethods) {
                    return const AuthMethodSelector();
                  }
                  
                  // Si no, mostrar pantalla de bloqueo normal
                  return const AppLockScreen();
                }
                
                return const NoteListScreen();
              },
            ),
          );
        },
      ),
    );
  }
}