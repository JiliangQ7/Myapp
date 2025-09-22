import "package:myapp/Menus/controllers/user_prefs.dart";

class UserController {
  List<String> ocultos = [];

  Future<List<Map<String, dynamic>>> getUsers() async {
    final users = await UserPrefs.getUsers();
    // Filtrar usuarios ocultos
    return users.where((user) => !ocultos.contains(user['username'])).toList();
  }

  void ocultarUsuario(String username) {
    if (!ocultos.contains(username)) {
      ocultos.add(username);
    }
  }

  Future<bool> validarLogin(String username, String password) async {
    return await UserPrefs.validateUser(username, password);
  }
}
