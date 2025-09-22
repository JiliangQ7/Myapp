import 'dart:io';
import 'package:flutter/material.dart';
import '/Menus/models/ejercicio.dart';
import '/Menus/db/ejercicio_database.dart';
import 'ejercicio_detalle_page.dart';
import 'seleccionar_ejercicio_page.dart';

class DiaPage extends StatefulWidget {
  final String username;
  final String dia;

  const DiaPage({super.key, required this.username, required this.dia});

  @override
  State<DiaPage> createState() => _DiaPageState();
}

class _DiaPageState extends State<DiaPage> {
  List<EjercicioConEstado> ejercicios = [];

  @override
  void initState() {
    super.initState();
    _cargarEjercicios();
  }

  Future<void> _cargarEjercicios() async {
    final data = await EjercicioDatabase.instance.leerEjerciciosPorDia(widget.username, widget.dia);
    setState(() {
      ejercicios = data;
    });
  }

  void _abrirDetalles(EjercicioConEstado ejercicio) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EjercicioDetallesPage(
          username: widget.username,
          ejercicio: ejercicio,
          soloLectura: true,
        ),
      ),
    );

    if (result == true) {
      _cargarEjercicios();
    }
  }

  Future<void> _toggleHecho(EjercicioConEstado ejercicio, bool nuevoValor) async {
    await EjercicioDatabase.instance.actualizarEstadoHecho(
      widget.username,
      ejercicio.id!,
      widget.dia,
      nuevoValor,
    );
    setState(() {
      final index = ejercicios.indexWhere((e) => e.id == ejercicio.id);
      if (index != -1) {
        ejercicios[index] = EjercicioConEstado(
          id: ejercicio.id,
          username: ejercicio.username,
          title: ejercicio.title,
          description: ejercicio.description,
          photoPath: ejercicio.photoPath,
          videoPath: ejercicio.videoPath,
          videoUrl: ejercicio.videoUrl,
          sets: ejercicio.sets,
          descanso: ejercicio.descanso,
          puntuacion: ejercicio.puntuacion,
          peso: ejercicio.peso,
          hecho: nuevoValor,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final azulFuerte = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicios del ${widget.dia}'),
        backgroundColor: azulFuerte,
      ),
      body: ejercicios.isEmpty
          ? const Center(child: Text('No hay ejercicios asignados.'))
          : ListView.builder(
              itemCount: ejercicios.length,
              itemBuilder: (context, index) {
                final ejercicio = ejercicios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ejercicio.photoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(ejercicio.photoPath!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.fitness_center, size: 40, color: azulFuerte),
                    title: Text(
                      ejercicio.title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: azulFuerte),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          ejercicio.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sets: ${ejercicio.sets ?? "-"}  |  Descanso: ${ejercicio.descanso ?? "-"}s  |  Peso: ${ejercicio.peso ?? "-"} kg',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: ejercicio.hecho,
                          activeColor: azulFuerte,
                          onChanged: (bool? checked) {
                            if (checked != null) {
                              _toggleHecho(ejercicio, checked);
                            }
                          },
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade600),
                      ],
                    ),
                    onTap: () => _abrirDetalles(ejercicio),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulFuerte,
        onPressed: () async {
          final seleccionado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeleccionarEjercicioPage(username: widget.username),
            ),
          );

          if (seleccionado != null && seleccionado is Ejercicio) {
            await EjercicioDatabase.instance.asignarEjercicioADia(
              widget.username,
              seleccionado.id!,
              widget.dia,
            );
            _cargarEjercicios();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
