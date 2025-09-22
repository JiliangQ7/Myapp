import 'package:flutter/material.dart';
import '../models/evento.dart';

//pantalla para agregar o editar un evento
class AgregarEditarEventoPage extends StatefulWidget {
  final Evento? evento;

  const AgregarEditarEventoPage({super.key, this.evento});

  @override
  State<AgregarEditarEventoPage> createState() => _AgregarEditarEventoPageState();
}

class _AgregarEditarEventoPageState extends State<AgregarEditarEventoPage> {
  late TextEditingController _descripcionController;
  TimeOfDay _horaSeleccionada = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.evento?.descripcion ?? '');
    _horaSeleccionada = widget.evento?.hora ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // aqui se cambia el titulo dependiendo si se esta editando o agregando 
        title: Text(widget.evento == null ? 'Agregar Evento' : 'Editar Evento'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Hora: ${_horaSeleccionada.format(context)}'),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _seleccionarHora,
                  child: const Text('Seleccionar hora'),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                final descripcion = _descripcionController.text.trim();
                if (descripcion.isNotEmpty) {
                  Navigator.pop(context, Evento(descripcion: descripcion, hora: _horaSeleccionada));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
//metodo para actualizar la hora
  Future<void> _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }
}
