import 'package:flutter/material.dart';
import '/Menus/models/ejercicio.dart';
import '/Menus/db/ejercicio_database.dart';

class SeleccionarEjercicioPage extends StatefulWidget {
  final String username;

  const SeleccionarEjercicioPage({super.key, required this.username});

  @override
  State<SeleccionarEjercicioPage> createState() => _SeleccionarEjercicioPageState();
}

class _SeleccionarEjercicioPageState extends State<SeleccionarEjercicioPage> {
  List<Ejercicio> ejercicios = [];

  @override
  void initState() {
    super.initState();
    _cargarEjercicios();
  }

  Future<void> _cargarEjercicios() async {
    final db = await EjercicioDatabase.instance.database;
    final result = await db.query(
      'ejercicios',
      where: 'username = ?',
      whereArgs: [widget.username],
    );
    setState(() {
      ejercicios = result.map((e) => Ejercicio.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Ejercicio')),
      body: ListView.builder(
        itemCount: ejercicios.length,
        itemBuilder: (context, index) {
          final ejercicio = ejercicios[index];
          return ListTile(
            title: Text(ejercicio.title),
            subtitle: Text(ejercicio.description),
            onTap: () => Navigator.pop(context, ejercicio),
          );
        },
      ),
    );
  }
}
