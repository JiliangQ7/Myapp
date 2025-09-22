import 'package:flutter/material.dart';
import 'dia_page.dart'; 

class RutinaPage extends StatelessWidget {
  final String username;

  const RutinaPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final List<String> diasSemana = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    final azulFuerte = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutina Semanal'),
        backgroundColor: azulFuerte,
      ),
      body: ListView.builder(
        itemCount: diasSemana.length,
        itemBuilder: (context, index) {
          final dia = diasSemana[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(Icons.calendar_today, color: azulFuerte),
              title: Text(
                dia,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: azulFuerte,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey.shade600),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaPage(username: username, dia: dia),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
