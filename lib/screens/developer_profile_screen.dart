import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../services/supabase_service.dart';
import '../models/developer_profile.dart';

class DeveloperProfileScreen extends StatefulWidget {
  const DeveloperProfileScreen({super.key});

  @override
  State<DeveloperProfileScreen> createState() => _DeveloperProfileScreenState();
}

class _DeveloperProfileScreenState extends State<DeveloperProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  DeveloperProfile? _profile;
  bool _isLoading = true;
  bool _isDeveloperMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _checkDeveloperMode();
  }

  Future<void> _checkDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDeveloperMode = prefs.getBool('is_developer') ?? false;
    });
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final profile = await _supabaseService.getDeveloperProfile();
    
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _logoutDeveloper() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_developer');
    setState(() {
      _isDeveloperMode = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modo desarrollador desactivado'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Información del Desarrollador',
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
        actions: [
          if (_isDeveloperMode)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _logoutDeveloper();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Salir modo dev', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ===== BANNER Y AVATAR (UBICACIÓN ORIGINAL) =====
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner mejorado
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue, Colors.purple, Colors.pink],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Patrón de fondo decorativo
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Opacity(
                              opacity: 0.1,
                              child: Icon(
                                Icons.note_alt,
                                size: 150,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Contenido del banner
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'QuickNote',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'Desarrollado con ❤️ por José Pablo Miranda',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar mejorado (ubicación original)
                    Positioned(
                      left: 20,
                      bottom: -40,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue, Colors.purple],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.blue, Colors.purple],
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Badge decorativo (estrella)
                    Positioned(
                      left: 85,
                      bottom: -15,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // ===== NOMBRE DEL DESARROLLADOR EN CONTENEDOR =====
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [Colors.grey[800]!.withValues(alpha: 0.6), Colors.grey[900]!.withValues(alpha: 0.4)]
                            : [Colors.white.withValues(alpha: 0.7), Colors.grey[50]!.withValues(alpha: 0.5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _profile?.name ?? 'José Pablo Miranda Quintanilla',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.blue.withValues(alpha: 0.2)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Desarrollador Full Stack',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ===== REDES SOCIALES MEJORADAS =====
                _buildSectionCard(
                  title: 'Conectar conmigo',
                  children: [
                    // Fila de botones mejorados
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            icon: Icons.code,
                            label: 'GitHub',
                            gradient: const [Color(0xFF333333), Color(0xFF1A1A1A)],
                            onTap: () => _launchUrl('https://github.com/JosePablo1996'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSocialButton(
                            icon: Icons.email,
                            label: 'Email',
                            gradient: [Colors.red.shade400, Colors.red.shade600],
                            onTap: () => _launchUrl('mailto:jose.miranda@quicknote.com'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSocialButton(
                      icon: Icons.business,
                      label: 'LinkedIn',
                      gradient: [Colors.blue.shade700, Colors.blue.shade900],
                      onTap: () => _launchUrl('https://linkedin.com/in/jose-pablo-miranda'),
                      isFullWidth: true,
                    ),
                  ],
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 20),

                // ===== BADGE DE MODO DESARROLLADOR =====
                if (_isDeveloperMode)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Modo Desarrollador Activo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  // Widget para las tarjetas de sección
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required bool isDarkMode,
  }) {
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para botones sociales mejorados
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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