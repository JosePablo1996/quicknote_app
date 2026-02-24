import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SecurityMethod { none, pin, pattern, biometric }

class SecurityProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  SecurityMethod _currentMethod = SecurityMethod.none;
  bool _isLocked = true;
  bool _biometricAvailable = false;
  bool _hasPin = false;
  bool _hasPattern = false;
  String? _biometricError;
  
  SecurityMethod get currentMethod => _currentMethod;
  bool get isLocked => _isLocked;
  bool get biometricAvailable => _biometricAvailable;
  bool get hasPin => _hasPin;
  bool get hasPattern => _hasPattern;
  String? get biometricError => _biometricError;
  
  bool get hasMultipleMethods => 
      (_hasPin || _hasPattern || _biometricAvailable) && 
      ((_hasPin ? 1 : 0) + (_hasPattern ? 1 : 0) + (_biometricAvailable ? 1 : 0) > 1);
  
  SecurityProvider() {
    _loadSecurityMethod();
    _checkBiometricAvailability();
    _checkStoredMethods();
  }
  
  Future<void> _loadSecurityMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodIndex = prefs.getInt('security_method') ?? 0;
      _currentMethod = SecurityMethod.values[methodIndex];
      _isLocked = _currentMethod != SecurityMethod.none;
      notifyListeners();
    } catch (e) {
      _currentMethod = SecurityMethod.none;
      _isLocked = false;
      notifyListeners();
    }
  }
  
  Future<void> _checkStoredMethods() async {
    try {
      final pin = await _secureStorage.read(key: 'security_pin');
      final pattern = await _secureStorage.read(key: 'security_pattern');
      
      _hasPin = pin != null;
      _hasPattern = pattern != null;
      
      notifyListeners();
    } catch (e) {
      _hasPin = false;
      _hasPattern = false;
    }
  }
  
  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      print('📱 Biometría - canCheck: $canCheck, isSupported: $isSupported');
      print('📱 Biometrías disponibles: $availableBiometrics');
      
      _biometricAvailable = canCheck && 
                            isSupported && 
                            availableBiometrics.isNotEmpty;
      
      if (!_biometricAvailable) {
        if (!canCheck) {
          _biometricError = 'El dispositivo no puede verificar biometría';
        } else if (!isSupported) {
          _biometricError = 'El dispositivo no soporta biometría';
        } else if (availableBiometrics.isEmpty) {
          _biometricError = 'No hay biometrías configuradas (huella/Face ID)';
        }
      } else {
        _biometricError = null;
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error checking biometrics: $e');
      _biometricAvailable = false;
      _biometricError = 'Error al verificar biometría: $e';
      notifyListeners();
    }
  }
  
  Future<void> setSecurityMethod(SecurityMethod method, {String? pin, String? pattern}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('security_method', method.index);
      
      if (method == SecurityMethod.pin && pin != null) {
        await _secureStorage.write(key: 'security_pin', value: pin);
        await _secureStorage.delete(key: 'security_pattern');
        _hasPin = true;
        _hasPattern = false;
      } else if (method == SecurityMethod.pattern && pattern != null) {
        await _secureStorage.write(key: 'security_pattern', value: pattern);
        await _secureStorage.delete(key: 'security_pin');
        _hasPin = false;
        _hasPattern = true;
      } else if (method == SecurityMethod.biometric) {
        await _secureStorage.delete(key: 'security_pin');
        await _secureStorage.delete(key: 'security_pattern');
        _hasPin = false;
        _hasPattern = false;
      } else {
        await _secureStorage.delete(key: 'security_pin');
        await _secureStorage.delete(key: 'security_pattern');
        _hasPin = false;
        _hasPattern = false;
      }
      
      _currentMethod = method;
      _isLocked = method != SecurityMethod.none;
      notifyListeners();
    } catch (e) {
      print('❌ Error setting security method: $e');
    }
  }
  
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: 'security_pin');
      final isValid = storedPin == pin;
      
      if (isValid) {
        _isLocked = false;
        notifyListeners();
      }
      
      return isValid;
    } catch (e) {
      print('❌ Error verifying PIN: $e');
      return false;
    }
  }
  
  Future<bool> verifyPattern(String pattern) async {
    try {
      final storedPattern = await _secureStorage.read(key: 'security_pattern');
      final isValid = storedPattern == pattern;
      
      if (isValid) {
        _isLocked = false;
        notifyListeners();
      }
      
      return isValid;
    } catch (e) {
      print('❌ Error verifying pattern: $e');
      return false;
    }
  }
  
  // ✅ NUEVA VERSIÓN MEJORADA DE authenticateBiometrics
  Future<bool> authenticateBiometrics() async {
    try {
      // Verificar disponibilidad antes de intentar autenticar
      if (!_biometricAvailable) {
        print('❌ Biometría no disponible');
        return false;
      }
      
      print('🔐 Intentando autenticación biométrica...');
      
      // Intentar autenticar con manejo de errores específico
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Autentícate para acceder a QuickNote',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            sensitiveTransaction: true,
          ),
        );
        
        print('🔐 Resultado autenticación: $authenticated');
        
        if (authenticated) {
          _isLocked = false;
          notifyListeners();
        }
        
        return authenticated;
      } catch (authError) {
        // Capturar específicamente el error de FragmentActivity
        if (authError.toString().contains('no_fragment_activity')) {
          print('❌ Error: La actividad no es FragmentActivity');
          
          // Intentar con opciones alternativas
          final fallbackAuthenticated = await _localAuth.authenticate(
            localizedReason: 'Autentícate para acceder a QuickNote',
            options: const AuthenticationOptions(
              biometricOnly: false, // Permitir otras opciones
              stickyAuth: true,
            ),
          );
          
          if (fallbackAuthenticated) {
            _isLocked = false;
            notifyListeners();
          }
          
          return fallbackAuthenticated;
        } else {
          print('❌ Error en autenticación biométrica: $authError');
          return false;
        }
      }
    } catch (e) {
      print('❌ Error general en autenticación biométrica: $e');
      return false;
    }
  }
  
  // ✅ NUEVO MÉTODO DE DIAGNÓSTICO (Paso 2)
  Future<Map<String, dynamic>> diagnosticBiometrics() async {
    final Map<String, dynamic> info = {};
    
    try {
      info['canCheckBiometrics'] = await _localAuth.canCheckBiometrics;
      info['isDeviceSupported'] = await _localAuth.isDeviceSupported();
      info['availableBiometrics'] = (await _localAuth.getAvailableBiometrics())
          .map((b) => b.name)
          .toList();
      
      // Verificar tipo de actividad
      try {
        // Intentar una autenticación rápida para diagnosticar
        final auth = await _localAuth.authenticate(
          localizedReason: 'Diagnóstico de biometría',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: false,
          ),
        );
        info['authTest'] = auth ? 'Success' : 'Failed';
      } catch (e) {
        info['authTest'] = 'Error: $e';
        info['authErrorType'] = e.runtimeType.toString();
      }
      
      info['biometricAvailable'] = _biometricAvailable;
      info['biometricError'] = _biometricError;
      
    } catch (e) {
      info['error'] = e.toString();
    }
    
    return info;
  }
  
  void unlockApp() {
    _isLocked = false;
    notifyListeners();
  }
  
  void lockApp() {
    _isLocked = true;
    notifyListeners();
  }
  
  Future<void> disableSecurity() async {
    try {
      await setSecurityMethod(SecurityMethod.none);
      _isLocked = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error disabling security: $e');
    }
  }
}