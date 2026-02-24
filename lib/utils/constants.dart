import 'package:flutter/material.dart';

class Constants {
  // URL de tu API en Render
    static const String baseUrl = 'https://api-notas-personales.onrender.com';

  // Endpoints de la API
  static const String notesEndpoint = '/api/v1/notes';
  
  // Headers para peticiones HTTP
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  
  // Colores de la app
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.lightBlue;
  
  // Textos
  static const String appTitle = 'QuickNote';
  static const String emptyNotesMessage = 'No hay notas. ¡Crea una!';
}