import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../screens/calendar_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/backup_screen.dart';
import '../screens/trash_screen.dart';
import '../screens/help_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/archived_screen.dart';
import '../screens/tags_screen.dart'; // 👈 IMPORTAMOS LA PANTALLA DE ETIQUETAS
import '../providers/theme_provider.dart';
import '../utils/snackbar_utils.dart';

class LeftMenu extends StatefulWidget {
  final VoidCallback onClose;

  const LeftMenu({super.key, required this.onClose});

  @override
  State<LeftMenu> createState() => _LeftMenuState();
}

class _LeftMenuState extends State<LeftMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToScreen(Widget screen) {
    widget.onClose();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.1, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuad;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  void _showComingSoon(String feature) {
    widget.onClose();
    SnackbarUtils.showInfoSnackbar(
      context,
      '🔜 $feature - Próximamente',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Colors.grey[900]!.withValues(alpha: 0.95),
                      Colors.grey[850]!.withValues(alpha: 0.92),
                      Colors.grey[900]!.withValues(alpha: 0.95),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.blue.shade50.withValues(alpha: 0.92),
                      Colors.white.withValues(alpha: 0.95),
                    ],
            ),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: isDarkMode
                    ? Colors.grey[900]!.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.2),
                child: SafeArea(
                  child: Column(
                    children: [
                      // HEADER MEJORADO CON AVATAR
                      Container(
                        height: 180,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode
                                ? [
                                    Colors.deepPurple.shade900.withValues(alpha: 0.9),
                                    Colors.purple.shade800.withValues(alpha: 0.85),
                                    Colors.indigo.shade900.withValues(alpha: 0.9),
                                  ]
                                : [
                                    Colors.deepPurple.shade700.withValues(alpha: 0.9),
                                    Colors.purple.shade600.withValues(alpha: 0.85),
                                    Colors.indigo.shade700.withValues(alpha: 0.9),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Botón de cerrar
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close, 
                                    color: Colors.white.withValues(alpha: 0.9), 
                                    size: 20,
                                  ),
                                  onPressed: widget.onClose,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                            
                            // Contenido centrado (nombre y versión)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'QuickNote',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'v 2.5.0',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Avatar en esquina inferior izquierda
                            Positioned(
                              left: 16,
                              bottom: -20,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Colors.amber, Colors.orange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.note_alt,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ===== CONTENIDO DEL MENÚ =====
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            // Calendario
                            _buildMenuSection(
                              title: 'Calendario',
                              items: [
                                _MenuItemData(
                                  label: 'Ver calendario',
                                  icon: Icons.calendar_today,
                                  color: Colors.green.shade400,
                                  onTap: () => _navigateToScreen(const CalendarScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            // FAVORITOS - Funcional
                            _buildMenuSection(
                              title: 'Favoritos',
                              items: [
                                _MenuItemData(
                                  label: 'Notas favoritas',
                                  icon: Icons.star,
                                  color: Colors.amber.shade400,
                                  onTap: () => _navigateToScreen(const FavoritesScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            // ETIQUETAS - AHORA FUNCIONAL
                            _buildMenuSection(
                              title: 'Etiquetas',
                              items: [
                                _MenuItemData(
                                  label: 'Todas las etiquetas',
                                  icon: Icons.label,
                                  color: Colors.purple.shade400,
                                  onTap: () => _navigateToScreen(const TagsScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            // ARCHIVAR - Funcional
                            _buildMenuSection(
                              title: 'Archivar',
                              items: [
                                _MenuItemData(
                                  label: 'Notas archivadas',
                                  icon: Icons.archive,
                                  color: Colors.teal.shade400,
                                  onTap: () => _navigateToScreen(const ArchivedScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            // PAPELERA - Funcional
                            _buildMenuSection(
                              title: 'Papelera',
                              items: [
                                _MenuItemData(
                                  label: 'Papelera',
                                  icon: Icons.delete,
                                  color: Colors.red.shade400,
                                  onTap: () => _navigateToScreen(const TrashScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            // Sincronizar y respaldar
                            _buildMenuSection(
                              title: 'Sincronizar y respaldar',
                              items: [
                                _MenuItemData(
                                  label: 'Respaldo manual',
                                  icon: Icons.backup,
                                  color: Colors.lightBlue.shade400,
                                  onTap: () => _navigateToScreen(const BackupScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            // Centro de ayuda
                            _buildMenuSection(
                              title: 'Centro de ayuda',
                              items: [
                                _MenuItemData(
                                  label: 'Ayuda y soporte',
                                  icon: Icons.help,
                                  color: Colors.indigo.shade400,
                                  onTap: () => _navigateToScreen(const HelpScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            // Ajustes
                            _buildMenuSection(
                              title: 'Ajustes',
                              items: [
                                _MenuItemData(
                                  label: 'Configuración',
                                  icon: Icons.settings,
                                  color: Colors.blueGrey.shade400,
                                  onTap: () => _navigateToScreen(const SettingsScreen()),
                                ),
                              ],
                              isDarkMode: isDarkMode,
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItemData> items,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildMenuItem(item, isDarkMode)),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItemData item, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  item.color.withValues(alpha: 0.15),
                  Colors.grey[800]!.withValues(alpha: 0.6),
                  Colors.grey[850]!.withValues(alpha: 0.4),
                ]
              : [
                  item.color.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.7),
                  Colors.grey[50]!.withValues(alpha: 0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode
              ? item.color.withValues(alpha: 0.25)
              : item.color.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: item.color.withValues(alpha: 0.2),
              highlightColor: item.color.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.color.withValues(alpha: 0.25),
                            item.color.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: item.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        item.icon, 
                        color: item.color, 
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _MenuItemData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}