import 'package:myapp/Menus/db/comida_database.dart';
import 'package:myapp/Menus/models/comida.dart';

class ComidaPageController {
  final String username;

  ComidaPageController(this.username);

  Future<List<Comida>> cargarComidas() {
    return ComidaDatabase.instance.getComidasPorUsuario(username);
  }

  Future<void> agregarComida(Comida comida) {
    return ComidaDatabase.instance.insertComida(comida);
  }

  Future<void> actualizarComida(Comida comida) {
    return ComidaDatabase.instance.updateComida(comida);
  }

  Future<void> eliminarComida(int id) {
    return ComidaDatabase.instance.deleteComida(id);
  }
}
