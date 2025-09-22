import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ejercicio.dart';
import '/Menus/db/ejercicio_database.dart';

class EjercicioDetallesPage extends StatefulWidget {
  final String username;
  final Ejercicio? ejercicio;
  final bool soloLectura;

  const EjercicioDetallesPage({
    super.key,
    required this.username,
    this.ejercicio,
    this.soloLectura = false,
  });

  @override
  _EjercicioDetallesPageState createState() => _EjercicioDetallesPageState();
}

class _EjercicioDetallesPageState extends State<EjercicioDetallesPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _setsController;
  late TextEditingController _repeticionesController; // <-- Nuevo controlador
  late TextEditingController _descansoController;
  late TextEditingController _duracionController;
  late TextEditingController _puntuacionController;
  late TextEditingController _videoUrlController;

  String? _photoPath;
  String? _videoPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ejercicio?.title ?? '');
    _descriptionController = TextEditingController(text: widget.ejercicio?.description ?? '');
    _setsController = TextEditingController(text: widget.ejercicio?.sets?.toString() ?? '');
    _repeticionesController = TextEditingController(text: widget.ejercicio?.repeticiones?.toString() ?? ''); // inicializar
    _descansoController = TextEditingController(text: widget.ejercicio?.descanso?.toString() ?? '');
    _duracionController = TextEditingController(text: widget.ejercicio?.duracion?.toString() ?? '');
    _puntuacionController = TextEditingController(text: widget.ejercicio?.puntuacion?.toString() ?? '');
    _videoUrlController = TextEditingController(text: widget.ejercicio?.videoUrl ?? '');
    _photoPath = widget.ejercicio?.photoPath;
    _videoPath = widget.ejercicio?.videoPath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _setsController.dispose();
    _repeticionesController.dispose(); // liberar controlador
    _descansoController.dispose();
    _duracionController.dispose();
    _puntuacionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  void _saveEjercicio() async {
    if (_formKey.currentState!.validate()) {
      final newEjercicio = Ejercicio(
        id: widget.ejercicio?.id,
        username: widget.username,
        title: _titleController.text,
        description: _descriptionController.text,
        photoPath: _photoPath,
        videoPath: _videoPath,
        videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
        sets: int.tryParse(_setsController.text),
        repeticiones: int.tryParse(_repeticionesController.text), // guardar repeticiones
        descanso: int.tryParse(_descansoController.text),
        duracion: int.tryParse(_duracionController.text),
        puntuacion: double.tryParse(_puntuacionController.text),
      );

      if (widget.ejercicio == null) {
        await EjercicioDatabase.instance.create(newEjercicio);
      } else {
        await EjercicioDatabase.instance.update(newEjercicio);
      }

      Navigator.of(context).pop(true);
    }
  }

  Widget _buildCampo(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$titulo: ", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          Expanded(child: Text(valor ?? '-', style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esLectura = widget.soloLectura;
    final primaryColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          esLectura
              ? 'Detalles del Ejercicio'
              : widget.ejercicio == null
                  ? 'Nuevo Ejercicio'
                  : 'Editar Ejercicio',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: esLectura
            ? null
            : [
                IconButton(
                  icon: Icon(Icons.save, color: Colors.white),
                  onPressed: _saveEjercicio,
                  tooltip: 'Guardar',
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: esLectura
            ? ListView(
                children: [
                  if (_photoPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_photoPath!),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    widget.ejercicio?.title ?? '',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const Divider(thickness: 2, height: 30),
                  const Text("📄 Descripción", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(widget.ejercicio?.description ?? '', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  const Text("📊 Detalles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildCampo("Sets", widget.ejercicio?.sets?.toString()),
                  _buildCampo("Repeticiones", widget.ejercicio?.repeticiones?.toString()), // Mostrar repeticiones
                  _buildCampo("Descanso", "${widget.ejercicio?.descanso ?? '-'} segundos"),
                  _buildCampo("Duración", widget.ejercicio?.duracion != null ? "${widget.ejercicio!.duracion} minutos" : "-"),
                  _buildCampo("Puntuación", widget.ejercicio?.puntuacion?.toString()),
                  const SizedBox(height: 20),
                  const Text("🎥 Video", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (widget.ejercicio?.videoUrl != null && widget.ejercicio!.videoUrl!.isNotEmpty)
                    InkWell(
                      onTap: () async {
                        final videoUrl = widget.ejercicio!.videoUrl!;
                        final Uri uri = Uri.parse(videoUrl.startsWith('http') ? videoUrl : 'https://$videoUrl');
                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No se pudo abrir el video")),
                          );
                        }
                      },
                      child: Text(
                        widget.ejercicio!.videoUrl!,
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    )
                  else
                    const Text("Sin video"),
                ],
              )
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) => value == null || value.isEmpty ? 'Ingrese el título' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _setsController,
                      decoration: InputDecoration(
                        labelText: 'Sets',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _repeticionesController, // Nuevo campo repeticiones
                      decoration: InputDecoration(
                        labelText: 'Repeticiones',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descansoController,
                      decoration: InputDecoration(
                        labelText: 'Descanso (segundos)',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _duracionController,
                      decoration: InputDecoration(
                        labelText: 'Duración (minutos)',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _puntuacionController,
                      decoration: InputDecoration(
                        labelText: 'Puntuación',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _videoUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL Video',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _photoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(_photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                          )
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text("Foto"),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.video_library),
                          label: const Text("Video"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoPath = pickedFile.path;
      });
    }
  }
}
