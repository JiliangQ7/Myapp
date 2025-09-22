import 'package:flutter/material.dart';
import 'comida_por_categoria_page.dart'; 

class DiaDietaPage extends StatelessWidget {
  final String dia;
  final String username;

  const DiaDietaPage({
    Key? key,
    required this.dia,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> secciones = ['Desayuno', 'Comida', 'Cena', 'Extra'];
    final Map<String, IconData> iconos = {
      'Desayuno': Icons.free_breakfast,
      'Comida': Icons.lunch_dining,
      'Cena': Icons.dinner_dining,
      'Extra': Icons.add_circle_outline,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Dieta - $dia'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 6,
        shadowColor: Colors.blue.shade200,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: secciones.length,
        itemBuilder: (context, index) {
          final seccion = secciones[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.blue.shade100,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade300,
                radius: 26,
                child: Icon(
                  iconos[seccion],
                  size: 28,
                  color: Colors.white,
                ),
              ),
              title: Text(
                seccion,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 20, color: Colors.blue.shade800),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComidasPorCategoriaPage(
                      dia: dia,
                      categoria: seccion,
                      username: username,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
