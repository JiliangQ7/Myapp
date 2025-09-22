import 'package:flutter/material.dart';
import 'dart:io';
import 'Menus/view/registro_page.dart';
import 'Menus/view/login_page.dart';
import 'Menus/view/homepage.dart';
import 'package:myapp/Menus/controllers/user_controller.dart';

// Página principal que muestra la lista de usuarios
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final UserController _controller = UserController();
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _controller.getUsers();
    });
  }

  void _goToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    ).then((_) => _loadUsers());
  }

  void _goToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _ocultarUsuario(String username) {
    _controller.ocultarUsuario(username);
    _loadUsers();
  }

  void _goToPasswordLogin(String username) async {
    final bool? success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPasswordPage(username: username),
      ),
    );

    if (success == true) {
      // Si se logueó con éxito, recarga usuarios por si cambió algo
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final visibleUsers = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Usuarios registrados:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: visibleUsers.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay usuarios visibles',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: visibleUsers.length,
                          itemBuilder: (context, index) {
                            final user = visibleUsers[index];
                            final username = user['username'];
                            final imagePath = user['profileImagePath'];

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: (imagePath != null &&
                                        imagePath.isNotEmpty &&
                                        File(imagePath).existsSync())
                                    ? CircleAvatar(
                                        backgroundImage: FileImage(File(imagePath)),
                                        radius: 32,
                                      )
                                    : const CircleAvatar(
                                        child: Icon(Icons.person, size: 32),
                                        radius: 32,
                                      ),
                                title: Text(
                                  username,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                ),
                                onTap: () => _goToPasswordLogin(username),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent),
                                  onPressed: () => _ocultarUsuario(username),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _goToRegisterPage,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Crear Usuario', style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _goToLoginPage,
                  icon: const Icon(Icons.login),
                  label: const Text('Iniciar sesión con otro usuario', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Nueva pantalla para ingresar la contraseña, amplia y limpia
class LoginPasswordPage extends StatefulWidget {
  final String username;
  const LoginPasswordPage({super.key, required this.username});

  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final UserController _controller = UserController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _tryLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final password = _passwordController.text.trim();
    final isValid = await _controller.validarLogin(widget.username, password);

    setState(() {
      _isLoading = false;
    });

    if (isValid) {
      // Navega a HomePage y cuando vuelve, indica éxito
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(username: widget.username)),
      );
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMessage = '❌ Contraseña incorrecta';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acceso: ${widget.username}'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        color: Colors.blue.shade50,
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Introduce tu contraseña',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para acceder a tu cuenta "${widget.username}", ingresa tu contraseña a continuación.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[800]?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue[700],
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _tryLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
