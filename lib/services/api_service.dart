import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../utils/constants.dart';

class ApiService {
  // GET /notes - Obtener todas las notas
  Future<List<Note>> getNotes() async {
    print('🔵 ===== INICIANDO GET NOTES =====');
    try {
      final url = Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}');
      print('📡 GET URL: $url');
      print('📡 GET Headers: ${Constants.headers}');
      
      final response = await http.get(
        url,
        headers: Constants.headers,
      ).timeout(const Duration(seconds: 15));

      print('📡 GET Status: ${response.statusCode}');
      print('📡 GET Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        print('✅ GET Éxito: ${jsonList.length} notas encontradas');
        return jsonList.map((json) => Note.fromJson(json)).toList();
      } else {
        print('❌ GET Error Status: ${response.statusCode}');
        print('❌ GET Error Body: ${response.body}');
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ GET Exception: $e');
      throw Exception('Error de conexión en GET: $e');
    } finally {
      print('🔵 ===== FIN GET NOTES =====');
    }
  }

  // POST /notes - Crear nota (VERSIÓN CORREGIDA - Maneja redirects 307)
  Future<Note> createNote(String title, String content) async {
    print('🟢 ===== INICIANDO CREATE NOTE =====');
    
    // Crear un cliente HTTP personalizado
    final client = http.Client();
    
    try {
      // Asegurar URL sin slash al final
      String endpoint = Constants.notesEndpoint;
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      
      final url = Uri.parse('${Constants.baseUrl}$endpoint');
      final body = json.encode({'title': title, 'content': content});
      
      print('📡 POST URL inicial: $url');
      print('📡 POST Headers: ${Constants.headers}');
      print('📡 POST Body: $body');

      // Primera petición
      var response = await client.post(
        url,
        headers: Constants.headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('📡 POST Status inicial: ${response.statusCode}');
      print('📡 POST Response Headers: ${response.headers}');

      // Manejar redirect 307
      if (response.statusCode == 307) {
        final location = response.headers['location'];
        if (location != null) {
          print('🔄 Redirect detectado. Siguiendo a: $location');
          
          // Seguir el redirect
          response = await client.post(
            Uri.parse(location),
            headers: Constants.headers,
            body: body,
          ).timeout(const Duration(seconds: 15));
          
          print('📡 POST Status final: ${response.statusCode}');
          print('📡 POST Response Body: ${response.body}');
        }
      }

      // Verificar respuesta exitosa
      if (response.statusCode == 201 || response.statusCode == 200) {
        final note = Note.fromJson(json.decode(response.body));
        print('✅ POST Éxito: Nota creada con ID: ${note.id}');
        return note;
      } else {
        print('❌ POST Error Status: ${response.statusCode}');
        print('❌ POST Error Body: ${response.body}');
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ POST Exception: $e');
      throw Exception('Error de conexión en POST: $e');
    } finally {
      client.close(); // Cerrar el cliente
      print('🟢 ===== FIN CREATE NOTE =====');
    }
  }

  // PUT /notes/{id} - Actualizar nota
  Future<Note> updateNote(int id, String title, String content) async {
    print('🟡 ===== INICIANDO UPDATE NOTE =====');
    final client = http.Client();
    
    try {
      String endpoint = Constants.notesEndpoint;
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      
      final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
      final body = json.encode({'title': title, 'content': content});
      
      print('📡 PUT URL: $url');
      print('📡 PUT Body: $body');

      var response = await client.put(
        url,
        headers: Constants.headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      // Manejar redirect si es necesario
      if (response.statusCode == 307) {
        final location = response.headers['location'];
        if (location != null) {
          print('🔄 Redirect en PUT, siguiendo a: $location');
          response = await client.put(
            Uri.parse(location),
            headers: Constants.headers,
            body: body,
          );
        }
      }

      print('📡 PUT Status: ${response.statusCode}');
      print('📡 PUT Response: ${response.body}');

      if (response.statusCode == 200) {
        return Note.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ PUT Exception: $e');
      throw Exception('Error de conexión en PUT: $e');
    } finally {
      client.close();
      print('🟡 ===== FIN UPDATE NOTE =====');
    }
  }

  // DELETE /notes/{id} - Eliminar nota
  Future<void> deleteNote(int id) async {
    print('🔴 ===== INICIANDO DELETE NOTE =====');
    final client = http.Client();
    
    try {
      String endpoint = Constants.notesEndpoint;
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      
      final url = Uri.parse('${Constants.baseUrl}$endpoint/$id');
      print('📡 DELETE URL: $url');

      var response = await client.delete(
        url,
        headers: Constants.headers,
      ).timeout(const Duration(seconds: 15));

      // Manejar redirect si es necesario
      if (response.statusCode == 307) {
        final location = response.headers['location'];
        if (location != null) {
          print('🔄 Redirect en DELETE, siguiendo a: $location');
          response = await client.delete(
            Uri.parse(location),
            headers: Constants.headers,
          );
        }
      }

      print('📡 DELETE Status: ${response.statusCode}');

      if (response.statusCode != 204) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
      
      print('✅ DELETE exitoso');
    } catch (e) {
      print('❌ DELETE Exception: $e');
      throw Exception('Error de conexión en DELETE: $e');
    } finally {
      client.close();
      print('🔴 ===== FIN DELETE NOTE =====');
    }
  }
}