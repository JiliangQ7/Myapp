
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/Menus/models/ejercicio.dart';

class EjercicioConEstado extends Ejercicio {
  final bool hecho;

  EjercicioConEstado({
    int? id,
    required String username,
    required String title,
    required String description,
    String? photoPath,
    String? videoPath,
    String? videoUrl,
    int? sets,
    int? descanso,
    double? puntuacion,
    double? peso,
    required this.hecho,
  }) : super(
          id: id,
          username: username,
          title: title,
          description: description,
          photoPath: photoPath,
          videoPath: videoPath,
          videoUrl: videoUrl,
          sets: sets,
          descanso: descanso,
          puntuacion: puntuacion,
          peso: peso,
        );

  factory EjercicioConEstado.fromMap(Map<String, dynamic> map) {
    return EjercicioConEstado(
      id: map['id'],
      username: map['username'],
      title: map['title'],
      description: map['description'],
      photoPath: map['photoPath'],
      videoPath: map['videoPath'],
      videoUrl: map['videoUrl'],
      sets: map['sets'],
      descanso: map['descanso'],
      puntuacion: (map['puntuacion'] as num?)?.toDouble(),
      peso: (map['peso'] as num?)?.toDouble(),
      hecho: (map['hecho'] ?? 0) == 1,
    );
  }
}

class EjercicioDatabase {
  static final EjercicioDatabase instance = EjercicioDatabase._init();
  static Database? _database;

  EjercicioDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ejercicios.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    ); 
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ejercicios(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      photoPath TEXT,
      videoPath TEXT,
      videoUrl TEXT,
      sets INTEGER,
      repeticiones INTEGER,
      descanso INTEGER,
      puntuacion REAL,
      peso REAL,
      duracion INTEGER,          -- <--- Agregado aquí
      hecho INTEGER DEFAULT 0
    )
    ''');

    await db.execute('''
      CREATE TABLE rutina_dia(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        ejercicio_id INTEGER NOT NULL,
        dia TEXT NOT NULL,
        hecho INTEGER DEFAULT 0,
        FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE historial_semanal(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        fecha_inicio TEXT NOT NULL,
        fecha_fin TEXT NOT NULL,
        puntuacion_total REAL NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE rutina_dia(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          ejercicio_id INTEGER NOT NULL,
          dia TEXT NOT NULL,
          FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE ejercicios ADD COLUMN peso REAL');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE rutina_dia ADD COLUMN hecho INTEGER DEFAULT 0');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE historial_semanal(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          fecha_inicio TEXT NOT NULL,
          fecha_fin TEXT NOT NULL,
          puntuacion_total REAL NOT NULL
        )
      ''');   //son las versiones 
    }
  }

  Future<int> create(Ejercicio ejercicio) async {
    final db = await instance.database;
    return await db.insert('ejercicios', ejercicio.toMap());
  }

  Future<Ejercicio?> readEjercicio(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'ejercicios',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Ejercicio.fromMap(maps.first) : null;
  }

  Future<List<Ejercicio>> readAllEjercicios(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'ejercicios',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'title ASC',
    );
    return result.map((json) => Ejercicio.fromMap(json)).toList();
  }

  Future<int> update(Ejercicio ejercicio) async {
    final db = await instance.database;
    return db.update(
      'ejercicios',
      ejercicio.toMap(),
      where: 'id = ?',
      whereArgs: [ejercicio.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'ejercicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> asignarEjercicioADia(String username, int ejercicioId, String dia) async {
    final db = await instance.database;
    final exists = await db.query(
      'rutina_dia',
      where: 'username = ? AND ejercicio_id = ? AND dia = ?',
      whereArgs: [username, ejercicioId, dia],
    );
    if (exists.isEmpty) {
      await db.insert('rutina_dia', {
        'username': username,
        'ejercicio_id': ejercicioId,
        'dia': dia,
        'hecho': 0,
      });
    }
  }

  Future<List<EjercicioConEstado>> leerEjerciciosPorDia(String username, String dia) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT e.*, r.hecho
      FROM ejercicios e
      INNER JOIN rutina_dia r ON e.id = r.ejercicio_id
      WHERE r.username = ? AND r.dia = ?
      ORDER BY e.title ASC
    ''', [username, dia]);

    return result.map((e) => EjercicioConEstado.fromMap(e)).toList();
  }

  Future<void> actualizarEstadoHecho(String username, int ejercicioId, String dia, bool hecho) async {
    final db = await instance.database;
    await db.update(
      'rutina_dia',
      {'hecho': hecho ? 1 : 0},
      where: 'username = ? AND ejercicio_id = ? AND dia = ?',
      whereArgs: [username, ejercicioId, dia],
    );
  }

  Future<void> eliminarEjercicioDeDia(String username, int ejercicioId, String dia) async {
    final db = await instance.database;
    await db.delete(
      'rutina_dia',
      where: 'username = ? AND ejercicio_id = ? AND dia = ?',
      whereArgs: [username, ejercicioId, dia],
    );
  }

  Future<double> calcularPuntosPorDia(String username, String dia) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(e.puntuacion)
      FROM ejercicios e
      INNER JOIN rutina_dia r ON e.id = r.ejercicio_id
      WHERE r.username = ? AND r.dia = ? AND r.hecho = 1
    ''', [username, dia]);

    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<double> calcularPuntosSemanales(String username) async {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    double total = 0.0;
    for (String dia in dias) {
      total += await calcularPuntosPorDia(username, dia);
    }
    return total;
  }

  Future<void> guardarHistorialSemanal({
    required String username,
    required String fechaInicio,
    required String fechaFin,
    required double puntuacionTotal,
  }) async {
    final db = await instance.database;
    await db.insert('historial_semanal', {
      'username': username,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'puntuacion_total': puntuacionTotal,
    });
  }

  Future<void> calcularYGuardarPuntuacionSemanal(String username) async {
    final db = await instance.database;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // lunes
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // domingo
    final fechaInicio = startOfWeek.toIso8601String().split('T').first;
    final fechaFin = endOfWeek.toIso8601String().split('T').first;

    final existe = await db.query(
      'historial_semanal',
      where: 'username = ? AND fecha_inicio = ? AND fecha_fin = ?',
      whereArgs: [username, fechaInicio, fechaFin],
    );

    if (existe.isNotEmpty) return; // Ya registrado

    final total = await calcularPuntosSemanales(username);

    await guardarHistorialSemanal(
      username: username,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      puntuacionTotal: total,
    );
  }




  Future<List<Map<String, dynamic>>> leerHistorialSemanal(String username) async {
    final db = await instance.database;
    return await db.query(
      'historial_semanal',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
