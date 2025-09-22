import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ejercicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        title TEXT,
        description TEXT,
        sets INTEGER,
        descanso INTEGER,
        puntuacion INTEGER,
        videoUrl TEXT,
        imagePath TEXT,
        peso REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE comidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        nombre TEXT,
        descripcion TEXT,
        imagenPath TEXT,
        diaSemana TEXT
      )
    ''');


    await db.execute('''
      CREATE TABLE peso (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT,
  peso REAL,
  fecha TEXT
)
    ''');
  }


  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
