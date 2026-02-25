import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ChangelogScreen extends StatefulWidget {
  const ChangelogScreen({super.key});

  @override
  State<ChangelogScreen> createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  final List<VersionData> _versions = [
    VersionData(
      version: '2.1.1',
      date: '25 de Febrero 2026',
      title: 'Perfil del Desarrollador y Mejoras UI',
      changes: [
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Nueva pantalla: Perfil del Desarrollador con banner y avatar decorativo',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Sección "Conectar conmigo" con enlaces a GitHub, Email y LinkedIn',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Pantalla de Ajustes simplificada y mejorada con nueva tarjeta de desarrollador',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Menú lateral izquierdo optimizado sin lag y con header centrado',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Menú de notas optimizado con animaciones más fluidas',
        ),
        ChangeItem(
          type: ChangeType.fix,
          description: 'Eliminadas opciones de "Términos" y "Política de privacidad"',
        ),
        ChangeItem(
          type: ChangeType.fix,
          description: 'Corrección de errores de rendimiento en animaciones',
        ),
      ],
    ),
    VersionData(
      version: '2.1.0',
      date: '24 de Febrero 2026',
      title: 'Sistema de Seguridad y Mejoras Visuales',
      changes: [
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Sistema de seguridad con PIN de 4 dígitos',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Autenticación biométrica (huella digital)',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Selector de método al iniciar la app',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Splash screen renovado con animaciones',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Pantalla de bloqueo con diseño mejorado',
        ),
      ],
    ),
    VersionData(
      version: '2.0.0',
      date: '24 de Febrero 2026',
      title: 'Modo Oscuro/Claro y Glassmorphism Global',
      changes: [
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Modo oscuro/claro con ThemeProvider y ChangeNotifier',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Toggle animado sol/luna en header',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Efectos glassmorphism en toda la app',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Menú lateral con colores distintivos por sección',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Pantalla de edición rediseñada tipo bloc de notas',
        ),
      ],
    ),
    VersionData(
      version: '1.2.0',
      date: '24 de Febrero 2026',
      title: 'Mejoras UI/UX',
      changes: [
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Calendario funcional con vista semanal y mensual',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Selector de color en formulario de notas',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Menú lateral izquierdo con efecto Liquid Glass',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Grid de notas con colores personalizados',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Pull to refresh mejorado',
        ),
      ],
    ),
    VersionData(
      version: '1.1.0',
      date: '23 de Febrero 2026',
      title: 'Mejoras de Interfaz',
      changes: [
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Splash Screen con animación fade',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'NoteCard rediseñado con mejor aspecto visual',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Empty State animado y atractivo',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Snackbars personalizados (éxito, error, info)',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Animaciones entre pantallas',
        ),
      ],
    ),
    VersionData(
      version: '1.0.0',
      date: '23 de Febrero 2026',
      title: 'Versión Inicial',
      changes: [
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'CRUD completo de notas (Crear, Leer, Actualizar, Eliminar)',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Conexión con API REST',
        ),
        ChangeItem(
          type: ChangeType.newFeature,
          description: 'Manejo de errores y redirects (307)',
        ),
        ChangeItem(
          type: ChangeType.enhancement,
          description: 'Logging para debug',
        ),
      ],
      isInitial: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Registro de cambios',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _versions.length,
        itemBuilder: (context, index) {
          final version = _versions[index];
          return _buildVersionCard(version, isDarkMode, index == 0);
        },
      ),
    );
  }

  Widget _buildVersionCard(VersionData version, bool isDarkMode, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.grey[850]!.withValues(alpha: 0.7),
                  Colors.grey[900]!.withValues(alpha: 0.5),
                ]
              : [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.grey[50]!.withValues(alpha: 0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDarkMode
              ? (isLatest ? Colors.blue.shade700 : Colors.grey[700]!)
                  .withValues(alpha: 0.4)
              : (isLatest ? Colors.blue.shade300 : Colors.grey[400]!)
                  .withValues(alpha: 0.3),
          width: isLatest ? 2 : 1.5,
        ),
        boxShadow: [
          if (isLatest)
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con versión y badge "NUEVO"
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLatest
                              ? [Colors.blue.shade400, Colors.purple.shade400]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v${version.version}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      version.date,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    if (isLatest)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'NUEVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Título de la versión
                Text(
                  version.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Lista de cambios
                ...version.changes.map((change) => _buildChangeItem(change, isDarkMode)),
                
                if (version.isInitial) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.green.shade900.withValues(alpha: 0.2)
                          : Colors.green.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.green.shade800.withValues(alpha: 0.3)
                            : Colors.green.shade200.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: isDarkMode ? Colors.green.shade300 : Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¡Versión inicial de QuickNote! 🚀',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeItem(ChangeItem change, bool isDarkMode) {
    Color getIconColor() {
      switch (change.type) {
        case ChangeType.newFeature:
          return Colors.green;
        case ChangeType.enhancement:
          return Colors.blue;
        case ChangeType.fix:
          return Colors.orange;
      }
    }

    IconData getIcon() {
      switch (change.type) {
        case ChangeType.newFeature:
          return Icons.rocket_launch;
        case ChangeType.enhancement:
          return Icons.brush;
        case ChangeType.fix:
          return Icons.bug_report;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: getIconColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              getIcon(),
              size: 14,
              color: getIconColor(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              change.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ChangeType {
  newFeature,
  enhancement,
  fix,
}

class ChangeItem {
  final ChangeType type;
  final String description;

  ChangeItem({
    required this.type,
    required this.description,
  });
}

class VersionData {
  final String version;
  final String date;
  final String title;
  final List<ChangeItem> changes;
  final bool isInitial;

  VersionData({
    required this.version,
    required this.date,
    required this.title,
    required this.changes,
    this.isInitial = false,
  });
}