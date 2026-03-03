import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../utils/constants.dart';

class ApiService {
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _retryDelay = Duration(seconds: 3);
  
  // Cache para saber si el servidor está "despierto"
  static bool _serverIsAwake = false;
  static DateTime _lastSuccessfulRequest = DateTime.now();

  // ========== MÉTODO TEST CONNECTION MEJORADO ==========
  Future<bool> testConnection() async {
    // Si ya tuvimos una petición exitosa en los últimos 30 segundos, asumimos que está vivo
    if (_serverIsAwake && DateTime.now().difference(_lastSuccessfulRequest).inSeconds < 30) {
      debugPrint('🔍 Usando caché de conexión - servidor activo');
      return true;
    }
    
    try {
      debugPrint('🔍 Probando conexión básica...');
      final url = Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}');
      
      // Hacer un GET rápido con timeout corto
      final response = await http
          .get(url, headers: Constants.headers)
          .timeout(const Duration(seconds: 8)); // Timeout más corto para test
      
      final success = response.statusCode == 200;
      
      if (success) {
        debugPrint('✅ Conexión exitosa: ${response.statusCode}');
        _serverIsAwake = true;
        _lastSuccessfulRequest = DateTime.now();
      }
      
      return success;
      
    } on SocketException catch (e) {
      debugPrint('❌ SocketException: $e - Sin conexión a internet');
      _serverIsAwake = false;
      return false;
      
    } on TimeoutException catch (e) {
      debugPrint('⚠️ TimeoutException: $e - Servidor podría estar \"durmiendo\"');
      // NO marcamos como offline, solo devolvemos false para que la operación principal intente
      return false;
      
    } catch (e) {
      debugPrint('❌ Error desconocido: $e');
      return false;
    }
  }

  // ========== GET NOTES MEJORADO ==========
  Future<List<Note>> getNotes() async {
    debugPrint('🔵 ===== INICIANDO GET NOTES CON REINTENTOS =====');
    
    // NO abortamos por testConnection, dejamos que la operación principal intente
    bool hasConnection = false;
    try {
      hasConnection = await testConnection().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('⚠️ Test de conexión rápido falló, pero continuando con GET...');
    }
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (!endpoint.startsWith('/')) {
          endpoint = '/$endpoint';
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint');
        debugPrint('📡 GET URL: $url');
        
        final response = await client
            .get(url, headers: Constants.headers)
            .timeout(_timeout);

        debugPrint('📡 GET Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          List<dynamic> jsonList = json.decode(response.body);
          debugPrint('✅ GET Éxito: ${jsonList.length} notas encontradas');
          
          // Actualizar caché de conexión
          _serverIsAwake = true;
          _lastSuccessfulRequest = DateTime.now();
          
          return jsonList.map((json) => Note.fromJson(json)).toList();
        } else {
          debugPrint('❌ GET Error Status: ${response.statusCode}');
          debugPrint('❌ GET Error Body: ${response.body}');
          
          if (attempt < _maxRetries) {
            debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
        
      } on SocketException catch (e) {
        debugPrint('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        _serverIsAwake = false;
        throw Exception('No hay conexión a internet. Verifica tu red.');
        
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        // Timeout no significa necesariamente offline, el servidor puede estar lento
        throw Exception('Tiempo de espera agotado. El servidor está tardando en responder.');
        
      } catch (e) {
        debugPrint('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Error de conexión: $e');
        
      } finally {
        client.close();
      }
    }
    
    throw Exception('No se pudo conectar después de $_maxRetries intentos');
  }

  // ========== CREATE NOTE MEJORADO ==========
  Future<Note> createNote(
    String title, 
    String content, {
    List<String>? tags,
    bool? isFavorite,
  }) async {
    debugPrint('🟢 ===== INICIANDO CREATE NOTE CON REINTENTOS =====');
    debugPrint('📝 Creando nota - Título: $title');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (!endpoint.startsWith('/')) {
          endpoint = '/$endpoint';
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint');
        
        final Map<String, dynamic> bodyMap = {
          'title': title,
          'content': content,
        };
        
        if (tags != null && tags.isNotEmpty) {
          bodyMap['tags'] = tags;
        }
        
        if (isFavorite != null) {
          bodyMap['is_favorite'] = isFavorite;
        }
        
        final body = json.encode(bodyMap);
        
        debugPrint('📡 POST URL: $url');
        debugPrint('📡 POST Body: $body');

        var response = await client
            .post(url, headers: Constants.headers, body: body)
            .timeout(_timeout);

        // Manejar redirects (como en tu caso)
        if (response.statusCode == 307 || response.statusCode == 308) {
          final location = response.headers['location'];
          if (location != null) {
            debugPrint('🔄 Redirect detectado. Siguiendo a: $location');
            response = await client
                .post(Uri.parse(location), headers: Constants.headers, body: body)
                .timeout(_timeout);
          }
        }

        if (response.statusCode == 201 || response.statusCode == 200) {
          final note = Note.fromJson(json.decode(response.body));
          debugPrint('✅ POST Éxito: Nota creada con ID: ${note.id}');
          
          // ¡IMPORTANTE! Actualizar caché de conexión
          _serverIsAwake = true;
          _lastSuccessfulRequest = DateTime.now();
          
          return note;
        } else {
          debugPrint('❌ POST Error Status: ${response.statusCode}');
          debugPrint('❌ POST Error Body: ${response.body}');
          
          if (attempt < _maxRetries) {
            debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
        
      } on SocketException catch (e) {
        debugPrint('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        _serverIsAwake = false;
        throw Exception('No hay conexión a internet.');
        
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        // Timeout no significa offline, solo que el servidor tardó
        throw Exception('Tiempo de espera agotado. El servidor está tardando en responder.');
        
      } catch (e) {
        debugPrint('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Error de conexión: $e');
        
      } finally {
        client.close();
      }
    }
    
    throw Exception('No se pudo crear la nota después de $_maxRetries intentos');
  }

  // ========== UPDATE NOTE MEJORADO ==========
  Future<Note> updateNote(
    int id, 
    String title, 
    String content, {
    bool? isFavorite,
    List<String>? tags,
  }) async {
    debugPrint('🟡 ===== INICIANDO UPDATE NOTE CON REINTENTOS =====');
    debugPrint('📝 Actualizando nota ID: $id');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (!endpoint.startsWith('/')) {
          endpoint = '/$endpoint';
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
        
        final Map<String, dynamic> bodyMap = {
          'title': title,
          'content': content,
        };
        
        if (isFavorite != null) {
          bodyMap['is_favorite'] = isFavorite;
        }
        
        if (tags != null && tags.isNotEmpty) {
          bodyMap['tags'] = tags;
        }
        
        final body = json.encode(bodyMap);
        
        debugPrint('📡 PUT URL: $url');
        debugPrint('📡 PUT Body: $body');

        var response = await client
            .put(url, headers: Constants.headers, body: body)
            .timeout(_timeout);

        if (response.statusCode == 307 || response.statusCode == 308) {
          final location = response.headers['location'];
          if (location != null) {
            debugPrint('🔄 Redirect detectado. Siguiendo a: $location');
            response = await client
                .put(Uri.parse(location), headers: Constants.headers, body: body)
                .timeout(_timeout);
          }
        }

        if (response.statusCode == 200) {
          debugPrint('✅ PUT Éxito');
          
          // Actualizar caché de conexión
          _serverIsAwake = true;
          _lastSuccessfulRequest = DateTime.now();
          
          return Note.fromJson(json.decode(response.body));
        } else {
          debugPrint('❌ PUT Error Status: ${response.statusCode}');
          debugPrint('❌ PUT Error Body: ${response.body}');
          
          if (attempt < _maxRetries) {
            debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
        
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Tiempo de espera agotado.');
        
      } on SocketException catch (e) {
        debugPrint('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        _serverIsAwake = false;
        throw Exception('No hay conexión a internet.');
        
      } catch (e) {
        debugPrint('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Error de conexión: $e');
        
      } finally {
        client.close();
      }
    }
    
    throw Exception('No se pudo actualizar la nota después de $_maxRetries intentos');
  }

  // ========== DELETE NOTE MEJORADO ==========
  Future<void> deleteNote(int id) async {
    debugPrint('🔴 ===== INICIANDO DELETE NOTE CON REINTENTOS =====');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (!endpoint.startsWith('/')) {
          endpoint = '/$endpoint';
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
        debugPrint('📡 DELETE URL: $url');

        var response = await client
            .delete(url, headers: Constants.headers)
            .timeout(_timeout);

        if (response.statusCode == 307 || response.statusCode == 308) {
          final location = response.headers['location'];
          if (location != null) {
            debugPrint('🔄 Redirect detectado. Siguiendo a: $location');
            response = await client
                .delete(Uri.parse(location), headers: Constants.headers)
                .timeout(_timeout);
          }
        }

        if (response.statusCode == 204 || response.statusCode == 200) {
          debugPrint('✅ DELETE exitoso');
          
          // Actualizar caché de conexión
          _serverIsAwake = true;
          _lastSuccessfulRequest = DateTime.now();
          
          return;
        } else {
          debugPrint('❌ DELETE Error Status: ${response.statusCode}');
          
          if (attempt < _maxRetries) {
            debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
        
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Tiempo de espera agotado.');
        
      } on SocketException catch (e) {
        debugPrint('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        _serverIsAwake = false;
        throw Exception('No hay conexión a internet.');
        
      } catch (e) {
        debugPrint('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Error de conexión: $e');
        
      } finally {
        client.close();
      }
    }
    
    throw Exception('No se pudo eliminar la nota después de $_maxRetries intentos');
  }
}