import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String? _errorMessage;
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
                
                Text(
                  'Autenticación requerida',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                if (securityProvider.currentMethod == SecurityMethod.pin)
                  _buildPinLock(isDarkMode, securityProvider)
                else if (securityProvider.currentMethod == SecurityMethod.pattern)
                  _buildPatternLockCustom(isDarkMode, securityProvider)
                else if (securityProvider.currentMethod == SecurityMethod.biometric)
                  _buildBiometricLock(securityProvider)
                else
                  _buildUnlockButton(securityProvider),
                
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                
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

  Widget _buildPinLock(bool isDarkMode, SecurityProvider provider) {
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
                _errorMessage = null;
              });
              
              final isValid = await provider.verifyPin(value);
              
              if (mounted) {
                setState(() {
                  _isAuthenticating = false;
                });
                
                if (!isValid) {
                  setState(() {
                    _errorMessage = 'PIN incorrecto';
                  });
                }
                // No necesitamos navegar, el Provider actualiza isLocked y el main.dart reconstruye
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
        ],
      ),
    );
  }

  Widget _buildPatternLockCustom(bool isDarkMode, SecurityProvider provider) {
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
            decoration: const BoxDecoration(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Borrar'),
              ),
              
              ElevatedButton(
                onPressed: _pattern.isEmpty || _isAuthenticating
                    ? null
                    : () async {
                        setState(() {
                          _isAuthenticating = true;
                          _errorMessage = null;
                        });
                        
                        final patternString = _pattern.join('');
                        final isValid = await provider.verifyPattern(patternString);
                        
                        if (mounted) {
                          setState(() {
                            _isAuthenticating = false;
                          });
                          
                          if (!isValid) {
                            setState(() {
                              _errorMessage = 'Patrón incorrecto';
                              _pattern.clear();
                            });
                          }
                          // No necesitamos navegar, el Provider actualiza isLocked
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Validar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricLock(SecurityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Autenticación biométrica',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isAuthenticating
                ? null
                : () async {
                    setState(() {
                      _isAuthenticating = true;
                      _errorMessage = null;
                    });
                    
                    final authenticated = await provider.authenticateBiometrics();
                    
                    if (mounted) {
                      setState(() {
                        _isAuthenticating = false;
                      });
                      
                      if (!authenticated) {
                        setState(() {
                          _errorMessage = 'Autenticación fallida';
                        });
                      }
                      // No necesitamos navegar, el Provider actualiza isLocked
                    }
                  },
            icon: const Icon(Icons.fingerprint),
            label: const Text('Usar huella digital'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockButton(SecurityProvider provider) {
    return ElevatedButton(
      onPressed: () {
        provider.unlockApp();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        minimumSize: const Size(200, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Entrar'),
    );
  }
}