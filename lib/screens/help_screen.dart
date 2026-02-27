import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/snackbar_utils.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<String> _categories = [
    'General',
    'Notas',
    'Sincronización',
    'Seguridad',
    'Backup',
    'Papelera',
  ];

  // Controlador para el dropdown de preguntas frecuentes
  String? _expandedFaq;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===== FUNCIONES PARA MOSTRAR MODALES DE CATEGORÍAS =====

  void _showGeneralModal(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _buildCategoryModal(
          titulo: 'Información General',
          icono: Icons.home,
          color: Colors.blue,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalSection(
                '📱 Acerca de QuickNote',
                'QuickNote es una aplicación de notas moderna y elegante diseñada para ayudarte a organizar tus ideas de manera rápida y eficiente. Desarrollada con Flutter, ofrece una experiencia fluida y personalizable.',
                isDarkMode,
              ),
              _buildModalSection(
                '✨ Características principales',
                '• Interfaz intuitiva y moderna\n• Modo oscuro/claro\n• Organización por categorías\n• Búsqueda avanzada\n• Personalización de colores\n• Sistema de etiquetas',
                isDarkMode,
              ),
              _buildModalSection(
                '💡 Consejos rápidos',
                '• Usa el botón + para crear notas rápidamente\n• Mantén presionada una nota para ver más opciones\n• Organiza tus notas con etiquetas de colores\n• Activa el modo oscuro para ahorrar batería',
                isDarkMode,
              ),
              _buildModalSection(
                '📊 Estadísticas',
                '• Versión actual: 2.2.0\n• Desarrollador: José Pablo Miranda Quintanilla\n• Licencia: MIT\n• Actualización: Febrero 2026',
                isDarkMode,
              ),
            ],
          ),
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _showNotasModal(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _buildCategoryModal(
          titulo: 'Centro de Ayuda - Notas',
          icono: Icons.note,
          color: Colors.green,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalSection(
                '📝 Crear una nota',
                '• Toca el botón "+" en la esquina inferior derecha\n• Completa el título y contenido\n• Selecciona un color para identificarla fácilmente\n• Agrega etiquetas para organizar mejor',
                isDarkMode,
              ),
              _buildModalSection(
                '✏️ Editar una nota',
                '• Toca la nota que deseas editar\n• Modifica el contenido\n• Los cambios se guardan automáticamente\n• Puedes cambiar el color y etiquetas',
                isDarkMode,
              ),
              _buildModalSection(
                '⭐ Favoritos',
                '• Marca notas como favoritas para acceder rápido\n• Usa el icono de estrella en la nota\n• Filtra por favoritos en el menú lateral',
                isDarkMode,
              ),
              _buildModalSection(
                '🏷️ Etiquetas',
                '• Las etiquetas ayudan a organizar tus notas\n• Puedes filtrar por etiqueta\n• Cada nota puede tener múltiples etiquetas\n• Las etiquetas se muestran con colores',
                isDarkMode,
              ),
            ],
          ),
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _showSincronizacionModal(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _buildCategoryModal(
          titulo: 'Centro de Ayuda - Sincronización',
          icono: Icons.sync,
          color: Colors.purple,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalSection(
                '🔄 Sincronización automática',
                '• Las notas se sincronizan automáticamente\n• Requiere conexión a internet\n• Los cambios se reflejan en todos tus dispositivos\n• La sincronización es en tiempo real',
                isDarkMode,
              ),
              _buildModalSection(
                '📶 Estado de sincronización',
                '• Icono verde: sincronizado correctamente\n• Icono amarillo: sincronizando\n• Icono rojo: error de conexión\n• Puedes forzar sincronización manual',
                isDarkMode,
              ),
              _buildModalSection(
                '💾 Datos sin conexión',
                '• Puedes trabajar sin internet\n• Los cambios se guardan localmente\n• Se sincronizan automáticamente al reconectar\n• Sin límite de notas offline',
                isDarkMode,
              ),
            ],
          ),
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _showSeguridadModal(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _buildCategoryModal(
          titulo: 'Centro de Ayuda - Seguridad',
          icono: Icons.lock,
          color: Colors.red,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalSection(
                '🔐 Bloqueo de aplicación',
                '• Configura PIN de 4-6 dígitos\n• Patrón de desbloqueo personalizado\n• Autenticación biométrica (huella/rostro)\n• Acceso desde Ajustes > Seguridad',
                isDarkMode,
              ),
              _buildModalSection(
                '🛡️ Privacidad',
                '• Tus notas son privadas\n• Sin acceso a datos personales\n• Las notas se almacenan de forma segura\n• Puedes borrar datos locales',
                isDarkMode,
              ),
              _buildModalSection(
                '⏱️ Tiempo de bloqueo',
                '• Bloqueo inmediato al salir\n• Bloqueo después de inactividad\n• Configurable en ajustes\n• Protección contra accesos no autorizados',
                isDarkMode,
              ),
            ],
          ),
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _showBackupModal(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _buildCategoryModal(
          titulo: 'Centro de Ayuda - Backup',
          icono: Icons.backup,
          color: Colors.green,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalSection(
                '💾 Crear backup',
                '• Ve a Ajustes > Respaldo manual\n• Selecciona "Crear backup"\n• Elige ubicación de guardado\n• El backup incluye todas tus notas',
                isDarkMode,
              ),
              _buildModalSection(
                '🔄 Restaurar backup',
                '• Accede a Ajustes > Respaldo manual\n• Selecciona "Restaurar"\n• Elige el archivo de backup\n• Confirma la restauración',
                isDarkMode,
              ),
              _buildModalSection(
                '📅 Backup automático',
                '• Configurable en ajustes\n• Periodicidad: diaria/semanal/mensual\n• Máximo 5 backups automáticos\n• Notificaciones de backup exitoso',
                isDarkMode,
              ),
            ],
          ),
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _showPapeleraModal(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _buildCategoryModal(
          titulo: 'Centro de Ayuda - Papelera',
          icono: Icons.delete,
          color: Colors.orange,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalSection(
                '🗑️ ¿Cómo funciona la papelera?',
                '• Las notas eliminadas van a la papelera\n• Permite recuperar notas borradas\n• Espacio seguro antes de eliminación permanente\n• Acceso desde menú lateral',
                isDarkMode,
              ),
              _buildModalSection(
                '♻️ Restaurar notas',
                '• Abre la pantalla de Papelera\n• Selecciona la nota a restaurar\n• Toca el icono de restaurar (♻️)\n• La nota vuelve a la lista principal',
                isDarkMode,
              ),
              _buildModalSection(
                '⏳ Tiempo en papelera',
                '• Las notas permanecen 30 días\n• Después se eliminan automáticamente\n• Puedes vaciar la papelera manualmente\n• Eliminación permanente requiere confirmación',
                isDarkMode,
              ),
              _buildModalSection(
                '⚡ Consejos',
                '• Revisa la papelera periódicamente\n• Restaura notas importantes a tiempo\n• Usa selección múltiple para acciones en lote\n• Las notas eliminadas NO ocupan espacio',
                isDarkMode,
              ),
            ],
          ),
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  Widget _buildCategoryModal({
    required String titulo,
    required IconData icono,
    required Color color,
    required Widget contenido,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.grey[850]!.withValues(alpha: 0.95),
                  Colors.grey[900]!.withValues(alpha: 0.9),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.grey[50]!.withValues(alpha: 0.9),
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
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del modal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icono, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Contenido del modal
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: contenido,
                ),
              ),
              // Botón de cerrar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalSection(String titulo, String contenido, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]!.withValues(alpha: 0.3)
                  : Colors.grey[100]!.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.grey[700]!.withValues(alpha: 0.2)
                    : Colors.grey[300]!.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              contenido,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Centro de Ayuda',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== HEADER CON BIENVENIDA =====
          _buildWelcomeHeader(isDarkMode),
          
          const SizedBox(height: 24),

          // ===== CATEGORÍAS EN GRID =====
          _buildCategoriesGrid(isDarkMode),

          const SizedBox(height: 24),

          // ===== PREGUNTAS FRECUENTES =====
          _buildFaqSection(isDarkMode),

          const SizedBox(height: 24),

          // ===== CONTACTO Y SOPORTE =====
          _buildContactSection(isDarkMode),

          const SizedBox(height: 24),

          // ===== ESTADÍSTICAS DE USO =====
          _buildStatsSection(isDarkMode),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========== WIDGETS ==========

  Widget _buildWelcomeHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Necesitas ayuda?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Explora nuestras guías y recursos',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar ayuda...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        SnackbarUtils.showInfoSnackbar(
                          context,
                          'Buscando: $value',
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
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
                'Categorías',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(
              category,
              isDarkMode,
              _getCategoryIcon(category),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String category,
    bool isDarkMode,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        // Mostrar modal según la categoría
        switch (category) {
          case 'General':
            _showGeneralModal(isDarkMode);
            break;
          case 'Notas':
            _showNotasModal(isDarkMode);
            break;
          case 'Sincronización':
            _showSincronizacionModal(isDarkMode);
            break;
          case 'Seguridad':
            _showSeguridadModal(isDarkMode);
            break;
          case 'Backup':
            _showBackupModal(isDarkMode);
            break;
          case 'Papelera':
            _showPapeleraModal(isDarkMode);
            break;
        }
      },
      child: Container(
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey[700]!.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
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
                'Preguntas Frecuentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        Container(
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
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFaqItem(
                      '¿Cómo crear una nota?',
                      'Para crear una nota, haz clic en el botón "+" en la esquina inferior derecha de la pantalla principal. Luego, completa el título y el contenido, selecciona un color y guarda.',
                      isDarkMode,
                    ),
                    _buildFaqItem(
                      '¿Cómo eliminar una nota?',
                      'Puedes eliminar una nota manteniendo presionada la tarjeta y seleccionando "Eliminar", o desde el menú de opciones. Las notas eliminadas van a la Papelera.',
                      isDarkMode,
                    ),
                    _buildFaqItem(
                      '¿Cómo restaurar una nota de la papelera?',
                      'Ve a la Papelera desde el menú lateral, selecciona la nota y haz clic en el icono de restaurar (♻️). La nota volverá a tu lista principal.',
                      isDarkMode,
                    ),
                    _buildFaqItem(
                      '¿Cómo hacer backup de mis notas?',
                      'En Ajustes > Respaldo manual, puedes crear copias de seguridad locales. También puedes activar el backup automático programado.',
                      isDarkMode,
                    ),
                    _buildFaqItem(
                      '¿Cómo cambiar entre modo oscuro y claro?',
                      'Usa el botón de tema en la esquina superior derecha del header, o ve a Ajustes > Apariencia > Modo oscuro.',
                      isDarkMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isDarkMode) {
    final isExpanded = _expandedFaq == question;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedFaq = isExpanded ? null : question;
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
        const Divider(
          height: 1,
        ),
      ],
    );
  }

  Widget _buildContactSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.headset_mic, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Necesitas más ayuda?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Contáctanos directamente',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.email,
                      label: 'Email',
                      color: Colors.blue,
                      onTap: () {
                        SnackbarUtils.showInfoSnackbar(
                          context,
                          'soporte@quicknote.com',
                        );
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.chat,
                      label: 'Chat',
                      color: Colors.green,
                      onTap: () {
                        SnackbarUtils.showInfoSnackbar(
                          context,
                          'Chat en vivo - Próximamente',
                        );
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.help_center,
                      label: 'FAQ',
                      color: Colors.purple,
                      onTap: () {
                        // Ya estamos en FAQ
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.feedback,
                      label: 'Feedback',
                      color: Colors.orange,
                      onTap: () {
                        SnackbarUtils.showInfoSnackbar(
                          context,
                          'Feedback - Próximamente',
                        );
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.amber.shade900.withValues(alpha: 0.2), Colors.orange.shade900.withValues(alpha: 0.1)]
              : [Colors.amber.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.amber.shade800.withValues(alpha: 0.3)
              : Colors.amber.shade200.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo del día',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Usa la papelera para recuperar notas eliminadas hasta 30 días después.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'General':
        return Icons.home;
      case 'Notas':
        return Icons.note;
      case 'Sincronización':
        return Icons.sync;
      case 'Seguridad':
        return Icons.lock;
      case 'Backup':
        return Icons.backup;
      case 'Papelera':
        return Icons.delete;
      default:
        return Icons.help;
    }
  }
}