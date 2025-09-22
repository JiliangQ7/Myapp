import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/Menus/models/comida.dart';


import '../controllers/comida_detalle_controller.dart';

class ComidaDetallePage extends StatefulWidget {
  final Comida comida;
  final bool isEditing;

  const ComidaDetallePage({
    Key? key,
    required this.comida,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _ComidaDetallePageState createState() => _ComidaDetallePageState();
}

class _ComidaDetallePageState extends State<ComidaDetallePage> {
  late ComidaDetalleController _detalleController;

  @override
  void initState() {
    super.initState();
    _detalleController = ComidaDetalleController(widget.comida);
  }

  @override
  void dispose() {
    _detalleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comida = widget.comida;
    final isEditing = widget.isEditing;

    final azulPrincipal = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar comida' : comida.titulo),
        backgroundColor: azulPrincipal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comida.fotoPath != null && comida.fotoPath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(comida.fotoPath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fastfood, size: 100, color: Colors.grey),
                    ),
              const SizedBox(height: 24),

              // Título
              isEditing
                  ? TextField(
                      controller: _detalleController.tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: azulPrincipal),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : Text(
                      comida.titulo,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: azulPrincipal,
                      ),
                    ),
              const SizedBox(height: 16),

              // Descripción
              isEditing
                  ? TextField(
                      controller: _detalleController.descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: azulPrincipal),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    )
                  : Text(
                      comida.descripcion.isNotEmpty ? comida.descripcion : 'Sin descripción',
                      style: const TextStyle(fontSize: 18, color: Colors.black87),
                    ),
              const SizedBox(height: 16),

              // Peso
              isEditing
                  ? TextField(
                      controller: _detalleController.pesoController,
                      decoration: InputDecoration(
                        labelText: 'Peso (gramos)',
                        labelStyle: TextStyle(color: azulPrincipal),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    )
                  : Text(
                      'Peso: ${comida.peso} gramos',
                      style: const TextStyle(fontSize: 18, color: Colors.black87),
                    ),
              const SizedBox(height: 16),

              // Puntuación
              isEditing
                  ? TextField(
                      controller: _detalleController.puntuacionController,
                      decoration: InputDecoration(
                        labelText: 'Puntuación',
                        labelStyle: TextStyle(color: azulPrincipal),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulPrincipal.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    )
                  : Text(
                      'Puntuación: ${comida.puntuacion}',
                      style: const TextStyle(fontSize: 18, color: Colors.black87),
                    ),

              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _detalleController.guardarCambios(comida);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Guardar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
