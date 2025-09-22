import 'package:flutter/material.dart';
import 'dart:io';
import '../db/ejercicio_database.dart';
import '../models/ejercicio.dart';
import 'ejercicio_detalle_page.dart';


class EjerciciosPage extends StatefulWidget {
  final String username;

  const EjerciciosPage({super.key, required this.username});

  @override
  _EjerciciosPageState createState() => _EjerciciosPageState();
}

class _EjerciciosPageState extends State<EjerciciosPage> {
  late Future<List<Ejercicio>> _ejercicios; 

  @override
  void initState() {
    super.initState();
    _refreshEjercicios(); // Cargar ejercicios al iniciar la pantalla
  }

  // actualiza  la lista de ejercicios desde la base de datos
  void _refreshEjercicios() {
    setState(() {
      _ejercicios = EjercicioDatabase.instance.readAllEjercicios(widget.username);
    });
  }

  // Elimina un ejercicio del usuario y actualiza la lista
  void _deleteEjercicio(int id) async {
    await EjercicioDatabase.instance.delete(id);
    _refreshEjercicios();
  }

  // ir a la pantalla de detalles (lectura)
  void _verDetalles(Ejercicio ejercicio) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EjercicioDetallesPage(
          username: widget.username,
          ejercicio: ejercicio,
          soloLectura: true,
        ),
      ),
    );
    if (result == true) {
      _refreshEjercicios();
    }
  }

  // ir a la pantalla de detalles (edicion)
  void _editarEjercicio(Ejercicio ejercicio) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EjercicioDetallesPage(
          username: widget.username,
          ejercicio: ejercicio,
          soloLectura: false,
        ),
      ),
    );
    if (result == true) {
      _refreshEjercicios();
    }
  }

  // ir a la pantalla para añadir nuevo ejercicio
  void _agregarEjercicio() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EjercicioDetallesPage(
          username: widget.username,
        ),
      ),
    );
    if (result == true) {
      _refreshEjercicios();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final primaryBlue = Colors.blue.shade700;
    final lightBlue = Colors.blue.shade50;
    final iconBlue = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        backgroundColor: primaryBlue,
        elevation: 5,
        shadowColor: Colors.blueAccent.withOpacity(0.6),
      ),
      body: FutureBuilder<List<Ejercicio>>(
        future: _ejercicios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar indicador de carga mientras se obtienen los datos
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Mostrar mensaje si no hay ejercicios 
            return Center(
              child: Text(
                'No hay ejercicios',
                style: TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }
          final ejercicios = snapshot.data!;
          // Lista de ejercicios 
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ejercicios.length,
            itemBuilder: (context, index) {
              final ejercicio = ejercicios[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 7,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shadowColor: primaryBlue.withOpacity(0.4),
                color: lightBlue,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _verDetalles(ejercicio), // Ver detalles al pulsar la tarjeta
                  splashColor: primaryBlue.withOpacity(0.2),
                  highlightColor: primaryBlue.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: 150,
                    child: Row(
                      children: [
                        ejercicio.photoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(ejercicio.photoPath!),
                                  width: 100,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 100,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.fitness_center, size: 50, color: primaryBlue),
                              ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ejercicio.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              Text(
                                ejercicio.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 15, color: primaryBlue.withOpacity(0.8)),
                              ),
                              const Spacer(),
                              // muestra sets, descanso y peso
                              Text(
                                'Sets: ${ejercicio.sets ?? "-"}  |  Descanso: ${ejercicio.descanso ?? "-"}s  |  Peso: ${ejercicio.peso ?? "-"} kg',
                                style: TextStyle(fontSize: 13, color: primaryBlue.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                        // Botones para editar y eliminar ejercicio
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: iconBlue),
                              onPressed: () => _editarEjercicio(ejercicio),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteEjercicio(ejercicio.id!),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: _agregarEjercicio,
        child: const Icon(Icons.add),
      ),
    );
  }
}
