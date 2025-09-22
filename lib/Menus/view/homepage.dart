import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/MainPage.dart';
import 'package:myapp/Menus/view/nutricionpage.dart';
import 'package:myapp/Menus/view/peso_page.dart';
import 'package:myapp/Menus/view/calendario_page.dart';
import 'package:myapp/Menus/view/ejerciciospage.dart';
import 'package:myapp/Menus/view/rutina_page.dart';
import 'package:myapp/Menus/view/logrospage.dart';
import 'package:myapp/Menus/controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

// State con animación para el menú y manejo de imagen de perfil
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final HomeController _controller; 
  late AnimationController _animationController; 
  late Animation<double> _animationScale; 
  String? _profileImagePath; 
  @override
  void initState() {
    super.initState();
    _controller = HomeController(widget.username); 
    _loadProfileImage(); 

   
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward(); 
  }


  Future<void> _loadProfileImage() async {
    final path = await _controller.loadProfileImage();
    setState(() {
      _profileImagePath = path;
    });
  }

  // Cambiar imagen de perfil usando controlador y actualizar estado visual
  Future<void> _changeProfileImage() async {
    final newPath = await _controller.changeProfileImage();
    if (newPath != null) {
      setState(() {
        _profileImagePath = newPath;
      });
      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.username;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Principal'),
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(username, style: const TextStyle(fontSize: 20)),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundImage: (_profileImagePath != null && File(_profileImagePath!).existsSync())
                    ? FileImage(File(_profileImagePath!))
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
                radius: 40,
              ),
            ),
            // Opción para cambiar foto de perfil
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cambiar foto de perfil'),
              onTap: () async {
                Navigator.pop(context); 
                await _changeProfileImage();
              },
            ),
      
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: ScaleTransition(
        scale: _animationScale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFE3F2FD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // Grid con botones que navegan a las diferentes menus
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            children: [
              _buildMenuButton(
                icon: Icons.fitness_center,
                label: 'Ejercicios',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EjerciciosPage(username: username)),
                ),
              ),
              _buildMenuButton(
                icon: Icons.scale,
                label: 'Peso',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PesoPage(username: username)),
                ),
              ),
              _buildMenuButton(
                icon: Icons.calendar_today,
                label: 'Calendario',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CalendarioPage(username: username)),
                ),
              ),
              _buildMenuButton(
                icon: Icons.star,
                label: 'Logros',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LogrosPage(username: username)),
                ),
              ),
              _buildMenuButton(
                icon: Icons.run_circle,
                label: 'Rutina',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RutinaPage(username: username)),
                ),
              ),
              _buildMenuButton(
                icon: Icons.restaurant,
                label: 'Nutrición',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NutricionPage(username: username)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para crear botones de menú con icono y texto
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue.shade900),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
