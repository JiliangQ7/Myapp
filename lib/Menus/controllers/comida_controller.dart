import '../models/comida.dart';
import '../db/comida_database.dart';

class ComidaController {
  
  Future<List<Comida>> getComidasPorUsuario(String username) async {
    return await ComidaDatabase.instance.getComidasPorUsuario(username);
  }

  Future<Comida> insertarComida(Comida comida) async {
    return await ComidaDatabase.instance.insertComida(comida);
  }

  Future<int> actualizarComida(Comida comida) async {
    return await ComidaDatabase.instance.updateComida(comida);
  }

  Future<int> eliminarComida(int id) async {
    return await ComidaDatabase.instance.deleteComida(id);
  }

  // funcion que asigna comidas a los dias 
  Future<void> asignarComidaADiaCategoria(int comidaId, String dia, String categoria, String username) async {
    await ComidaDatabase.instance.asignarComidaADiaCategoria(comidaId, dia, categoria, username);
  }

  Future<List<Comida>> obtenerComidasPorDiaYCategoriaYUsuario(String dia, String categoria, String username) async {
    return await ComidaDatabase.instance.obtenerComidasPorDiaYCategoriaYUsuario(dia, categoria, username);
  }

  Future<int> eliminarComidaDeDiaCategoria(int comidaId, String dia, String categoria, String username) async {
    return await ComidaDatabase.instance.eliminarComidaDeDiaCategoria(comidaId, dia, categoria, username);
  }
}
