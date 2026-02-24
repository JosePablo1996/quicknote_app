import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';

class AuthMethodSelector extends StatefulWidget {
  const AuthMethodSelector({super.key});

  @override
  State<AuthMethodSelector> createState() => _AuthMethodSelectorState();
}

class _AuthMethodSelectorState extends State<AuthMethodSelector> {
  SecurityMethod? _selectedMethod;
  String? _pinError;
  String? _patternError;
  final List<int> _pattern = [];
  final int _patternSize = 9;
  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  'QuickNote',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                const Text(
                  'Selecciona método de autenticación',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Selector de métodos
                if (_selectedMethod == null) ...[
                  _buildMethodButton(
                    icon: Icons.pin,
                    title: 'Usar PIN',
                    isAvailable: securityProvider.hasPin,
                    onTap: () {
                      setState(() {
                        _selectedMethod = SecurityMethod.pin;
                      });
                    },
                  ),
                  
                  if (securityProvider.hasPattern)
                    _buildMethodButton(
                      icon: Icons.grid_3x3,
                      title: 'Usar Patrón',
                      isAvailable: true,
                      onTap: () {
                        setState(() {
                          _selectedMethod = SecurityMethod.pattern;
                        });
                      },
                    ),
                  
                  if (securityProvider.biometricAvailable)
                    _buildBiometricButton(securityProvider),
                ],
                
                // PIN input
                if (_selectedMethod == SecurityMethod.pin)
                  _buildPinInput(isDarkMode, securityProvider),
                
                // Pattern input
                if (_selectedMethod == SecurityMethod.pattern)
                  _buildPatternInput(isDarkMode, securityProvider),
                
                if (_isAuthenticating)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodButton({
    required IconData icon,
    required String title,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isAvailable ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAvailable ? Colors.white : Colors.grey.shade400,
          foregroundColor: isAvailable ? Colors.blue : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ BOTÓN DE BIOMETRÍA MEJORADO
  Widget _buildBiometricButton(SecurityProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAuthenticating
            ? null
            : () async {
                setState(() {
                  _isAuthenticating = true;
                });
                
                print('🔐 Iniciando autenticación biométrica desde selector...');
                
                // Mostrar diálogo de carga
                if (mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                
                final authenticated = await provider.authenticateBiometrics();
                
                if (mounted) {
                  Navigator.pop(context); // Cerrar diálogo de carga
                  
                  setState(() {
                    _isAuthenticating = false;
                  });
                  
                  if (!authenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.biometricError ?? 
                          '❌ Error de autenticación. Intenta con otro método.',
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint),
            const SizedBox(width: 12),
            Text(
              _isAuthenticating ? 'Autenticando...' : 'Usar Biometría',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinInput(bool isDarkMode, SecurityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Ingresa tu PIN',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          PinCodeTextField(
            appContext: context,
            length: 4,
            enabled: !_isAuthenticating,
            onChanged: (value) {},
            onCompleted: (value) async {
              setState(() {
                _isAuthenticating = true;
                _pinError = null;
              });
              
              final isValid = await provider.verifyPin(value);
              
              if (mounted) {
                setState(() {
                  _isAuthenticating = false;
                });
                
                if (!isValid) {
                  setState(() {
                    _pinError = 'PIN incorrecto';
                  });
                }
              }
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 60,
              fieldWidth: 50,
              activeColor: Colors.white,
              inactiveColor: Colors.white54,
              selectedColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            enableActiveFill: false,
            textStyle: const TextStyle(color: Colors.white),
          ),
          if (_pinError != null) ...[
            const SizedBox(height: 10),
            Text(
              _pinError!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMethod = null;
                _pattern.clear();
              });
            },
            child: const Text(
              'Volver a métodos',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInput(bool isDarkMode, SecurityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Dibuja tu patrón',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _patternSize,
              itemBuilder: (context, index) {
                final isSelected = _pattern.contains(index);
                
                return GestureDetector(
                  onTapDown: (_) {
                    if (!_isAuthenticating) {
                      setState(() {
                        if (!_pattern.contains(index)) {
                          _pattern.add(index);
                        }
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.white54,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isAuthenticating
                    ? null
                    : () {
                        setState(() {
                          _pattern.clear();
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Borrar'),
              ),
              
              ElevatedButton(
                onPressed: _pattern.isEmpty || _isAuthenticating
                    ? null
                    : () async {
                        setState(() {
                          _isAuthenticating = true;
                          _patternError = null;
                        });
                        
                        final patternString = _pattern.join('');
                        final isValid = await provider.verifyPattern(patternString);
                        
                        if (mounted) {
                          setState(() {
                            _isAuthenticating = false;
                          });
                          
                          if (!isValid) {
                            setState(() {
                              _patternError = 'Patrón incorrecto';
                              _pattern.clear();
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Validar'),
              ),
            ],
          ),
          
          if (_patternError != null) ...[
            const SizedBox(height: 10),
            Text(
              _patternError!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMethod = null;
                _pattern.clear();
              });
            },
            child: const Text(
              'Volver a métodos',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}