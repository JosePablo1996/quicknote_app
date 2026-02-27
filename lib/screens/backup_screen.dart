import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../models/backup_history.dart';
import '../services/backup_service.dart'; // 👈 NUEVO SERVICIO

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> with TickerProviderStateMixin {
  final BackupService _backupService = BackupService();
  
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isDeleting = false;
  bool _autoBackupEnabled = false;
  
  double _backupProgress = 0.0;
  double _restoreProgress = 0.0;
  
  late AnimationController _backupAnimationController;
  late AnimationController _restoreAnimationController;

  List<BackupFileInfo> _backupFiles = [];
  List<BackupHistory> _backupHistory = [];
  bool _isLoadingFiles = false;
  
  // Opciones de intervalo para backup automático
  final List<int> _intervalOptions = [1, 3, 6, 12, 24];
  int _selectedInterval = 1;
  String _lastAutoBackup = 'Nunca';
  Timer? _autoBackupTimer;

  @override
  void initState() {
    super.initState();
    
    _backupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _backupProgress = _backupAnimationController.value * 100;
          });
        }
      });

    _restoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _restoreProgress = _restoreAnimationController.value * 100;
          });
        }
      });

    // Cargar datos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _backupAnimationController.dispose();
    _restoreAnimationController.dispose();
    _autoBackupTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadBackupFiles();
    await _loadBackupHistory();
    await _loadAutoBackupSettings();
  }

  // ========== CARGAR LISTA DE BACKUPS ==========

  Future<void> _loadBackupFiles() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingFiles = true;
      _backupFiles.clear();
    });

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final backupFolder = Directory('${directory.path}/QuickNote/backups');
        
        if (await backupFolder.exists()) {
          final files = await backupFolder.list().toList();
          final jsonFiles = files.whereType<File>().where((file) => 
            file.path.endsWith('.json') && !file.path.contains('history')
          ).toList();
          
          for (var file in jsonFiles) {
            try {
              final content = await file.readAsString();
              final jsonData = jsonDecode(content);
              
              final backupInfo = BackupFileInfo(
                file: file,
                fileName: file.path.split('/').last,
                fileSize: file.lengthSync(),
                modified: file.lastModifiedSync(),
                noteCount: jsonData['total_notes'] ?? 
                           (jsonData['notes'] as List?)?.length ?? 0,
                timestamp: jsonData['timestamp'] ?? 'Fecha desconocida',
                version: jsonData['version'] ?? 'Desconocida',
                isAccumulative: jsonData['based_on'] != null,
                newNotes: (jsonData['new_notes'] as List?)?.length ?? 0,
              );
              _backupFiles.add(backupInfo);
            } catch (e) {
              _backupFiles.add(BackupFileInfo(
                file: file,
                fileName: file.path.split('/').last,
                fileSize: file.lengthSync(),
                modified: file.lastModifiedSync(),
                noteCount: 0,
                timestamp: 'Archivo corrupto',
                version: 'Desconocida',
                isAccumulative: false,
                newNotes: 0,
              ));
            }
          }
          
          _backupFiles.sort((a, b) => b.modified.compareTo(a.modified));
        }
      }
    } catch (e) {
      // Silencioso
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFiles = false;
        });
      }
    }
  }

  Future<void> _loadBackupHistory() async {
    await _backupService.loadHistory();
    setState(() {
      _backupHistory = _backupService.getHistory();
    });
  }

  Future<void> _loadAutoBackupSettings() async {
    // Cargar desde SharedPreferences si lo implementas
    // Por ahora valores por defecto
  }

  // ========== BACKUP ACUMULATIVO ==========

  Future<void> _performAccumulativeBackup() async {
    if (!mounted) return;
    
    setState(() {
      _isBackingUp = true;
      _backupProgress = 0.0;
    });

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final currentNotes = noteProvider.getNotesForBackup();
      
      if (mounted) setState(() => _backupProgress = 20);

      if (currentNotes.isEmpty) {
        _showWarningSnackbar('⚠️ No hay notas para respaldar');
        setState(() => _isBackingUp = false);
        return;
      }

      setState(() => _backupProgress = 40);

      final fileName = await _backupService.performAccumulativeBackup(currentNotes);
      
      setState(() => _backupProgress = 80);
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _backupProgress = 100);

      await _loadBackupFiles();
      await _loadBackupHistory();
      
      if (fileName != null) {
        final totalNotes = currentNotes.length;
        final previousTotal = _backupHistory.length > 1 ? _backupHistory[1].totalNotes : 0;
        final newNotes = totalNotes - previousTotal;
        
        String message = '✅ Backup completado: $totalNotes notas';
        if (newNotes > 0) {
          message = '✅ Backup +$newNotes notas nuevas (Total: $totalNotes)';
        }
        
        _showSuccessSnackbar(message);
      }
    } catch (e) {
      _showErrorSnackbar('❌ Error al crear backup');
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  // ========== RESTORE ==========

  Future<void> _performRestore({BackupFileInfo? backupInfo}) async {
    if (!mounted) return;
    
    setState(() {
      _isRestoring = true;
      _restoreProgress = 0.0;
    });

    try {
      BackupFileInfo infoToRestore = backupInfo ?? _backupFiles.first;
      
      setState(() => _restoreProgress = 20);

      final jsonString = await infoToRestore.file.readAsString();
      final backupData = jsonDecode(jsonString);
      
      setState(() => _restoreProgress = 40);

      if (backupData['notes'] == null) {
        throw Exception('El archivo de backup no contiene notas válidas');
      }
      
      final notesJson = backupData['notes'] as List;
      final restoredNotes = <Note>[];
      
      for (var noteJson in notesJson) {
        try {
          final safeJson = {
            'id': noteJson['id'] ?? 0,
            'title': noteJson['title'] ?? 'Sin título',
            'content': noteJson['content'] ?? '',
            'created_at': noteJson['created_at'] ?? noteJson['createdAt'] ?? DateTime.now().toIso8601String(),
            'updated_at': noteJson['updated_at'] ?? noteJson['updatedAt'],
            'is_favorite': noteJson['is_favorite'] ?? false,
            'tags': noteJson['tags'] ?? [],
            'color_hex': noteJson['color_hex'],
          };
          restoredNotes.add(Note.fromJson(safeJson));
        } catch (e) {
          // Ignorar notas con error
        }
      }
      
      setState(() => _restoreProgress = 60);

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      final confirm = await _showRestoreConfirmationDialog(restoredNotes.length, infoToRestore);
      if (!confirm) {
        setState(() => _isRestoring = false);
        return;
      }
      
      setState(() => _restoreProgress = 80);

      await noteProvider.replaceAllNotes(restoredNotes);
      
      setState(() => _restoreProgress = 100);
      
      String message = '✅ Notas restauradas: ${restoredNotes.length}';
      if (infoToRestore.isAccumulative && infoToRestore.newNotes > 0) {
        message = '✅ Restauradas: ${restoredNotes.length} notas (${infoToRestore.newNotes} nuevas del backup)';
      }
      
      _showSuccessSnackbar(message);
    } catch (e) {
      _showErrorSnackbar('❌ Error al restaurar');
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  // ========== ELIMINAR BACKUP ==========

  Future<void> _deleteBackup(BackupFileInfo backupInfo) async {
    final confirm = await _showDeleteConfirmationDialog(backupInfo.fileName);
    if (!confirm) return;

    setState(() => _isDeleting = true);

    try {
      await backupInfo.file.delete();
      await _loadBackupFiles();
      await _loadBackupHistory();
      _showSuccessSnackbar('✅ Backup eliminado');
    } catch (e) {
      _showErrorSnackbar('❌ Error al eliminar');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // ========== BACKUP AUTOMÁTICO ==========

  void _toggleAutoBackup(bool enabled) {
    setState(() {
      _autoBackupEnabled = enabled;
    });
    
    if (enabled) {
      _startAutoBackup();
      _showSuccessSnackbar('✅ Backup automático activado (cada $_selectedInterval hora)');
    } else {
      _autoBackupTimer?.cancel();
      _showWarningSnackbar('⏸️ Backup automático desactivado');
    }
  }

  void _startAutoBackup() {
    _autoBackupTimer?.cancel();
    
    _autoBackupTimer = Timer.periodic(
      Duration(hours: _selectedInterval),
      (timer) async {
        await _performAccumulativeBackup();
        setState(() {
          final now = DateTime.now();
          _lastAutoBackup = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
        });
      },
    );
  }

  void _updateInterval(int hours) {
    setState(() {
      _selectedInterval = hours;
    });
    
    if (_autoBackupEnabled) {
      _startAutoBackup();
      _showSuccessSnackbar('⏱️ Intervalo actualizado a $hours hora(s)');
    }
  }

  // ========== DIÁLOGOS ==========

  Future<bool> _showRestoreConfirmationDialog(int noteCount, BackupFileInfo info) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar notas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Se restaurarán las siguientes notas:'),
              const SizedBox(height: 16),
              _buildBackupDetailsCard(info),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Las notas actuales serán reemplazadas',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildBackupDetailsCard(BackupFileInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              info.fileName.length > 40 ? '${info.fileName.substring(0, 37)}...' : info.fileName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDetailChip(
                icon: Icons.description,
                label: 'Notas',
                value: '${info.noteCount}',
                color: Colors.blue,
              ),
              _buildDetailChip(
                icon: Icons.calendar_today,
                label: 'Fecha',
                value: _formatDetailedDate(info.modified),
                color: Colors.green,
              ),
              _buildDetailChip(
                icon: Icons.access_time,
                label: 'Hora',
                value: _formatTime(info.modified),
                color: Colors.purple,
              ),
              _buildDetailChip(
                icon: Icons.sd_storage,
                label: 'Tamaño',
                value: _formatFileSize(info.fileSize),
                color: Colors.orange,
              ),
              _buildDetailChip(
                icon: Icons.label,
                label: 'Versión',
                value: info.version,
                color: Colors.teal,
              ),
              if (info.isAccumulative)
                _buildDetailChip(
                  icon: Icons.trending_up,
                  label: 'Nuevas',
                  value: '+${info.newNotes}',
                  color: Colors.pink,
                ),
            ],
          ),
          
          if (info.timestamp != 'Fecha desconocida') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Backup: ${info.timestamp}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(String fileName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Eliminar permanentemente?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                '📁 ${fileName.length > 40 ? '${fileName.substring(0, 37)}...' : fileName}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }

  // ========== SNACKBARS ==========

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showWarningSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ========== UTILIDADES ==========

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDetailedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final fileDate = DateTime(date.year, date.month, date.day);

    if (fileDate == today) return 'Hoy';
    if (fileDate == yesterday) return 'Ayer';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getProgressColor(double progress) {
    if (progress < 33) return Colors.amber.shade400;
    if (progress < 66) return Colors.orange.shade600;
    return Colors.green.shade500;
  }

  String _getProgressText(double progress, String action) {
    if (progress == 0) return 'Iniciando...';
    if (progress < 25) return 'Accediendo al almacenamiento...';
    if (progress < 50) return 'Procesando notas...';
    if (progress < 75) return 'Guardando...';
    if (progress < 100) return 'Finalizando...';
    return '¡Completado!';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Respaldo de Notas', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDarkMode ? Colors.white70 : Colors.grey[700], size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDarkMode ? Colors.white70 : Colors.grey[700]),
            onPressed: _loadInitialData,
            tooltip: 'Actualizar',
          ),
        ],
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
          // HEADER
          _buildHeader(isDarkMode),
          const SizedBox(height: 24),

          // BACKUP AUTOMÁTICO
          _buildAutoBackupCard(isDarkMode),
          const SizedBox(height: 16),

          // BACKUP ACUMULATIVO
          _buildAccumulativeBackupOption(isDarkMode),
          const SizedBox(height: 16),

          // HISTORIAL DE BACKUPS
          if (_backupHistory.isNotEmpty) ...[
            _buildHistorySection(isDarkMode),
            const SizedBox(height: 16),
          ],

          // BACKUP MANUAL (LEGACY)
          _buildBackupOption(
            icon: Icons.backup,
            title: 'Backup Manual',
            description: 'Crea una copia de seguridad manual de todas tus notas',
            color: Colors.blue,
            isProcessing: _isBackingUp,
            progress: _backupProgress,
            onTap: _performAccumulativeBackup,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),

          // BACKUP RECIENTE
          if (_backupFiles.isNotEmpty) ...[
            _buildRecentBackupCard(_backupFiles.first, isDarkMode),
            const SizedBox(height: 16),
            
            // LISTA DE BACKUPS
            _buildSectionHeader('Todos los backups', isDarkMode),
            const SizedBox(height: 8),
            _isLoadingFiles
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: _backupFiles.map((info) => 
                      _buildBackupFileTile(info, isDarkMode)
                    ).toList(),
                  ),
          ],

          // EMPTY STATE
          if (_backupFiles.isEmpty && !_isLoadingFiles) ...[
            _buildEmptyState(isDarkMode),
          ],

          const SizedBox(height: 16),
          
          // INFO CARD
          _buildInfoCard(isDarkMode),
        ],
      ),
    );
  }

  // ========== WIDGETS ==========

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.storage, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Almacenamiento Local',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('QuickNote/backups/',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoBackupCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[850]!.withValues(alpha: 0.7), Colors.grey[900]!.withValues(alpha: 0.5)]
              : [Colors.white.withValues(alpha: 0.8), Colors.grey[50]!.withValues(alpha: 0.6)],
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
            color: Colors.purple.withValues(alpha: 0.15),
            blurRadius: 20,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.schedule, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Backup Automático',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Switch(
                      value: _autoBackupEnabled,
                      onChanged: _toggleAutoBackup,
                      activeColor: Colors.purple,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                if (_autoBackupEnabled) ...[
                  Row(
                    children: [
                      const Text('Intervalo:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: _selectedInterval,
                        items: _intervalOptions.map((hours) {
                          return DropdownMenuItem(
                            value: hours,
                            child: Text('$hours hora${hours > 1 ? 's' : ''}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _updateInterval(value);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.purple.shade900.withValues(alpha: 0.2)
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.purple.shade800.withValues(alpha: 0.3)
                            : Colors.purple.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, 
                             color: isDarkMode ? Colors.purple.shade200 : Colors.purple.shade700,
                             size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Último backup: $_lastAutoBackup',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode ? Colors.purple.shade200 : Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Los backups son acumulativos: conservan notas anteriores + nuevas',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Activa el backup automático para que QuickNote guarde periódicamente el estado acumulativo de tus notas.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccumulativeBackupOption(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[850]!.withValues(alpha: 0.7), Colors.grey[900]!.withValues(alpha: 0.5)]
              : [Colors.white.withValues(alpha: 0.8), Colors.grey[50]!.withValues(alpha: 0.6)],
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
            color: Colors.green.withValues(alpha: 0.15),
            blurRadius: 20,
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.teal],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backup Acumulativo',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Conserva notas anteriores + nuevas',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isBackingUp ? null : _performAccumulativeBackup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Respaldar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[850]!.withValues(alpha: 0.7), Colors.grey[900]!.withValues(alpha: 0.5)]
              : [Colors.white.withValues(alpha: 0.8), Colors.grey[50]!.withValues(alpha: 0.6)],
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
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      'Historial de Backups',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _backupHistory.length > 5 ? 5 : _backupHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final backup = _backupHistory[index];
                    final isLatest = index == 0;
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLatest
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLatest
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLatest ? Icons.new_releases : Icons.backup,
                            size: 16,
                            color: isLatest ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${backup.timestamp.day}/${backup.timestamp.month} ${backup.timestamp.hour}:${backup.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                if (backup.newNotesIds.isNotEmpty)
                                  Text(
                                    '+${backup.newNotesIds.length} nuevas',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${backup.totalNotes} notas',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (backup.basedOn != null)
                                Text(
                                  'acumulativo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                if (_backupHistory.length > 5) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'y ${_backupHistory.length - 5} más...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
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

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
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

  Widget _buildBackupFileTile(BackupFileInfo info, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[850]!.withValues(alpha: 0.6), Colors.grey[900]!.withValues(alpha: 0.4)]
              : [Colors.white.withValues(alpha: 0.7), Colors.grey[50]!.withValues(alpha: 0.5)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]!.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.8),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: info.isAccumulative
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            info.isAccumulative ? Icons.auto_awesome : Icons.backup,
            color: info.isAccumulative ? Colors.green : Colors.amber,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                info.fileName.length > 25 ? '${info.fileName.substring(0, 22)}...' : info.fileName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ),
            if (info.isAccumulative)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ACUM',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
          ],
        ),
        subtitle: Wrap(
          spacing: 4,
          runSpacing: 2,
          children: [
            if (info.noteCount > 0)
              Text('📝 ${info.noteCount}', style: const TextStyle(fontSize: 11)),
            Text('📦 ${_formatFileSize(info.fileSize)}', style: const TextStyle(fontSize: 11)),
            Text('🕒 ${_formatDetailedDate(info.modified)}', style: const TextStyle(fontSize: 11)),
            if (info.newNotes > 0)
              Text('✨ +${info.newNotes}', style: const TextStyle(fontSize: 11, color: Colors.green)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.restore, color: Colors.green, size: 22),
              onPressed: info.noteCount > 0 && !_isRestoring ? () => _performRestore(backupInfo: info) : null,
              tooltip: 'Restaurar',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 22),
              onPressed: _isDeleting ? null : () => _deleteBackup(info),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBackupCard(BackupFileInfo info, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _performRestore(backupInfo: info),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.restore, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Último backup',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(_formatDetailedDate(info.modified),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRecentInfoItem(Icons.description, 'Notas', '${info.noteCount}'),
                      _buildRecentInfoItem(Icons.access_time, 'Hora', _formatTime(info.modified)),
                      _buildRecentInfoItem(Icons.sd_storage, 'Tamaño', _formatFileSize(info.fileSize)),
                      if (info.isAccumulative && info.newNotes > 0)
                        _buildRecentInfoItem(Icons.trending_up, 'Nuevas', '+${info.newNotes}'),
                    ],
                  ),
                ),
                if (info.isAccumulative) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Backup acumulativo',
                          style: TextStyle(color: Colors.white, fontSize: 10),
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

  Widget _buildRecentInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBackupOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isProcessing,
    required double progress,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[850]!.withValues(alpha: 0.7), Colors.grey[900]!.withValues(alpha: 0.5)]
              : [Colors.white.withValues(alpha: 0.8), Colors.grey[50]!.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]!.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.9),
          width: 2,
        ),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)]),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                if (isProcessing) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getProgressText(progress, ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(progress),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: isDarkMode
                              ? Colors.grey[700]!.withValues(alpha: 0.3)
                              : Colors.grey[300]!.withValues(alpha: 0.5),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: 8,
                          width: (progress / 100) * MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              _getProgressColor(progress).withValues(alpha: 0.7),
                              _getProgressColor(progress),
                            ]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: color.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                progress < 100 ? 'Procesando...' : 'Completado',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : const Text(
                            'Iniciar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800]!.withValues(alpha: 0.3) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.grey[700]!.withValues(alpha: 0.2) : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.backup_outlined, size: 48, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay backups disponibles',
            style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer backup con el botón "Respaldar"',
            style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[500] : Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDarkMode) {
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
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Información', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  '✓ Backup acumulativo: conserva notas anteriores + nuevas\n'
                  '✓ Backup automático: programado cada X horas\n'
                  '✓ Restore: recupera desde cualquier punto\n'
                  '✓ Eliminar: borra backups antiguos',
                  style: TextStyle(fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackupFileInfo {
  final File file;
  final String fileName;
  final int fileSize;
  final DateTime modified;
  final int noteCount;
  final String timestamp;
  final String version;
  final bool isAccumulative;
  final int newNotes;

  BackupFileInfo({
    required this.file,
    required this.fileName,
    required this.fileSize,
    required this.modified,
    required this.noteCount,
    required this.timestamp,
    required this.version,
    this.isAccumulative = false,
    this.newNotes = 0,
  });
}