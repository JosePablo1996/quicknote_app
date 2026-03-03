import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/security_provider.dart';
import 'security_setup_screen.dart';
import 'developer_profile_screen.dart';
import 'changelog_screen.dart';
import 'backup_screen.dart'; // 👈 IMPORTAMOS LA NUEVA PANTALLA DE RESPALDO

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedSortOrder = 'Fecha de modificación';
  final List<String> _sortOptions = [
    'Fecha de modificación',
    'Fecha de creación',
    'Título (A-Z)',
    'Título (Z-A)',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Configuración',
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
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SECCIÓN: APARIENCIA
          _buildSectionHeader('Apariencia', isDarkMode),
          _buildGlassCard(
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.dark_mode,
                  iconColor: Colors.blue,
                  title: 'Modo oscuro',
                  subtitle: 'Cambiar entre tema claro y oscuro',
                  trailing: _buildThemeToggle(themeProvider, isDarkMode),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // SECCIÓN: NOTIFICACIONES
          _buildSectionHeader('Notificaciones', isDarkMode),
          _buildGlassCard(
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications,
                  iconColor: Colors.orange,
                  title: 'Notificaciones',
                  subtitle: 'Recibir alertas de recordatorios',
                  trailing: _buildSwitch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // SECCIÓN: SEGURIDAD
          _buildSectionHeader('Seguridad', isDarkMode),
          _buildGlassCard(
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.lock,
                  iconColor: Colors.red,
                  title: 'Bloqueo de aplicación',
                  subtitle: _getSecuritySubtitle(securityProvider),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Configurar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecuritySetupScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // SECCIÓN: ORDENAR NOTAS
          _buildSectionHeader('Ordenar notas', isDarkMode),
          _buildGlassCard(
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.sort,
                  iconColor: Colors.purple,
                  title: 'Ordenar por',
                  subtitle: _selectedSortOrder,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[700]!.withValues(alpha: 0.3)
                          : Colors.grey[200]!.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey[600]!.withValues(alpha: 0.3)
                            : Colors.grey[400]!.withValues(alpha: 0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSortOrder,
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSortOrder = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // SECCIÓN: RESPALDO - AHORA CON NAVEGACIÓN A BACKUP_SCREEN
          _buildSectionHeader('Respaldo', isDarkMode),
          _buildGlassCard(
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.backup_rounded,
                  iconColor: Colors.green,
                  title: 'Respaldo manual',
                  subtitle: 'Crear y restaurar copias de seguridad de tus notas',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Administrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BackupScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // SECCIÓN: ACERCA DE - ACTUALIZADA A VERSIÓN 2.2.0
          _buildSectionHeader('Acerca de', isDarkMode),
          _buildGlassCard(
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.info,
                  iconColor: Colors.lightBlue,
                  title: 'Versión',
                  subtitle: 'QuickNote v2.5.0', // 👈 ACTUALIZADO A 2.5.0
                  isDarkMode: isDarkMode,
                  showArrow: false,
                ),
                _buildSettingsTile(
                  icon: Icons.update,
                  iconColor: Colors.amber,
                  title: 'Registro de cambios',
                  subtitle: 'Ver todas las novedades de QuickNote',
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangelogScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // SECCIÓN: INFORMACIÓN DEL DESARROLLADOR - SIN BADGE "DESARROLLADOR FULL STACK"
          _buildSectionHeader('Información del desarrollador', isDarkMode),
          _buildDeveloperEnhancedCard(isDarkMode),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _getSecuritySubtitle(SecurityProvider provider) {
    switch (provider.currentMethod) {
      case SecurityMethod.none:
        return 'Sin bloqueo - Toca para configurar';
      case SecurityMethod.pin:
        return 'PIN configurado - Toca para cambiar';
      case SecurityMethod.pattern:
        return 'Patrón configurado - Toca para cambiar';
      case SecurityMethod.biometric:
        return 'Biometría configurada - Toca para cambiar';
    }
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, required bool isDarkMode}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.grey[850]!.withValues(alpha: 0.6),
                  Colors.grey[900]!.withValues(alpha: 0.4),
                ]
              : [
                  Colors.white.withValues(alpha: 0.7),
                  Colors.grey[50]!.withValues(alpha: 0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]!.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required bool isDarkMode,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isDarkMode
            ? Colors.grey[800]!.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.3),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor.withValues(alpha: 0.2),
                iconColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing ??
            (showArrow
                ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: iconColor,
                      size: 14,
                    ),
                  )
                : null),
        onTap: onTap ?? (showArrow ? () {} : null),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  // Tarjeta mejorada para información del desarrollador - SIN BADGE
  Widget _buildDeveloperEnhancedCard(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
              ? Colors.grey[700]!.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.purple : Colors.blue).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Icono decorativo con gradiente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Texto principal
                const Text(
                  'Desarrollado con ❤️ por',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Nombre del desarrollador con estilo especial
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink.shade100.withValues(alpha: 0.3),
                        Colors.purple.shade100.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[600]! : Colors.purple.shade200,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'José Pablo Miranda Quintanilla',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Botón de perfil mejorado
                _buildDeveloperProfileButton(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Botón de perfil mejorado
  Widget _buildDeveloperProfileButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.teal, Colors.green],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DeveloperProfileScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Ver perfil del desarrollador',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider, bool isDarkMode) {
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.grey[700]!, Colors.grey[800]!]
                : [Colors.blue.shade300, Colors.blue.shade500],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey[600]!.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.blue).withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDarkMode ? 30 : 4,
              right: isDarkMode ? 4 : 30,
              top: 4,
              bottom: 4,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 16,
                  color: isDarkMode ? Colors.grey[800] : Colors.amber.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required bool value,
    required Function(bool) onChanged,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 50,
        height: 26,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: value
                ? [Colors.blue.shade400, Colors.blue.shade600]
                : isDarkMode
                    ? [Colors.grey[700]!, Colors.grey[800]!]
                    : [Colors.grey[300]!, Colors.grey[400]!],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? Colors.blue.shade300.withValues(alpha: 0.5)
                : isDarkMode
                    ? Colors.grey[600]!.withValues(alpha: 0.3)
                    : Colors.grey[400]!.withValues(alpha: 0.3),
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 24 : 4,
              right: value ? 4 : 24,
              top: 3,
              bottom: 3,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}