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
  // Controlar qué versión está expandida
  final Set<String> _expandedVersions = {'2.2.0'}; // Por defecto, la última versión expandida

  final List<VersionData> _versions = [
    // VERSIÓN 2.2.0 - ACTUAL
    VersionData(
      version: '2.2.0',
      date: '26 Feb 2026',
      title: 'Sistema de Papelera y Centro de Ayuda',
      cardCorner: CardCorner.rounded,
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '🗑️ Sistema de Papelera completo',
              subItems: [
                'Las notas eliminadas van a la papelera (no se pierden)',
                'Restaurar notas individuales o múltiples',
                'Eliminación permanente con confirmación',
                'Vaciar papelera completo',
                'Selección múltiple en papelera',
                'Contador de días desde eliminación',
              ],
            ),
            ChangeItem(
              description: '❓ Centro de Ayuda interactivo',
              subItems: [
                '6 categorías con modales informativos',
                'Búsqueda funcional en header',
                'Preguntas frecuentes con dropdown',
                'Tutoriales rápidos en cards',
                'Sección de contacto integrada',
              ],
            ),
            ChangeItem(
              description: '💾 Sistema de Backup mejorado',
              subItems: [
                'Backup acumulativo (conserva historial)',
                'Backup automático programado',
                'Historial de backups visual',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '✨ Mejoras UI/UX',
          icon: Icons.brush,
          color: 0xFF2196F3,
          items: [
            ChangeItem(
              description: '🎨 Mejoras visuales',
              subItems: [
                'Header con saludo dinámico (🌞/☀️/🌙)',
                'Splash screen rediseñada',
                'Glassmorphism consistente',
                'Animaciones optimizadas',
                'Mensajes más claros',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '🐛 Correcciones',
          icon: Icons.bug_report,
          color: 0xFFFF9800,
          items: [
            ChangeItem(
              description: '🔧 Correcciones técnicas',
              subItems: [
                'Caracteres ilegales en help_screen',
                'Verificaciones mounted',
                'Parámetros incorrectos',
                'Eliminación de logs',
              ],
            ),
          ],
        ),
      ],
    ),
    // VERSIÓN 2.1.2
    VersionData(
      version: '2.1.2',
      date: '25 Feb 2026',
      title: 'Sistema de Backup/Restore',
      cardCorner: CardCorner.soft,
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '📦 Sistema de backup manual',
              subItems: [
                'Guardado en formato JSON',
                'Restauración desde cualquier backup',
                'Lista de backups con detalles',
                'Eliminación de backups',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '✨ Mejoras UI/UX',
          icon: Icons.brush,
          color: 0xFF2196F3,
          items: [
            ChangeItem(
              description: '📊 Visualización mejorada',
              subItems: [
                'Barra de progreso dinámica',
                'Menú lateral rediseñado',
              ],
            ),
          ],
        ),
      ],
    ),
    // VERSIÓN 2.1.1
    VersionData(
      version: '2.1.1',
      date: '24 Feb 2026',
      title: 'Perfil del Desarrollador',
      cardCorner: CardCorner.soft,
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '👤 Perfil del Desarrollador',
              subItems: [
                'Nueva pantalla con banner',
                'Avatar decorativo',
                'Sección "Conectar conmigo"',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '✨ Mejoras UI/UX',
          icon: Icons.brush,
          color: 0xFF2196F3,
          items: [
            ChangeItem(
              description: '⚡ Optimizaciones',
              subItems: [
                'Menús sin lag',
                'Pantalla de Ajustes simplificada',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '🐛 Correcciones',
          icon: Icons.bug_report,
          color: 0xFFFF9800,
          items: [
            ChangeItem(
              description: '🔧 Correcciones',
              subItems: [
                'Opciones redundantes eliminadas',
              ],
            ),
          ],
        ),
      ],
    ),
    // VERSIÓN 2.1.0
    VersionData(
      version: '2.1.0',
      date: '23 Feb 2026',
      title: 'Sistema de Seguridad',
      cardCorner: CardCorner.soft,
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '🔐 Sistema de seguridad',
              subItems: [
                'Bloqueo con PIN de 4 dígitos',
                'Autenticación biométrica',
                'Selector de método al iniciar',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '✨ Mejoras UI/UX',
          icon: Icons.brush,
          color: 0xFF2196F3,
          items: [
            ChangeItem(
              description: '🎨 Mejoras visuales',
              subItems: [
                'Splash screen renovado',
              ],
            ),
          ],
        ),
      ],
    ),
    // VERSIÓN 2.0.0
    VersionData(
      version: '2.0.0',
      date: '22 Feb 2026',
      title: 'Modo Oscuro/Claro',
      cardCorner: CardCorner.soft,
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '🌓 Modo oscuro/claro',
              subItems: [
                'ThemeProvider con ChangeNotifier',
                'Toggle animado sol/luna',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '✨ Mejoras UI/UX',
          icon: Icons.brush,
          color: 0xFF2196F3,
          items: [
            ChangeItem(
              description: '🎨 Glassmorphism',
              subItems: [
                'Efectos en toda la app',
                'Colores distintivos por sección',
              ],
            ),
          ],
        ),
      ],
    ),
    // VERSIÓN 1.2.0
    VersionData(
      version: '1.2.0',
      date: '21 Feb 2026',
      title: 'Mejoras UI/UX',
      cardCorner: CardCorner.square,
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '📅 Calendario funcional',
              subItems: [
                'Vista semanal y mensual',
              ],
            ),
            ChangeItem(
              description: '🎨 Selector de color',
              subItems: [
                'En formulario de notas',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '✨ Mejoras UI/UX',
          icon: Icons.brush,
          color: 0xFF2196F3,
          items: [
            ChangeItem(
              description: '📊 Visualización',
              subItems: [
                'Grid de notas con colores',
                'Pull to refresh mejorado',
              ],
            ),
          ],
        ),
      ],
    ),
    // VERSIÓN 1.1.0
    VersionData(
      version: '1.1.0',
      date: '20 Feb 2026',
      title: 'Mejoras de Interfaz',
      cardCorner: CardCorner.square,
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '✨ Splash Screen',
              subItems: [
                'Animación fade',
              ],
            ),
            ChangeItem(
              description: '🔄 Empty State',
              subItems: [
                'Animado y atractivo',
              ],
            ),
            ChangeItem(
              description: '🍫 Snackbars',
              subItems: [
                'Personalizados (éxito, error, info)',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '✨ Mejoras UI/UX',
          icon: Icons.brush,
          color: 0xFF2196F3,
          items: [
            ChangeItem(
              description: '🎴 NoteCard',
              subItems: [
                'Rediseñado',
              ],
            ),
          ],
        ),
      ],
    ),
    // VERSIÓN 1.0.0
    VersionData(
      version: '1.0.0',
      date: '19 Feb 2026',
      title: 'Versión Inicial',
      cardCorner: CardCorner.square,
      changes: [
        ChangeCategory(
          title: '🚀 Primera Versión',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '📝 CRUD completo',
              subItems: [
                'Crear, Leer, Actualizar, Eliminar',
              ],
            ),
            ChangeItem(
              description: '🌐 API REST',
              subItems: [
                'Conexión con backend',
                'Manejo de redirects 307',
              ],
            ),
          ],
        ),
      ],
      isInitial: true,
    ),
  ];

  void _toggleVersion(String version) {
    setState(() {
      if (_expandedVersions.contains(version)) {
        _expandedVersions.remove(version);
      } else {
        _expandedVersions.add(version);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Historial de cambios',
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
          final isLatest = index == 0;
          final isExpanded = _expandedVersions.contains(version.version);
          
          return _buildVersionCard(
            version, 
            isDarkMode, 
            isLatest, 
            isExpanded,
          );
        },
      ),
    );
  }

  Widget _buildVersionCard(
    VersionData version, 
    bool isDarkMode, 
    bool isLatest,
    bool isExpanded,
  ) {
    // Determinar border radius según el estilo de la tarjeta
    BorderRadius getBorderRadius() {
      switch (version.cardCorner) {
        case CardCorner.square:
          return BorderRadius.circular(0);
        case CardCorner.soft:
          return BorderRadius.circular(12);
        case CardCorner.rounded:
          return BorderRadius.circular(25);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.grey[850]!.withValues(alpha: 0.8),
                  Colors.grey[900]!.withValues(alpha: 0.6),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.grey[50]!.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: getBorderRadius(),
        border: Border.all(
          color: isLatest
              ? Colors.purple.withValues(alpha: 0.5)
              : (isDarkMode
                  ? Colors.grey[700]!.withValues(alpha: 0.3)
                  : Colors.grey[400]!.withValues(alpha: 0.2)),
          width: isLatest ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isLatest)
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.25),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: getBorderRadius(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                // HEADER DE LA TARJETA (siempre visible)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleVersion(version.version),
                    borderRadius: getBorderRadius(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Badge de versión
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLatest
                                    ? [Colors.purple.shade400, Colors.blue.shade400]
                                    : [Colors.grey.shade500, Colors.grey.shade700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                          
                          // Fecha a la izquierda del dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isDarkMode ? Colors.grey[800] : Colors.grey[200])!.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  version.date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Icono de expandir/contraer
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isLatest ? Colors.purple : (isDarkMode ? Colors.grey[800] : Colors.grey[200]))!.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isLatest 
                                    ? Colors.purple.withValues(alpha: 0.3) 
                                    : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: isLatest ? Colors.purple : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // CONTENIDO EXPANDIBLE
                if (isExpanded) ...[
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TÍTULO DE LA VERSIÓN DENTRO DE LA TARJETA EXPANDIDA
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLatest
                                  ? [Colors.purple.shade50, Colors.blue.shade50]
                                  : [Colors.grey.shade100, Colors.grey.shade200],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isLatest
                                  ? Colors.purple.withValues(alpha: 0.3)
                                  : Colors.grey.shade400.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: isLatest ? Colors.purple : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  version.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode 
                                        ? (isLatest ? Colors.purple.shade200 : Colors.grey[300])
                                        : (isLatest ? Colors.purple.shade700 : Colors.grey[800]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Categorías de cambios
                        ...version.changes.map((category) => 
                          _buildCategorySection(category, isDarkMode, isLatest)
                        ),
                        
                        // Versión inicial
                        if (version.isInitial) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [Colors.green.shade900.withValues(alpha: 0.3), Colors.green.shade800.withValues(alpha: 0.2)]
                                    : [Colors.green.shade50, Colors.green.shade100],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.green.shade800.withValues(alpha: 0.3)
                                    : Colors.green.shade300.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '¡El comienzo de todo!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'La primera versión de QuickNote 🚀',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildCategorySection(ChangeCategory category, bool isDarkMode, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de categoría con diseño mejorado
          Container(
            margin: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(category.color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.icon,
                    color: Color(category.color),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(category.color).withValues(alpha: 0.5),
                        Color(category.color).withValues(alpha: 0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
          
          // Items de la categoría con mejor visualización
          ...category.items.map((item) => 
            Container(
              margin: const EdgeInsets.only(left: 16, bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.grey[800] : Colors.white)!.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(category.color).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item principal
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(category.color).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.folder,
                          size: 12,
                          color: Color(category.color),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Sub-items con mejor diseño
                  if (item.subItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(category.color).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: item.subItems.map((subItem) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(category.color),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    subItem,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum CardCorner {
  square,
  soft,
  rounded,
}

class ChangeCategory {
  final String title;
  final IconData icon;
  final int color;
  final List<ChangeItem> items;

  const ChangeCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class ChangeItem {
  final String description;
  final List<String> subItems;

  const ChangeItem({
    required this.description,
    this.subItems = const [],
  });
}

class VersionData {
  final String version;
  final String date;
  final String title;
  final CardCorner cardCorner;
  final List<ChangeCategory> changes;
  final bool isInitial;

  const VersionData({
    required this.version,
    required this.date,
    required this.title,
    required this.cardCorner,
    required this.changes,
    this.isInitial = false,
  });
}