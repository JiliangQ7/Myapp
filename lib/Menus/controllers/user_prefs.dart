import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const String _keyUsers = 'users';

  // Actualizar foto de perfil
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_keyUsers) ?? '[]';
    final List<dynamic> users = jsonDecode(usersString);

    final List<Map<String, dynamic>> updatedUsers = [];

    for (var user in users) {
      final username = user['username'];
      final profileImagePath = prefs.getString('profile_image_$username') ?? user['profileImagePath'] ?? '';
      updatedUsers.add({
        'username': username,
        'password': user['password'],
        'profileImagePath': profileImagePath,
      });
    }

    return updatedUsers;
  }

  // Nuevo usuario
  static Future<void> saveUser(String username, String password, String? profileImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();

    if (users.any((u) => u['username'] == username)) {
      throw Exception('El nombre de usuario ya existe');
    }

    users.add({
      'username': username,
      'password': password,
      'profileImagePath': profileImagePath ?? '',
    });

    await prefs.setString(_keyUsers, jsonEncode(users));

    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      await setProfileImagePath(username, profileImagePath);
    }
  }

  // Validar login
  static Future<bool> validateUser(String username, String password) async {
    final users = await getUsers();
    return users.any((u) => u['username'] == username && u['password'] == password);
  }

  // Guardar imagen separada por usuario
  static Future<void> setProfileImagePath(String username, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_$username', path);
  }

  // ruta de imagen separada por usuario
  static Future<String?> getProfileImagePath(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_$username');
  }
  
}
