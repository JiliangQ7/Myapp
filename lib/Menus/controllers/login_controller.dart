

import '../controllers/user_prefs.dart';

class LoginController {
  Future<String?> login(String username, String password) async {
    final isValid = await UserPrefs.validateUser(username, password);
    if (isValid) {
      return null; // éxito
    } else {
      return 'Usuario o contraseña incorrectos';
    }
  }
}
