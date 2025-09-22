import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/Menus/view/comida_detalle_page.dart';
import 'package:myapp/Menus/models/comida.dart';
import 'package:myapp/Menus/controllers/comida_page_controller.dart';

class ComidaPage extends StatefulWidget {
  final String username;

  const ComidaPage({Key? key, required this.username}) : super(key: key);

  @override
  State<ComidaPage> createState() => _ComidaPageState();
}

class _ComidaPageState extends State<ComidaPage> {
  late ComidaPageController _controller;
  List<Comida> _comidas = [];

  @override
  void initState() {
    super.initState();
    _controller = ComidaPageController(widget.username);
    _cargarComidas();
  }

  Future<void> _cargarComidas() async {
    final comidas = await _controller.cargarComidas();
    setState(() {
      _comidas = comidas;
    });
  }

  void _mostrarFormularioAgregarComida() {
    _mostrarFormularioComida();
  }

  void _mostrarFormularioEditarComida(Comida comida) {
    _mostrarFormularioComida(comida: comida);
  }

  bool _imagenValida(File? img) {
    return img != null && img.existsSync();
  }

  void _mostrarFormularioComida({Comida? comida}) {
    String titulo = comida?.titulo ?? '';
    String descripcion = comida?.descripcion ?? '';
    String pesoStr = comida?.peso.toString() ?? '';
    int puntuacion = comida?.puntuacion ?? 1;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        File? imagen = (comida?.fotoPath != null && comida!.fotoPath!.isNotEmpty)
            ? File(comida.fotoPath!)
            : null;

        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              comida == null ? 'Agregar comida' : 'Editar comida',
              style: const TextStyle(color: Color.fromARGB(255, 21, 101, 192), fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: titulo,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa un título' : null,
                      onChanged: (val) => titulo = val,
                    ),
                    TextFormField(
                      initialValue: descripcion,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                      ),
                      onChanged: (val) => descripcion = val,
                      maxLines: 2,
                    ),
                    TextFormField(
                      initialValue: pesoStr,
                      decoration: InputDecoration(
                        labelText: 'Peso (gramos)',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa el peso';
                        if (int.tryParse(value) == null) return 'Debe ser un número';
                        return null;
                      },
                      onChanged: (val) => pesoStr = val,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Puntuación: ', style: TextStyle(color: Colors.blue.shade700)),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: puntuacion,
                          items: List.generate(5, (index) {
                            int val = index + 1;
                            return DropdownMenuItem(
                              value: val,
                              child: Text(val.toString()),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setStateDialog(() => puntuacion = val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _imagenValida(imagen)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(imagen!, height: 100),
                          )
                        : Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'No hay imagen seleccionada',
                                style: TextStyle(color: Colors.blue.shade300),
                              ),
                            ),
                          ),
                    TextButton.icon(
                      icon: Icon(Icons.photo, color: Colors.blue.shade800),
                      label: Text('Seleccionar imagen', style: TextStyle(color: Colors.blue.shade800)),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setStateDialog(() {
                            imagen = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancelar', style: TextStyle(color: Colors.blue.shade800)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                ),
                child: Text(comida == null ? 'Guardar' : 'Actualizar'),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final int peso = int.parse(pesoStr);

                    final nuevaComida = Comida(
                      id: comida?.id,
                      username: widget.username,
                      titulo: titulo,
                      descripcion: descripcion,
                      peso: peso,
                      puntuacion: puntuacion,
                      fotoPath: imagen?.path,
                    );

                    if (comida == null) {
                      await _controller.agregarComida(nuevaComida);
                    } else {
                      await _controller.actualizarComida(nuevaComida);
                    }

                    await _cargarComidas();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _eliminarComida(int id) async {
    await _controller.eliminarComida(id);
    await _cargarComidas();
  }

  Widget _buildComidaItem(Comida comida) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: comida.fotoPath != null && File(comida.fotoPath!).existsSync()
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(comida.fotoPath!),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.fastfood, size: 40, color: Color.fromARGB(255, 42, 145, 230)),
        title: Text(comida.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${comida.descripcion}\nPeso: ${comida.peso} g | Puntuación: ${comida.puntuacion}',
          style: const TextStyle(height: 1.4),
        ),
        isThreeLine: true,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComidaDetallePage(comida: comida),
            ),
          );
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _mostrarFormularioEditarComida(comida),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar comida'),
                    content: const Text('¿Estás seguro de que quieres eliminar esta comida?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('Eliminar'),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _eliminarComida(comida.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Comidas'),
        backgroundColor: Colors.blue.shade800,
        elevation: 6,
        shadowColor: Colors.blue.shade200,
      ),
      body: _comidas.isEmpty
          ? Center(child: Text('No hay comidas registradas', style: TextStyle(color: Colors.blue.shade800)))
          : ListView.builder(
              itemCount: _comidas.length,
              itemBuilder: (context, index) => _buildComidaItem(_comidas[index]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        onPressed: _mostrarFormularioAgregarComida,
        child: const Icon(Icons.add),
      ),
    );
  }
}
