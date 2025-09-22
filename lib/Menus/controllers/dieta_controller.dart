
import '../models/comida.dart';
import 'comida_controller.dart';

class DietaController {
  final ComidaController _comidaController = ComidaController();

  Future<Map<String, List<Comida>>> obtenerDietaCompletaPorDia(String username, String dia) async {
    Map<String, List<Comida>> dieta = {};
    List<String> categorias = ['Desayuno', 'Comida', 'Cena', 'Extra'];

    for (var categoria in categorias) {
      dieta[categoria] = await _comidaController.obtenerComidasPorDiaYCategoriaYUsuario(username, dia, categoria);
    }

    return dieta;
  }


}
