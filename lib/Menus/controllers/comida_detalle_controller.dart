import 'package:flutter/material.dart';
import 'package:myapp/Menus/models/comida.dart';
import 'comida_controller.dart'; 

class ComidaDetalleController {
  final ComidaController _comidaController = ComidaController();

  late TextEditingController tituloController;
  late TextEditingController descripcionController;
  late TextEditingController pesoController;
  late TextEditingController puntuacionController;

  ComidaDetalleController(Comida comida) {
    tituloController = TextEditingController(text: comida.titulo);
    descripcionController = TextEditingController(text: comida.descripcion);
    pesoController = TextEditingController(text: comida.peso.toString());
    puntuacionController = TextEditingController(text: comida.puntuacion.toString());
  }

  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    pesoController.dispose();
    puntuacionController.dispose();
  }

  Future<void> guardarCambios(Comida comida) async {
    final updatedComida = comida.copyWith(
      titulo: tituloController.text,
      descripcion: descripcionController.text,
      peso: int.tryParse(pesoController.text) ?? comida.peso,
      puntuacion: int.tryParse(puntuacionController.text) ?? comida.puntuacion,
    );
    await _comidaController.actualizarComida(updatedComida);
  }
}
