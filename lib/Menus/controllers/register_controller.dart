import 'package:myapp/Menus/models/user.dart';
class RegisterController {
  final UserModel _userModel = UserModel();

  Future<String?> register(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return 'Por favor completa todos los campos';
    }
    try {
      await _userModel.saveUser(username, password);
      return null; // Registro correcto
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
