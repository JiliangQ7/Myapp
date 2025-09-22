import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/Menus/controllers/peso_controller.dart';
import 'package:myapp/Menus/models/peso.dart';

class PesoPage extends StatefulWidget {
  final String username;
  const PesoPage({super.key, required this.username});

  @override
  State<PesoPage> createState() => _PesoPageState();
}

class _PesoPageState extends State<PesoPage> {
  final _pesoController = TextEditingController();
  final PesoController _controller = PesoController();
  List<Peso> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final pesos = await _controller.obtenerPesosPorUsuario(widget.username);
    setState(() {
      _historial = pesos;
    });
  }

  Future<void> _guardarPeso() async {
    final texto = _pesoController.text;
    final peso = double.tryParse(texto);

    if (peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un número válido')),
      );
      return;
    }

    final nuevoPeso = Peso(
      username: widget.username,
      peso: peso,
      fecha: DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now()),
    );

    await _controller.insertarPeso(nuevoPeso);
    _pesoController.clear();
    _cargarHistorial();
  }

  Future<void> _editarPeso(Peso peso) async {
    final controller = TextEditingController(text: peso.peso.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar peso'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nuevo peso'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nuevoPeso = double.tryParse(controller.text);
              if (nuevoPeso != null) {
                await _controller.actualizarPeso(peso.id!, nuevoPeso);
                _cargarHistorial();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPeso(int id) async {
    await _controller.eliminarPeso(id);
    _cargarHistorial();
  }

  Widget _buildGrafica() {
    // Ordenamos el historial por fecha
    final sortedData = List<Peso>.from(_historial)
      ..sort((a, b) {
        final fechaA = DateFormat('dd/MM/yyyy – HH:mm').parse(a.fecha);
        final fechaB = DateFormat('dd/MM/yyyy – HH:mm').parse(b.fecha);
        return fechaA.compareTo(fechaB);
      });

    // coge 10
    final data = sortedData.reversed.take(10).toList().reversed.toList();

    if (data.length < 2 || data.map((e) => e.peso).toSet().length <= 1) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Agrega más datos o valores distintos para mostrar la gráfica.',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    final minPeso = data.map((e) => e.peso).reduce((a, b) => a < b ? a : b);
    final maxPeso = data.map((e) => e.peso).reduce((a, b) => a > b ? a : b);
    const margen = 2.0;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: (minPeso - margen).clamp(0, double.infinity),
          maxY: maxPeso + margen,
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxPeso - minPeso).clamp(1, double.infinity),
                getTitlesWidget: (value, _) => Text(
                  '${value.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 10, color: Colors.blueAccent),
                ),
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox();
                  final fecha = data[index].fecha.split('–')[0].trim();
                  final parsed = DateFormat('dd/MM/yyyy').parse(fecha);
                  return Text(
                    '${parsed.day}/${parsed.month}',
                    style: const TextStyle(fontSize: 10, color: Colors.blueAccent),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].peso)),
              isCurved: true,
              barWidth: 2,
              color: Colors.blue,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Peso'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_historial.length >= 2) _buildGrafica(),
            const SizedBox(height: 20),
            TextField(
              controller: _pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Introduce tu peso (kg)',
                labelStyle: TextStyle(color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.blueAccent.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.monitor_weight, color: Colors.blueAccent),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarPeso,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Historial', style: theme.textTheme.titleLarge?.copyWith(color: Colors.blueAccent)),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historial.length,
              itemBuilder: (context, index) {
                final peso = _historial[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      child: const Icon(Icons.monitor_weight, color: Colors.blueAccent),
                    ),
                    title: Text('${peso.peso} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(peso.fecha, style: const TextStyle(color: Colors.black54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                          tooltip: 'Editar peso',
                          onPressed: () => _editarPeso(peso),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Eliminar peso',
                          onPressed: () => _eliminarPeso(peso.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
