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
  final Set<String> _expandedVersions = {'2.5.0'}; // Por defecto, la última versión expandida

  final List<VersionData> _versions = [
    // ========== VERSIÓN 2.5.0 - ACTUAL (con todos los cambios implementados) ==========
    VersionData(
      version: '2.5.0',
      date: '03 Mar 2026',
      title: '🏆 Sincronización Offline Perfecta',
      cardCorner: CardCorner.rounded,
      gradientColors: [0xFF6366F1, 0xFF8B5CF6], // Indigo a Violeta
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '📱 Modo Offline Completo',
              subItems: [
                'Sistema de base de datos local con SQLite',
                'Detección automática de conectividad',
                'Sincronización en segundo plano al recuperar conexión',
                'Indicadores visuales de estado offline (naranja)',
                'Tooltips explicativos en tarjetas pendientes',
              ],
            ),
            ChangeItem(
              description: '🔌 Nuevo widget ConnectionStatus',
              subItems: [
                'Barra naranja en la parte superior cuando estás offline',
                'Mensaje claro: "Modo offline - Los cambios se sincronizarán cuando haya conexión"',
                'Botón "RECARGAR" para forzar sincronización manual',
                'Integrado en todas las pantallas principales',
              ],
            ),
            ChangeItem(
              description: '🔄 Sistema de Verificación y Corrección',
              subItems: [
                'Verificación post-guardado en BD local',
                'Corrección forzada automática si la BD no guarda correctamente',
                'Logs detallados para debugging',
                'Sistema de emojis en logs (🔴, 🟡, 🟢)',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '🐛 Correcciones Críticas',
          icon: Icons.bug_report,
          color: 0xFFFF9800,
          items: [
            ChangeItem(
              description: '🔧 Corrección del Ciclo Offline-Online',
              subItems: [
                'Notas restauradas offline ya NO desaparecen al conectar internet',
                'Corregida inconsistencia en BD local después de restaurar',
                'Sincronización correcta de notas pendientes',
                'Verificación de deletedAt en BD después de restaurar',
                'Forzado de corrección con SQL directo cuando es necesario',
              ],
            ),
            ChangeItem(
              description: '📱 Correcciones en UI',
              subItems: [
                'Refresh automático en eliminación múltiple',
                'Eliminado spinner que se quedaba cargando en NoteMenu',
                'Pull-to-refresh funcional incluso en estado vacío',
                'Mejoras en notificaciones de papelera',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '🗑️ Mejoras en Papelera',
          icon: Icons.delete_outline,
          color: 0xFFEF4444,
          items: [
            ChangeItem(
              description: '✨ Restauración mejorada',
              subItems: [
                'Método _restoreSelectedNotes ahora cuenta éxitos correctamente',
                'Forzada actualización de UI con notifyListeners()',
                'Mensajes personalizados para restauración múltiple',
                'Indicadores visuales de estado offline en papelera',
              ],
            ),
          ],
        ),
        ChangeCategory(
          title: '🛠️ Técnico',
          icon: Icons.code,
          color: 0xFF9C27B0,
          items: [
            ChangeItem(
              description: '📱 App Flutter',
              subItems: [
                'Nuevas dependencias: sqflite, connectivity_plus, synchronized',
                'Modelo Note ampliado con isSynced, localId, isPending, lastSyncError',
                'Nuevo servicio LocalDBService con índices optimizados',
                'ConnectivityUtil mejorado con singleton y listeners',
                'NoteProvider con flag _isSyncing para evitar sincronizaciones múltiples',
                'Método deleteNoteByLocalId para limpieza de notas offline',
              ],
            ),
          ],
        ),
      ],
    ),
    // ========== VERSIÓN 2.4.0 - Sistema de Notificaciones y Pull-to-Refresh ==========
    VersionData(
      version: '2.4.0',
      date: '02 Mar 2026',
      title: '⚡ Notificaciones y Pull-to-Refresh',
      cardCorner: CardCorner.rounded,
      gradientColors: [0xFF3B82F6, 0xFF10B981], // Azul a Verde
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '🔄 Pull-to-Refresh universal',
              subItems: [
                'Agregado RefreshIndicator en note_list_screen.dart incluso sin notas',
                'Agregado RefreshIndicator en trash_screen.dart',
                'Permite refrescar manualmente para verificar cambios',
                'Consistente en toda la app',
              ],
            ),
            ChangeItem(
              description: '📱 Notificaciones mejoradas',
              subItems: [
                'Diseño atractivo con iconos circulares',
                'Mensajes de título y subtítulo',
                'Botón "VER" para navegación rápida',
                'Snackbars animados al marcar/desmarcar favoritos',
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
              description: '🎨 Optimizaciones visuales',
              subItems: [
                'Sincronización fluida desde el menú',
                'Eliminados spinners que se quedaban cargando',
                'Mejor feedback visual en operaciones múltiples',
                'Contador de días desde eliminación en papelera',
              ],
            ),
          ],
        ),
      ],
    ),
    // ========== VERSIÓN 2.3.0 - Sistema Completo de Etiquetas y Archivado ==========
    VersionData(
      version: '2.3.0',
      date: '01 Mar 2026',
      title: '🏷️ Sistema Completo de Etiquetas y Archivado',
      cardCorner: CardCorner.rounded,
      gradientColors: [0xFFEC4899, 0xFFF59E0B], // Rosa a Naranja
      changes: [
        ChangeCategory(
          title: '🚀 Nuevas Funcionalidades',
          icon: Icons.rocket_launch,
          color: 0xFF4CAF50,
          items: [
            ChangeItem(
              description: '🏷️ Sistema completo de etiquetas',
              subItems: [
                'Gestión de etiquetas (TagsScreen) con vista lista/nube',
                'Filtrado dinámico por etiquetas en lista principal',
                'Colores únicos por etiqueta usando Tag.getColorForName()',
                'Diálogo de selección con sugerencias y colores',
                'Navegación a TagNotesScreen desde cualquier etiqueta',
              ],
            ),
            ChangeItem(
              description: '📦 Pantalla de notas archivadas (ArchivedScreen)',
              subItems: [
                'Archivar y desarchivar notas',
                'Restauración múltiple desde archivadas',
                'Indicador visual de notas archivadas',
              ],
            ),
            ChangeItem(
              description: '⭐ Indicador LED parpadeante para favoritos',
              subItems: [
                'LED parpadeante en notas favoritas',
                'Snackbar animado al marcar/desmarcar',
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
              description: '🎯 CustomHeader rediseñado',
              subItems: [
                'Dropdown dinámico con todas las etiquetas existentes',
                'Título estilizado con gradiente',
                'Cada etiqueta muestra su color característico',
              ],
            ),
            ChangeItem(
              description: '💬 Diálogo de selección de etiquetas mejorado',
              subItems: [
                'Sugerencias de etiquetas existentes',
                'Colores únicos por etiqueta',
                'Eliminación de tags con confirmación',
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
              description: '🔧 Correcciones críticas',
              subItems: [
                'Error 500 en API por columna deleted_at faltante',
                'Pantalla negra en diálogo de etiquetas',
                'Persistencia de etiquetas al recargar la app',
                'Tags no se enviaban al backend',
              ],
            ),
          ],
        ),
      ],
    ),
    // ========== VERSIÓN 2.2.0 - Sistema de Papelera y Centro de Ayuda ==========
    VersionData(
      version: '2.2.0',
      date: '26 Feb 2026',
      title: '🗑️ Sistema de Papelera y Centro de Ayuda',
      cardCorner: CardCorner.rounded,
      gradientColors: [0xFF8B5CF6, 0xFFEC4899], // Violeta a Rosa
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
              ],
            ),
          ],
        ),
      ],
    ),
    // ========== VERSIÓN 2.1.2 - Sistema de Backup/Restore ==========
    VersionData(
      version: '2.1.2',
      date: '25 Feb 2026',
      title: '💾 Sistema de Backup/Restore',
      cardCorner: CardCorner.soft,
      gradientColors: [0xFF10B981, 0xFF3B82F6], // Verde a Azul
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
      ],
    ),
    // ========== VERSIÓN 2.1.1 - Perfil del Desarrollador ==========
    VersionData(
      version: '2.1.1',
      date: '24 Feb 2026',
      title: '👤 Perfil del Desarrollador',
      cardCorner: CardCorner.soft,
      gradientColors: [0xFFF59E0B, 0xFFEF4444], // Naranja a Rojo
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
      ],
    ),
    // ========== VERSIÓN 2.1.0 - Sistema de Seguridad ==========
    VersionData(
      version: '2.1.0',
      date: '23 Feb 2026',
      title: '🔐 Sistema de Seguridad',
      cardCorner: CardCorner.soft,
      gradientColors: [0xFF6366F1, 0xFF8B5CF6], // Indigo a Violeta
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
      ],
    ),
    // ========== VERSIÓN 2.0.0 - Modo Oscuro/Claro ==========
    VersionData(
      version: '2.0.0',
      date: '22 Feb 2026',
      title: '🌓 Modo Oscuro/Claro',
      cardCorner: CardCorner.soft,
      gradientColors: [0xFF3B82F6, 0xFF10B981], // Azul a Verde
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
    // ========== VERSIÓN 1.2.0 - Mejoras UI/UX ==========
    VersionData(
      version: '1.2.0',
      date: '21 Feb 2026',
      title: '📅 Mejoras UI/UX',
      cardCorner: CardCorner.square,
      gradientColors: [0xFFEC4899, 0xFFF59E0B], // Rosa a Naranja
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
      ],
    ),
    // ========== VERSIÓN 1.1.0 - Mejoras de Interfaz ==========
    VersionData(
      version: '1.1.0',
      date: '20 Feb 2026',
      title: '✨ Mejoras de Interfaz',
      cardCorner: CardCorner.square,
      gradientColors: [0xFF8B5CF6, 0xFFEC4899], // Violeta a Rosa
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
          ],
        ),
      ],
    ),
    // ========== VERSIÓN 1.0.0 - Versión Inicial ==========
    VersionData(
      version: '1.0.0',
      date: '19 Feb 2026',
      title: '🎉 Versión Inicial',
      cardCorner: CardCorner.square,
      gradientColors: [0xFF10B981, 0xFF3B82F6], // Verde a Azul
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

    // Colores del gradiente para la tarjeta
    final gradientStart = Color(version.gradientColors[0]);
    final gradientEnd = Color(version.gradientColors[1]);

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
              ? gradientStart.withValues(alpha: 0.7)
              : (isDarkMode
                  ? Colors.grey[700]!.withValues(alpha: 0.3)
                  : Colors.grey[400]!.withValues(alpha: 0.2)),
          width: isLatest ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isLatest)
            BoxShadow(
              color: gradientStart.withValues(alpha: 0.3),
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
                          // Badge de versión con gradiente
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [gradientStart, gradientEnd],
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
                          
                          // Icono de expandir/contraer con animación
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: gradientStart.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: gradientStart.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: isExpanded ? 0.5 : 0.0,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: gradientStart,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // CONTENIDO EXPANDIBLE CON ANIMACIÓN
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
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
                                  colors: [gradientStart.withValues(alpha: 0.1), gradientEnd.withValues(alpha: 0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: gradientStart.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: gradientStart.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: gradientStart,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      version.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: gradientStart,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Categorías de cambios
                            ...version.changes.map((category) => 
                              _buildCategorySection(category, isDarkMode, gradientStart)
                            ),
                            
                            // Versión inicial
                            if (version.isInitial) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDarkMode
                                        ? [gradientStart.withValues(alpha: 0.2), gradientEnd.withValues(alpha: 0.1)]
                                        : [gradientStart.withValues(alpha: 0.1), gradientEnd.withValues(alpha: 0.05)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: gradientStart.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: gradientStart.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.emoji_events,
                                        color: gradientStart,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '¡El comienzo de todo!',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: gradientStart,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'La primera versión de QuickNote 🚀',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: gradientStart,
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
                  ),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 400),
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(ChangeCategory category, bool isDarkMode, Color versionColor) {
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
  final List<int> gradientColors; // Nuevo campo para colores de gradiente

  const VersionData({
    required this.version,
    required this.date,
    required this.title,
    required this.cardCorner,
    required this.changes,
    this.isInitial = false,
    required this.gradientColors, // Ahora es requerido
  });
}