import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/theme_provider.dart';
import 'providers/security_provider.dart';
import 'providers/note_provider.dart'; // 👈 IMPORTAR NOTE PROVIDER
import 'screens/splash_screen.dart';
import 'screens/app_lock_screen.dart';
import 'screens/auth_method_selector.dart';
import 'screens/note_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://hrrlcxxkboaamrzhntns.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhycmxjeHhrYm9hYW1yemhudG5zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwNDUwODcsImV4cCI6MjA4NzYyMTA4N30.sJZ7dEL2qap82JAo5e2jFMn1cLYVOTTtKw80JLCp7K4',
  );
  
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
        ChangeNotifierProvider(create: (_) => NoteProvider()), // 👈 AGREGADO
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