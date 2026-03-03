// utils/connectivity_util.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ConnectivityUtil {
  static final ConnectivityUtil _instance = ConnectivityUtil._internal();
  factory ConnectivityUtil() => _instance;
  
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  final List<Function(bool)> _listeners = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;

  ConnectivityUtil._internal() {
    _initialize();
  }

  static ConnectivityUtil get instance => _instance;

  bool get isConnected => _isConnected;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    await _initConnectivity();
    _setupConnectivityListener();
    _isInitialized = true;
  }

  void _setupConnectivityListener() {
    // Cancelar subscription anterior si existe
    _connectivitySubscription?.cancel();
    
    // Configurar nuevo listener con manejo de errores
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        debugPrint('❌ Error en connectivity listener: $error');
        _handleConnectionError();
      },
      onDone: () {
        debugPrint('📡 Connectivity listener completed, restarting...');
        _setupConnectivityListener(); // Reiniciar listener si se completa
      },
    );
    
    debugPrint('📡 Connectivity listener configurado');
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      debugPrint('🔍 Connectivity inicial: $result');
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      _handleConnectionError();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasConnected = _isConnected;
    
    // Verificar si hay alguna conexión activa
    // En versiones recientes, result es una lista de ConnectivityResult
    final hasConnection = result.isNotEmpty && !result.every((r) => r == ConnectivityResult.none);
    
    // Log detallado del estado
    debugPrint('📡 Connectivity changed: $result');
    debugPrint('   ├─ hasConnection: $hasConnection');
    debugPrint('   ├─ wasConnected: $wasConnected');
    debugPrint('   └─ isConnected: $_isConnected');
    
    if (hasConnection != _isConnected) {
      _isConnected = hasConnection;
      debugPrint('🔔 Estado de conectividad CAMBIÓ: ${wasConnected ? "ONLINE" : "OFFLINE"} → ${_isConnected ? "ONLINE" : "OFFLINE"}');
      _notifyListeners();
    } else {
      debugPrint('ℹ️ Estado de conectividad sin cambios: ${_isConnected ? "ONLINE" : "OFFLINE"}');
    }
  }

  void _handleConnectionError() {
    final wasConnected = _isConnected;
    _isConnected = false;
    
    if (wasConnected != _isConnected) {
      debugPrint('⚠️ Error de conectividad - Forzando modo OFFLINE');
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    debugPrint('📢 Notificando a ${_listeners.length} listeners sobre cambio a ${_isConnected ? "ONLINE" : "OFFLINE"}');
    
    // Crear una copia de la lista para evitar modificaciones durante la iteración
    final listeners = List<Function(bool)>.from(_listeners);
    
    for (var listener in listeners) {
      try {
        listener(_isConnected);
      } catch (e) {
        debugPrint('❌ Error notificando listener: $e');
        // Remover listener que causa error
        _listeners.remove(listener);
      }
    }
  }

  void addListener(Function(bool) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
      debugPrint('👂 Listener agregado. Total listeners: ${_listeners.length}');
      
      // Notificar estado actual inmediatamente
      try {
        listener(_isConnected);
      } catch (e) {
        debugPrint('❌ Error en listener inicial: $e');
        _listeners.remove(listener);
      }
    }
  }

  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
    debugPrint('👋 Listener removido. Total listeners: ${_listeners.length}');
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection = result.isNotEmpty && !result.every((r) => r == ConnectivityResult.none);
      
      debugPrint('🔍 Check connectivity manual: $result → ${hasConnection ? "ONLINE" : "OFFLINE"}');
      
      if (hasConnection != _isConnected) {
        _isConnected = hasConnection;
        _notifyListeners();
      }
      
      return _isConnected;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      _handleConnectionError();
      return false;
    }
  }

  // Método para forzar una verificación y notificación
  Future<void> forceRefresh() async {
    debugPrint('🔄 Forzando actualización de conectividad...');
    await checkConnectivity();
  }

  // Método para simular cambios (útil para pruebas)
  void simulateConnectivityChange(bool isConnected) {
    debugPrint('🧪 Simulando cambio de conectividad a: ${isConnected ? "ONLINE" : "OFFLINE"}');
    final wasConnected = _isConnected;
    _isConnected = isConnected;
    
    if (wasConnected != _isConnected) {
      _notifyListeners();
    }
  }

  void dispose() {
    debugPrint('🧹 Limpiando ConnectivityUtil');
    _connectivitySubscription?.cancel();
    _listeners.clear();
  }
}