import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../utils/constants.dart';

class ApiService {
  // Configuración de reintentos y timeouts
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30); // Aumentado a 30 segundos
  static const Duration _retryDelay = Duration(seconds: 3); // Espera entre reintentos

  // GET /notes - Obtener todas las notas con reintentos automáticos
  Future<List<Note>> getNotes() async {
    print('🔵 ===== INICIANDO GET NOTES CON REINTENTOS =====');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('📡 Intento $attempt de $_maxRetries');
        
        final url = Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}');
        print('📡 GET URL: $url');
        
        final response = await http
            .get(url, headers: Constants.headers)
            .timeout(_timeout);

        print('📡 GET Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          List<dynamic> jsonList = json.decode(response.body);
          print('✅ GET Éxito: ${jsonList.length} notas encontradas');
          return jsonList.map((json) => Note.fromJson(json)).toList();
        } else {
          print('❌ GET Error Status: ${response.statusCode}');
          print('❌ GET Error Body: ${response.body}');
          
          // Si no es el último intento, esperar y reintentar
          if (attempt < _maxRetries) {
            print('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
      } on TimeoutException catch (e) {
        print('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar por timeout...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Tiempo de espera agotado. El servidor está tardando en responder.');
        
      } on SocketException catch (e) {
        print('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar por error de red...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('No hay conexión a internet. Verifica tu red.');
        
      } catch (e) {
        print('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Error de conexión: $e');
      }
    }
    
    // Si llegamos aquí, todos los intentos fallaron
    throw Exception('No se pudo conectar después de $_maxRetries intentos');
  }

  // POST /notes - Crear nota con reintentos
  Future<Note> createNote(String title, String content) async {
    print('🟢 ===== INICIANDO CREATE NOTE CON REINTENTOS =====');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        print('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (endpoint.endsWith('/')) {
          endpoint = endpoint.substring(0, endpoint.length - 1);
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint');
        final body = json.encode({'title': title, 'content': content});
        
        print('📡 POST URL: $url');
        print('📡 POST Body: $body');

        var response = await client
            .post(url, headers: Constants.headers, body: body)
            .timeout(_timeout);

        // Manejar redirect 307
        if (response.statusCode == 307) {
          final location = response.headers['location'];
          if (location != null) {
            print('🔄 Redirect detectado. Siguiendo a: $location');
            
            response = await client
                .post(Uri.parse(location), headers: Constants.headers, body: body)
                .timeout(_timeout);
          }
        }

        if (response.statusCode == 201 || response.statusCode == 200) {
          final note = Note.fromJson(json.decode(response.body));
          print('✅ POST Éxito: Nota creada con ID: ${note.id}');
          return note;
        } else {
          print('❌ POST Error Status: ${response.statusCode}');
          
          if (attempt < _maxRetries) {
            print('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
        
      } on TimeoutException catch (e) {
        print('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Tiempo de espera agotado. El servidor está tardando en responder.');
        
      } on SocketException catch (e) {
        print('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('No hay conexión a internet. Verifica tu red.');
        
      } catch (e) {
        print('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
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

  // PUT /notes/{id} - Actualizar nota con reintentos
  Future<Note> updateNote(int id, String title, String content) async {
    print('🟡 ===== INICIANDO UPDATE NOTE CON REINTENTOS =====');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        print('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (endpoint.endsWith('/')) {
          endpoint = endpoint.substring(0, endpoint.length - 1);
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
        final body = json.encode({'title': title, 'content': content});
        
        print('📡 PUT URL: $url');

        var response = await client
            .put(url, headers: Constants.headers, body: body)
            .timeout(_timeout);

        if (response.statusCode == 307) {
          final location = response.headers['location'];
          if (location != null) {
            print('🔄 Redirect detectado. Siguiendo a: $location');
            response = await client
                .put(Uri.parse(location), headers: Constants.headers, body: body)
                .timeout(_timeout);
          }
        }

        if (response.statusCode == 200) {
          print('✅ PUT Éxito');
          return Note.fromJson(json.decode(response.body));
        } else {
          print('❌ PUT Error Status: ${response.statusCode}');
          
          if (attempt < _maxRetries) {
            print('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
        
      } on TimeoutException catch (e) {
        print('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Tiempo de espera agotado.');
        
      } on SocketException catch (e) {
        print('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('No hay conexión a internet.');
        
      } catch (e) {
        print('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
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

  // DELETE /notes/{id} - Eliminar nota con reintentos
  Future<void> deleteNote(int id) async {
    print('🔴 ===== INICIANDO DELETE NOTE CON REINTENTOS =====');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final client = http.Client();
      
      try {
        print('📡 Intento $attempt de $_maxRetries');
        
        String endpoint = Constants.notesEndpoint;
        if (endpoint.endsWith('/')) {
          endpoint = endpoint.substring(0, endpoint.length - 1);
        }
        
        final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
        print('📡 DELETE URL: $url');

        var response = await client
            .delete(url, headers: Constants.headers)
            .timeout(_timeout);

        if (response.statusCode == 307) {
          final location = response.headers['location'];
          if (location != null) {
            print('🔄 Redirect detectado. Siguiendo a: $location');
            response = await client
                .delete(Uri.parse(location), headers: Constants.headers)
                .timeout(_timeout);
          }
        }

        if (response.statusCode == 204) {
          print('✅ DELETE exitoso');
          return;
        } else {
          print('❌ DELETE Error Status: ${response.statusCode}');
          
          if (attempt < _maxRetries) {
            print('🔄 Esperando $_retryDelay antes de reintentar...');
            await Future.delayed(_retryDelay);
            continue;
          }
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
        
      } on TimeoutException catch (e) {
        print('⏱️ Timeout en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('Tiempo de espera agotado.');
        
      } on SocketException catch (e) {
        print('📶 Error de red en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
          await Future.delayed(_retryDelay);
          continue;
        }
        throw Exception('No hay conexión a internet.');
        
      } catch (e) {
        print('❌ Error inesperado en intento $attempt: $e');
        
        if (attempt < _maxRetries) {
          print('🔄 Esperando $_retryDelay antes de reintentar...');
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