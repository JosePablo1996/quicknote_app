import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';

class SecuritySetupScreen extends StatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  int _selectedMethod = 0;
  String? _tempPin;
  bool _isConfirming = false;
  bool _biometricEnabled = false;

  String _getCurrentMethodText(SecurityProvider provider) {
    switch (provider.currentMethod) {
      case SecurityMethod.pin:
        return 'PIN de 4 dígitos';
      case SecurityMethod.biometric:
        return 'Biometría (Huella digital)';
      case SecurityMethod.none:
        return 'Sin método de seguridad';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Seguridad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner mejorado visualmente
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: securityProvider.currentMethod != SecurityMethod.none
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.orange.shade50, Colors.orange.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: securityProvider.currentMethod != SecurityMethod.none
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (securityProvider.currentMethod != SecurityMethod.none
                      ? Colors.green
                      : Colors.orange).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono grande
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (securityProvider.currentMethod != SecurityMethod.none
                        ? Colors.green
                        : Colors.orange).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    securityProvider.currentMethod != SecurityMethod.none
                        ? Icons.security
                        : Icons.warning_amber_rounded,
                    color: securityProvider.currentMethod != SecurityMethod.none
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        securityProvider.currentMethod != SecurityMethod.none
                            ? 'Método activo'
                            : 'Atención',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: securityProvider.currentMethod != SecurityMethod.none
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCurrentMethodText(securityProvider),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: securityProvider.currentMethod != SecurityMethod.none
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Selecciona tu método de seguridad preferido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Opción PIN con indicador verde a la izquierda
          _buildSecurityOption(
            icon: Icons.pin,
            title: 'PIN de 4 dígitos',
            subtitle: 'Código numérico rápido',
            index: 1,
            isDarkMode: isDarkMode,
            isConfigured: securityProvider.currentMethod == SecurityMethod.pin,
          ),
          
          // Opción Biometría con indicador verde a la izquierda
          if (securityProvider.biometricAvailable)
            _buildSecurityOption(
              icon: Icons.fingerprint,
              title: 'Biometría',
              subtitle: 'Huella digital',
              index: 3,
              isDarkMode: isDarkMode,
              isConfigured: securityProvider.currentMethod == SecurityMethod.biometric,
            ),
          
          const SizedBox(height: 30),
          
          // Configuración según método seleccionado
          if (_selectedMethod == 1) _buildPinSetup(isDarkMode),
          if (_selectedMethod == 3) _buildBiometricSetup(isDarkMode, securityProvider),
          
          const SizedBox(height: 30),
          
          // Botón de guardar (solo para PIN)
          if (_selectedMethod == 1 && _tempPin != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _saveSecurity(securityProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar configuración',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          
          // Botón para deshabilitar seguridad (si hay método configurado)
          if (securityProvider.currentMethod != SecurityMethod.none)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: OutlinedButton(
                onPressed: () => _disableSecurity(securityProvider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Deshabilitar seguridad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required bool isDarkMode,
    bool isConfigured = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfigured
              ? Colors.green.shade400
              : (_selectedMethod == index
                  ? Colors.blue
                  : (isDarkMode ? Colors.grey[700]! : Colors.grey[200]!)),
          width: isConfigured ? 2 : (_selectedMethod == index ? 2 : 1),
        ),
        boxShadow: isConfigured
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: RadioListTile<int>(
        value: index,
        groupValue: _selectedMethod,
        onChanged: (value) {
          setState(() {
            _selectedMethod = value!;
            _tempPin = null;
            _isConfirming = false;
            _biometricEnabled = false;
          });
        },
        activeColor: Colors.blue,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        title: Row(
          children: [
            // Indicador verde a la izquierda del título
            if (isConfigured) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(left: isConfigured ? 16 : 0),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinSetup(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            _isConfirming ? 'Confirma tu PIN' : 'Establece tu PIN de 4 dígitos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          PinCodeTextField(
            appContext: context,
            length: 4,
            onChanged: (value) {},
            onCompleted: (value) {
              if (!_isConfirming) {
                setState(() {
                  _tempPin = value;
                  _isConfirming = true;
                });
              } else {
                if (value == _tempPin) {
                  setState(() {});
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Los PIN no coinciden'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  setState(() {
                    _tempPin = null;
                    _isConfirming = false;
                  });
                }
              }
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 60,
              fieldWidth: 50,
              activeColor: Colors.blue,
              inactiveColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              selectedColor: Colors.blue,
            ),
            keyboardType: TextInputType.number,
            enableActiveFill: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSetup(bool isDarkMode, SecurityProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Configurar autenticación biométrica',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          
          if (!provider.biometricAvailable) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    provider.biometricError ?? 'Biometría no disponible',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Asegúrate de tener huellas digitales configuradas en el sistema',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else if (!_biometricEnabled) ...[
            ElevatedButton.icon(
              onPressed: () async {
                print('🔐 Iniciando prueba de biometría...');
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                final authenticated = await provider.authenticateBiometrics();
                
                if (context.mounted) {
                  Navigator.pop(context);
                  
                  if (authenticated) {
                    setState(() {
                      _biometricEnabled = true;
                    });
                    
                    await provider.setSecurityMethod(SecurityMethod.biometric);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Biometría configurada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.biometricError ?? 
                          '❌ Error al verificar biometría. Intenta de nuevo.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.fingerprint),
              label: const Text('Configurar biometría'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          
          if (_biometricEnabled) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ Biometría verificada. Configuración guardada.',
                      style: TextStyle(color: Colors.green),
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

  Future<void> _saveSecurity(SecurityProvider provider) async {
    if (_selectedMethod == 1 && _tempPin != null) {
      await provider.setSecurityMethod(SecurityMethod.pin, pin: _tempPin);
      if (mounted) {
        _showSuccessDialog('PIN configurado correctamente');
      }
    }
  }

  Future<void> _disableSecurity(SecurityProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deshabilitar seguridad'),
        content: const Text('¿Estás seguro? La app ya no requerirá autenticación.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deshabilitar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.disableSecurity();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}