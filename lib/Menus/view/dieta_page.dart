import 'package:flutter/material.dart';
import 'dia_dieta_page.dart';

class DietaPage extends StatelessWidget {
  final String username;

  const DietaPage({Key? key, required this.username}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dieta'),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: ListView.builder(
          itemCount: diasSemana.length,
          itemBuilder: (context, index) {
            final dia = diasSemana[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                title: Text(
                  dia,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaDietaPage(
                        dia: dia,
                        username: username,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
