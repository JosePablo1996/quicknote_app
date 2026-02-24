import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/calendar_screen.dart'; // ✅ Importar la pantalla de calendario

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

  @override
  Widget build(BuildContext context) {
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
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.blue.shade50.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.blue.withValues(alpha: _glassAnimation.value * 0.3),
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
                  color: Colors.white.withValues(alpha: 0.3),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // HEADER CON TÍTULO Y BOTÓN CERRAR
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                                Colors.blue.shade800,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'QuickNote', // ✅ Cambiado de EasyNotes a QuickNote
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
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
                                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                                  onPressed: widget.onClose,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CONTENIDO DEL MENÚ
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            children: [
                              // SECCIÓN: TODAS LAS NOTAS
                              _buildSectionTitle('Todas las notas'),
                              _buildGlassButton(
                                label: 'Todas',
                                icon: Icons.note,
                                onTap: () {},
                              ),
                              _buildSubButton('Personal', onTap: () {}),
                              _buildSubButton('Trabajo', onTap: () {}),

                              const SizedBox(height: 16),

                              // SECCIÓN: CALENDARIO (CON NAVEGACIÓN)
                              _buildSectionTitle('Calendario'),
                              _buildGlassButton(
                                label: 'Ver calendario',
                                icon: Icons.calendar_today,
                                onTap: _navigateToCalendar, // ✅ Navega a CalendarScreen
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: RECORDATORIO
                              _buildSectionTitle('Recordatorio'),
                              _buildGlassButton(
                                label: 'Recordatorios',
                                icon: Icons.alarm,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: FAVORITOS
                              _buildSectionTitle('Favoritos'),
                              _buildGlassButton(
                                label: 'Notas favoritas',
                                icon: Icons.star,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: ETIQUETAS
                              _buildSectionTitle('Etiquetas'),
                              _buildGlassButton(
                                label: 'Todas las etiquetas',
                                icon: Icons.label,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: ARCHIVAR
                              _buildSectionTitle('Archivar'),
                              _buildGlassButton(
                                label: 'Notas archivadas',
                                icon: Icons.archive,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: PAPELERA
                              _buildSectionTitle('Papelera'),
                              _buildGlassButton(
                                label: 'Papelera',
                                icon: Icons.delete,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: WIDGET
                              _buildSectionTitle('Widget'),
                              _buildGlassButton(
                                label: 'Configurar widget',
                                icon: Icons.widgets,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: SINCRONIZAR
                              _buildSectionTitle('Sincronizar y respaldar'),
                              _buildGlassButton(
                                label: 'Sincronizar ahora',
                                icon: Icons.sync,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: AYUDA
                              _buildSectionTitle('Centro de ayuda'),
                              _buildGlassButton(
                                label: 'Ayuda y soporte',
                                icon: Icons.help,
                                onTap: () {},
                              ),

                              const SizedBox(height: 16),

                              // SECCIÓN: AJUSTES
                              _buildSectionTitle('Ajustes'),
                              _buildGlassButton(
                                label: 'Configuración',
                                icon: Icons.settings,
                                onTap: () {},
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

  // Widget para título de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Widget para botones principales con efecto glass
  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.7),
            Colors.white.withValues(alpha: 0.9),
            Colors.blue.shade50.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para sub-botones (como Personal, Trabajo, etc.)
  Widget _buildSubButton(String label, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 36), // Alineación con los iconos
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}