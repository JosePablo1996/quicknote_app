import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../utils/constants.dart';

class ApiService {
  // GET /notes - Obtener todas las notas
  Future<List<Note>> getNotes() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}'),
        headers: Constants.headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // POST /notes - Crear nota
  Future<Note> createNote(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}'),
        headers: Constants.headers,
        body: json.encode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        return Note.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PUT /notes/{id} - Actualizar nota
  Future<Note> updateNote(int id, String title, String content) async {
    try {
      final response = await http.put(
        Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}/$id'),
        headers: Constants.headers,
        body: json.encode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return Note.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // DELETE /notes/{id} - Eliminar nota
  Future<void> deleteNote(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}${Constants.notesEndpoint}/$id'),
        headers: Constants.headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}