import 'package:flutter/material.dart';
import 'dart:math' as math; // Import necesario para funciones trigonométricas

class EmptyNotesWidget extends StatefulWidget {
  final VoidCallback onCreateNote;

  const EmptyNotesWidget({
    super.key,
    required this.onCreateNote,
  });

  @override
  State<EmptyNotesWidget> createState() => _EmptyNotesWidgetState();
}

class _EmptyNotesWidgetState extends State<EmptyNotesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono animado
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fondo decorativo
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.shade100.withValues(alpha: 0.5),
                          Colors.blue.shade50.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                  
                  // Icono principal
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.note_alt_outlined,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                  
                  // Pequeñas decoraciones (notas flotantes)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildFloatingNote(Icons.note, 40, 0.2),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 30,
                    child: _buildFloatingNote(Icons.note_add, 30, 0.4),
                  ),
                  Positioned(
                    top: 40,
                    left: 40,
                    child: _buildFloatingNote(Icons.edit_note, 25, 0.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Textos animados
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Título principal
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      '¡Comienza a tomar notas!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtítulo
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Tus ideas, pensamientos y recordatorios\nen un solo lugar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botón de acción
                  GestureDetector(
                    onTap: widget.onCreateNote,
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween<double>(begin: 1, end: 1),
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Crear primera nota',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para notas flotantes decorativas - VERSIÓN CORREGIDA
  Widget _buildFloatingNote(IconData icon, double size, double delay) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      tween: Tween<double>(begin: 0, end: 2 * math.pi),
      builder: (context, double value, child) {
        // ✅ CORREGIDO: Usar math.sin() en lugar de .sin()
        double sinValue = math.sin(value * delay);
        return Transform.translate(
          offset: Offset(0, sinValue * 5),
          child: Opacity(
            opacity: 0.3 + (value / (2 * math.pi) * 0.2),
            child: child,
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.6,
          color: Colors.blue.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}