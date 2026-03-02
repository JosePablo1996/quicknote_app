import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // 👈 IMPORTANTE: Esta importación es necesaria para debugPrint
import '../models/developer_profile.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener perfil del desarrollador
  Future<DeveloperProfile?> getDeveloperProfile() async {
    try {
      final response = await _supabase
          .from('developer_profile')
          .select()
          .eq('id', '1')
          .single();

      return DeveloperProfile.fromJson(response);
    } catch (e) {
      debugPrint('Error al obtener perfil: $e');
      return null;
    }
  }

  // Actualizar perfil (solo para el desarrollador)
  Future<bool> updateDeveloperProfile(DeveloperProfile profile) async {
    try {
      await _supabase
          .from('developer_profile')
          .update(profile.toJson())
          .eq('id', '1');

      return true;
    } catch (e) {
      debugPrint('Error al actualizar perfil: $e');
      return false;
    }
  }

  // Subir imagen a Supabase Storage
  Future<String?> uploadImage(String path, String fileName, Uint8List bytes) async {
    try {
      await _supabase.storage
          .from('developer-images')
          .uploadBinary('$path/$fileName', bytes);

      final publicUrl = _supabase.storage
          .from('developer-images')
          .getPublicUrl('$path/$fileName');

      return publicUrl;
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      return null;
    }
  }

  // Verificar si el usuario actual es el desarrollador
  bool isDeveloper() {
    final user = _supabase.auth.currentUser;
    // Aquí puedes verificar el email o un campo específico
    return user?.email == 'jose.miranda@quicknote.com' || 
           user?.id == 'developer-id-1';
  }
}