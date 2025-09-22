import 'package:flutter/material.dart';

import 'dieta_page.dart';
import 'comida_page.dart';

class NutricionPage extends StatefulWidget {
  final String username;

  const NutricionPage({Key? key, required this.username}) : super(key: key);

  @override
  State<NutricionPage> createState() => _NutricionPageState();
}

class _NutricionPageState extends State<NutricionPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _animationScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrición'),
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1,
          children: [
            AnimatedBuilder(
              animation: _animationScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animationScale.value,
                  child: child,
                );
              },
              child: _buildOption(
                context,
                'Dieta',
                Icons.restaurant_menu,
                Colors.orange.shade600,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DietaPage(username: widget.username),
                    ),
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _animationScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animationScale.value,
                  child: child,
                );
              },
              child: _buildOption(
                context,
                'Comida',
                Icons.fastfood,
                Colors.green.shade600,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComidaPage(username: widget.username),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      shadowColor: color.withOpacity(0.6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
                color.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
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
