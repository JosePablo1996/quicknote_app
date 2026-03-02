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

  // Método de prueba para verificar conectividad básica
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Probando conexión básica...');
      final url = Uri.parse('https://api-notas-personales.onrender.com');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      debugPrint('✅ Conexión exitosa: ${response.statusCode}');
      return true;
    } on SocketException catch (e) {
      debugPrint('❌ SocketException: $e');
      debugPrint('   Posibles causas: Sin internet, DNS no resuelve, o firewall');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('❌ TimeoutException: $e');
      debugPrint('   El servidor tarda demasiado en responder');
      return false;
    } catch (e) {
      debugPrint('❌ Error desconocido: $e');
      return false;
    }
  }

  // GET /notes - Obtener todas las notas
  Future<List<Note>> getNotes() async {
    debugPrint('🔵 ===== INICIANDO GET NOTES CON REINTENTOS =====');
    
    // Primero probar conexión básica
    final hasConnection = await testConnection();
    if (!hasConnection) {
      debugPrint('⚠️ No hay conexión al servidor. Abortando GET.');
      throw Exception('No hay conexión al servidor. Verifica tu internet.');
    }
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        final url = Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}');
        debugPrint('📡 GET URL: $url');
        
        final response = await http
            .get(url, headers: Constants.headers)
            .timeout(_timeout);

        debugPrint('📡 GET Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          List<dynamic> jsonList = json.decode(response.body);
          debugPrint('✅ GET Éxito: ${jsonList.length} notas encontradas');
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
        debugPrint('   Detalles: No se puede resolver el host o conectar');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('No hay conexión a internet. Verifica tu red.');
        
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Tiempo de espera agotado. El servidor está tardando en responder.');
        
      } catch (e) {
        debugPrint('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Error de conexión: $e');
      }
    }
    
    throw Exception('No se pudo conectar después de $_maxRetries intentos');
  }

  // POST /notes - Crear nota
  Future<Note> createNote(
    String title, 
    String content, {
    List<String>? tags,
    bool? isFavorite,
  }) async {
    debugPrint('🟢 ===== INICIANDO CREATE NOTE CON REINTENTOS =====');
    debugPrint('📝 Creando nota - Título: $title');
    debugPrint('   Tags recibidos del provider: $tags');
    
    // Primero probar conexión básica
    final hasConnection = await testConnection();
    if (!hasConnection) {
      debugPrint('⚠️ No hay conexión al servidor. Abortando CREATE.');
      throw Exception('No hay conexión al servidor. Verifica tu internet.');
    }
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (endpoint.endsWith('/')) {
          endpoint = endpoint.substring(0, endpoint.length - 1);
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint');
        
        final Map<String, dynamic> bodyMap = {
          'title': title,
          'content': content,
        };
        
        if (tags != null && tags.isNotEmpty) {
          bodyMap['tags'] = tags;
          debugPrint('   ✅ Incluyendo tags en la petición: $tags');
        } else {
          debugPrint('   ℹ️ No hay tags para incluir');
        }
        
        if (isFavorite != null) {
          bodyMap['is_favorite'] = isFavorite; // 👈 CAMBIADO
          debugPrint('   ✅ Incluyendo is_favorite: $isFavorite');
        }
        
        final body = json.encode(bodyMap);
        
        debugPrint('📡 POST URL: $url');
        debugPrint('📡 POST Body: $body');

        var response = await client
            .post(url, headers: Constants.headers, body: body)
            .timeout(_timeout);

        if (response.statusCode == 307) {
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
          debugPrint('   Tags en la respuesta del servidor: ${note.tags}');
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
        debugPrint('   Detalles: No se puede resolver el host o conectar');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('No hay conexión a internet. Verifica tu red.');
        
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          debugPrint('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
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

  // PUT /notes/{id} - Actualizar nota
  Future<Note> updateNote(
    int id, 
    String title, 
    String content, {
    bool? isFavorite,
    List<String>? tags,
  }) async {
    debugPrint('🟡 ===== INICIANDO UPDATE NOTE CON REINTENTOS =====');
    debugPrint('📝 Actualizando nota ID: $id');
    debugPrint('   Título: $title');
    debugPrint('   isFavorite: $isFavorite');
    debugPrint('   Tags: $tags');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (endpoint.endsWith('/')) {
          endpoint = endpoint.substring(0, endpoint.length - 1);
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
        
        final Map<String, dynamic> bodyMap = {
          'title': title,
          'content': content,
        };
        
        if (isFavorite != null) {
          bodyMap['is_favorite'] = isFavorite; // 👈 CAMBIADO
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

        if (response.statusCode == 307) {
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
          final updatedNote = Note.fromJson(json.decode(response.body));
          debugPrint('📝 Nota actualizada - isFavorite: ${updatedNote.isFavorite}');
          debugPrint('   Tags: ${updatedNote.tags}');
          return updatedNote;
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

  // DELETE /notes/{id} - Eliminar nota
  Future<void> deleteNote(int id) async {
    debugPrint('🔴 ===== INICIANDO DELETE NOTE CON REINTENTOS =====');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        debugPrint('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (endpoint.endsWith('/')) {
          endpoint = endpoint.substring(0, endpoint.length - 1);
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
        debugPrint('📡 DELETE URL: $url');

        var response = await client
            .delete(url, headers: Constants.headers)
            .timeout(_timeout);

        if (response.statusCode == 307) {
          final location = response.headers['location'];
          if (location != null) {
            debugPrint('🔄 Redirect detectado. Siguiendo a: $location');
            response = await client
                .delete(Uri.parse(location), headers: Constants.headers)
                .timeout(_timeout);
          }
        }

        if (response.statusCode == 204) {
          debugPrint('✅ DELETE exitoso');
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