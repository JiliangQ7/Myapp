import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/comida.dart';



import 'dart:async';

class ComidaDatabase {
  static final ComidaDatabase instance = ComidaDatabase._init();

  static Database? _database;

  ComidaDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('comidas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';

    // Tabla de comidas
    await db.execute('''
      CREATE TABLE comidas (
        id $idType,
        username $textType,
        titulo $textType,
        descripcion $textType,
        peso $intType,
        puntuacion $intType,
        fotoPath $textNullable
      )
    ''');

    // Tabla que relaciona comida dia y categoria
    await db.execute('''
      CREATE TABLE comida_dia_categoria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comidaId INTEGER NOT NULL,
        dia TEXT NOT NULL,
        categoria TEXT NOT NULL,
        username TEXT NOT NULL,
        FOREIGN KEY (comidaId) REFERENCES comidas(id) ON DELETE CASCADE
      )
    ''');
  }


  Future<Comida> insertComida(Comida comida) async {
    final db = await instance.database;
    final id = await db.insert('comidas', comida.toMap());
    return comida.copyWith(id: id);
  }

  Future<List<Comida>> getComidasPorUsuario(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'comidas',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
    return result.map((json) => Comida.fromMap(json)).toList();
  }

  Future<List<Comida>> getComidas() async {
    final db = await instance.database;
    final result = await db.query('comidas', orderBy: 'id DESC');
    return result.map((json) => Comida.fromMap(json)).toList();
  }

  Future<int> updateComida(Comida comida) async {
    final db = await instance.database;
    return db.update(
      'comidas',
      comida.toMap(),
      where: 'id = ?',
      whereArgs: [comida.id],
    );
  }

  Future<int> deleteComida(int id) async {
    final db = await instance.database;
    return await db.delete(
      'comidas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Relación comida dia categoria y con usuario
  Future<void> asignarComidaADiaCategoria(int comidaId, String dia, String categoria, String username) async {
    final db = await instance.database;
    await db.insert(
      'comida_dia_categoria',
      {
        'comidaId': comidaId,
        'dia': dia,
        'categoria': categoria,
        'username': username,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Comida>> obtenerComidasPorDiaYCategoriaYUsuario(String dia, String categoria, String username) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT comidas.* FROM comidas
      INNER JOIN comida_dia_categoria
      ON comidas.id = comida_dia_categoria.comidaId
      WHERE comida_dia_categoria.dia = ? 
        AND comida_dia_categoria.categoria = ? 
        AND comida_dia_categoria.username = ?
    ''', [dia, categoria, username]);

    return result.map((json) => Comida.fromMap(json)).toList();
  }


  Future<int> eliminarComidaDeDiaCategoria(int comidaId, String dia, String categoria, String username) async {
    final db = await instance.database;
    return await db.delete(
      'comida_dia_categoria',
      where: 'comidaId = ? AND dia = ? AND categoria = ? AND username = ?',
      whereArgs: [comidaId, dia, categoria, username],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'comidas.db');
    print('Eliminando base de datos en: $path');
    await deleteDatabase(path);
  }
}
