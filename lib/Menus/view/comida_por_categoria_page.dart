import 'dart:io';
import 'package:flutter/material.dart';

import '../models/comida.dart';
import '../controllers/comida_controller.dart';
import 'comida_detalle_page.dart';

class ComidasPorCategoriaPage extends StatefulWidget {
  final String dia;
  final String categoria;
  final String username;

  const ComidasPorCategoriaPage({
    Key? key,
    required this.dia,
    required this.categoria,
    required this.username,
  }) : super(key: key);

  @override
  State<ComidasPorCategoriaPage> createState() => _ComidasPorCategoriaPageState();
}

class _ComidasPorCategoriaPageState extends State<ComidasPorCategoriaPage> {
  final ComidaController _comidaController = ComidaController();

  List<Comida> comidasAsignadas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarComidas();
  }

  
  Future<void> _cargarComidas() async {
    setState(() => isLoading = true);

    final comidas = await _comidaController.obtenerComidasPorDiaYCategoriaYUsuario(
      widget.dia,
      widget.categoria,
      widget.username,
    );

    setState(() {
      comidasAsignadas = comidas;
      isLoading = false;
    });
  }

  ///  seleccionar una comida y asignarla
  Future<void> _mostrarSelectorComida() async {
    final todas = await _comidaController.getComidasPorUsuario(widget.username);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
      
        String searchText = '';
        List<Comida> comidasFiltradas = List.from(todas);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void filtrar(String texto) {
              setModalState(() {
                searchText = texto;
                comidasFiltradas = todas
                    .where((c) => c.titulo.toLowerCase().contains(texto.toLowerCase()))
                    .toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barra de arriba decorativa 
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Título
                  Text(
                    'Seleccionar comida',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // para buscar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar comida...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: filtrar,
                  ),

                  const SizedBox(height: 12),

                  // lista de comidas 
                  SizedBox(
                    height: 350,
                    child: comidasFiltradas.isEmpty
                        ? Center(
                            child: Text(
                              'No se encontraron comidas.',
                              style: TextStyle(color: Colors.blueGrey.shade400),
                            ),
                          )
                        : ListView.separated(
                            itemCount: comidasFiltradas.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final comida = comidasFiltradas[index];
                              return ListTile(
                                leading: comida.fotoPath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(comida.fotoPath!),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: Colors.blue.shade300,
                                        child: const Icon(
                                          Icons.fastfood,
                                          color: Colors.white,
                                        ),
                                      ),
                                title: Text(
                                  comida.titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                subtitle: comida.descripcion != null
                                    ? Text(
                                        comida.descripcion!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                onTap: () async {
                                  await _comidaController.asignarComidaADiaCategoria(
                                    comida.id!,
                                    widget.dia,
                                    widget.categoria,
                                    widget.username,
                                  );
                                  Navigator.pop(context);
                                  _cargarComidas();
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //elimina la comida en la dieta de ese dia
  Future<void> _eliminarComidaAsignada(int comidaId) async {
    await _comidaController.eliminarComidaDeDiaCategoria(
      comidaId,
      widget.dia,
      widget.categoria,
      widget.username,
    );
    _cargarComidas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoria} - ${widget.dia}'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blue.shade800,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : comidasAsignadas.isEmpty
              ? Center(
                  child: Text(
                    'No hay comidas asignadas.',
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade400),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comidasAsignadas.length,
                  itemBuilder: (context, index) {
                    final comida = comidasAsignadas[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        leading: comida.fotoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(comida.fotoPath!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue.shade300,
                                child: const Icon(
                                  Icons.fastfood,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                        title: Text(
                          comida.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                        subtitle: comida.descripcion != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  comida.descripcion!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.blueGrey.shade700),
                                ),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Eliminar comida'),
                                  content: const Text(
                                      '¿Quieres eliminar esta comida de la categoría?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue.shade800,
                                      ),
                                    ),
                                    TextButton(
                                      child: const Text('Eliminar'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _eliminarComidaAsignada(comida.id!);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        onTap: () {
                          // ir a detalles de la comida
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComidaDetallePage(comida: comida),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarSelectorComida,
        icon: const Icon(Icons.add),
        label: const Text('Agregar comida'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}
