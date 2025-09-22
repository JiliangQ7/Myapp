class Comida {
  final int? id;
  final String username;
  final String titulo;
  final String descripcion;
  final int peso;
  final int puntuacion;
  final String? fotoPath;

  Comida({
    this.id,
    required this.username,
    required this.titulo,
    required this.descripcion,
    required this.peso,
    required this.puntuacion,
    this.fotoPath,
  });

  Comida copyWith({
    int? id,
    String? username,
    String? titulo,
    String? descripcion,
    int? peso,
    int? puntuacion,
    String? fotoPath,
  }) {
    return Comida(
      id: id ?? this.id,
      username: username ?? this.username,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      peso: peso ?? this.peso,
      puntuacion: puntuacion ?? this.puntuacion,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'titulo': titulo,
      'descripcion': descripcion,
      'peso': peso,
      'puntuacion': puntuacion,
      'fotoPath': fotoPath,
    };
  }

  factory Comida.fromMap(Map<String, dynamic> map) {
    return Comida(
      id: map['id'] as int?,
      username: map['username'] as String,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      peso: map['peso'] as int,
      puntuacion: map['puntuacion'] as int,
      fotoPath: map['fotoPath'] as String?,
    );
  }
}
