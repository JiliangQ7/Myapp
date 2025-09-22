import 'package:flutter/material.dart';
import '../controllers/logros_controller.dart';

class LogrosPage extends StatefulWidget {
  final String username;
  const LogrosPage({super.key, required this.username});

  @override
  State<LogrosPage> createState() => _LogrosPageState();
}

class _LogrosPageState extends State<LogrosPage> {
  final LogrosController _controller = LogrosController();

  Map<String, dynamic>? registroSemanaActual;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      cargando = true;
    });

    final registro = await _controller.obtenerRegistroSemanaActual(widget.username);

    setState(() {
      registroSemanaActual = registro;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final azulFuerte = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros Semanales'),
        backgroundColor: azulFuerte,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cargando
            ? Center(child: CircularProgressIndicator(color: azulFuerte))
            : registroSemanaActual == null
                ? Center(
                    child: Text(
                      'No hay datos para la semana actual.',
                      style: TextStyle(color: azulFuerte),
                    ),
                  )
                : Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white, 
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Semana del ${registroSemanaActual!['fecha_inicio'].substring(0, 10)} al ${registroSemanaActual!['fecha_fin'].substring(0, 10)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: azulFuerte,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Puntuación total: ${registroSemanaActual!['puntuacion_total'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: azulFuerte,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
