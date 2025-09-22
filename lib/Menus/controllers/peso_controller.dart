import 'package:myapp/Menus/db/database_helper.dart'; 
import 'package:myapp/Menus/models/peso.dart';

class PesoController {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Peso>> obtenerPesosPorUsuario(String username) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'peso',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'fecha DESC',
    );

    return result.map((map) => Peso.fromMap(map)).toList();
  }

  Future<int> insertarPeso(Peso peso) async {
    final db = await dbHelper.database;
    return await db.insert('peso', peso.toMap());
  }

  Future<int> actualizarPeso(int id, double nuevoPeso) async {
    final db = await dbHelper.database;
    return await db.update(
      'peso',
      {'valor': nuevoPeso},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarPeso(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'peso',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
