import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../screens/calendar_screen.dart';
import '../providers/theme_provider.dart';
import '../screens/settings_screen.dart'; // ✅ Importar SettingsScreen

class LeftMenu extends StatefulWidget {
  final VoidCallback onClose;

  const LeftMenu({super.key, required this.onClose});

  @override
  State<LeftMenu> createState() => _LeftMenuState();
}

class _LeftMenuState extends State<LeftMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _glassAnimationController;
  late Animation<double> _glassAnimation;

  @override
  void initState() {
    super.initState();
    _glassAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _glassAnimation = Tween<double>(begin: 0.1, end: 0.3).animate(
      CurvedAnimation(
        parent: _glassAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _glassAnimationController.dispose();
    super.dispose();
  }

  void _navigateToCalendar() {
    widget.onClose(); // Cerrar el menú
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    widget.onClose(); // Cerrar el menú
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
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
      child: AnimatedBuilder(
        animation: _glassAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Colors.grey[900]!.withValues(alpha: 0.95),
                        Colors.grey[850]!.withValues(alpha: 0.9),
                        Colors.grey[900]!.withValues(alpha: 0.95),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.blue.shade50.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.95),
                      ],
              ),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDarkMode
                      ? Colors.blue.withValues(alpha: _glassAnimation.value * 0.2)
                      : Colors.blue.withValues(alpha: _glassAnimation.value * 0.3),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: isDarkMode
                      ? Colors.grey[900]!.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.3),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // HEADER CON TÍTULO MEJORADO Y VERSIÓN
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDarkMode
                                  ? [
                                      Colors.deepPurple.shade900.withValues(alpha: 0.95),
                                      Colors.purple.shade800.withValues(alpha: 0.9),
                                      Colors.indigo.shade900.withValues(alpha: 0.95),
                                    ]
                                  : [
                                      Colors.deepPurple.shade700.withValues(alpha: 0.95),
                                      Colors.purple.shade600.withValues(alpha: 0.9),
                                      Colors.indigo.shade700.withValues(alpha: 0.95),
                                    ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withValues(alpha: 0.5),
                                blurRadius: 25,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.amber,
                                                Colors.orange,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withValues(alpha: 0.5),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.note_alt,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'QuickNote',
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black.withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: const Text(
                                                'v 2.1.1',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white70,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
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
                                          size: 22
                                        ),
                                        onPressed: widget.onClose,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // CONTENIDO DEL MENÚ
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            children: [
                              // SECCIÓN: CALENDARIO - COLOR VERDE CON CONTRASTE MEJORADO
                              _buildSectionTitle('Calendario', isDarkMode),
                              _buildGlassButton(
                                label: 'Ver calendario',
                                icon: Icons.calendar_today,
                                color: Colors.green.shade400,
                                onTap: _navigateToCalendar,
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: RECORDATORIO - COLOR NARANJA CON CONTRASTE MEJORADO
                              _buildSectionTitle('Recordatorio', isDarkMode),
                              _buildGlassButton(
                                label: 'Recordatorios',
                                icon: Icons.alarm,
                                color: Colors.orange.shade400,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: FAVORITOS - COLOR AMARILLO CON CONTRASTE MEJORADO
                              _buildSectionTitle('Favoritos', isDarkMode),
                              _buildGlassButton(
                                label: 'Notas favoritas',
                                icon: Icons.star,
                                color: Colors.amber.shade400,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: ETIQUETAS - COLOR PÚRPURA CON CONTRASTE MEJORADO
                              _buildSectionTitle('Etiquetas', isDarkMode),
                              _buildGlassButton(
                                label: 'Todas las etiquetas',
                                icon: Icons.label,
                                color: Colors.purple.shade400,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: ARCHIVAR - COLOR TEAL CON CONTRASTE MEJORADO
                              _buildSectionTitle('Archivar', isDarkMode),
                              _buildGlassButton(
                                label: 'Notas archivadas',
                                icon: Icons.archive,
                                color: Colors.teal.shade400,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: PAPELERA - COLOR ROJO CON CONTRASTE MEJORADO
                              _buildSectionTitle('Papelera', isDarkMode),
                              _buildGlassButton(
                                label: 'Papelera',
                                icon: Icons.delete,
                                color: Colors.red.shade400,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: SINCRONIZAR - COLOR CELESTE CON CONTRASTE MEJORADO
                              _buildSectionTitle('Sincronizar y respaldar', isDarkMode),
                              _buildGlassButton(
                                label: 'Sincronizar ahora',
                                icon: Icons.sync,
                                color: Colors.lightBlue.shade400,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: AYUDA - COLOR INDIGO CON CONTRASTE MEJORADO
                              _buildSectionTitle('Centro de ayuda', isDarkMode),
                              _buildGlassButton(
                                label: 'Ayuda y soporte',
                                icon: Icons.help,
                                color: Colors.indigo.shade400,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: AJUSTES - COLOR GRIS CON CONTRASTE MEJORADO
                              _buildSectionTitle('Ajustes', isDarkMode),
                              _buildGlassButton(
                                label: 'Configuración',
                                icon: Icons.settings,
                                color: Colors.blueGrey.shade400,
                                onTap: _navigateToSettings,
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget para título de sección mejorado
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para botones principales con efecto glass mejorado y contraste
  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    Color? color,
    EdgeInsetsGeometry? margin,
  }) {
    final buttonColor = color ?? Colors.blue;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  buttonColor.withValues(alpha: 0.25),
                  Colors.grey[800]!.withValues(alpha: 0.8),
                  Colors.grey[850]!.withValues(alpha: 0.6),
                ]
              : [
                  buttonColor.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.9),
                  Colors.grey[50]!.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? buttonColor.withValues(alpha: 0.4)
              : buttonColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withValues(alpha: isDarkMode ? 0.2 : 0.25),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: buttonColor.withValues(alpha: 0.3),
              highlightColor: buttonColor.withValues(alpha: 0.15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            buttonColor.withValues(alpha: 0.4),
                            buttonColor.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: buttonColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon, 
                        color: buttonColor, 
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: buttonColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: buttonColor,
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

  // Widget para sub-botones con efecto glass mejorado
  Widget _buildSubButton(String label, {required VoidCallback onTap, required bool isDarkMode}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDarkMode
              ? [
                  Colors.grey[800]!.withValues(alpha: 0.6),
                  Colors.grey[700]!.withValues(alpha: 0.4),
                ]
              : [
                  Colors.grey[100]!.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode 
              ? Colors.grey[600]!.withValues(alpha: 0.4)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 42), // Alineación con los iconos
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
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