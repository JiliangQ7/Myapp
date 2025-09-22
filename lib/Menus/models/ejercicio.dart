class Ejercicio {
  final int? id;
  final String username;
  final String title;
  final String description;
  final String? photoPath;
  final String? videoPath;
  final String? videoUrl;
  final int? sets;
  final int? repeticiones;
  final int? descanso;
  final double? puntuacion;
  final double? peso;
  final int? duracion;

  Ejercicio({
    this.id,
    required this.username,
    required this.title,
    required this.description,
    this.photoPath,
    this.videoPath,
    this.videoUrl,
    this.sets,
    this.repeticiones,
    this.descanso,
    this.puntuacion,
    this.peso,
    this.duracion,
  });

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    return Ejercicio(
      id: map['id'],
      username: map['username'],
      title: map['title'],
      description: map['description'],
      photoPath: map['photoPath'],
      videoPath: map['videoPath'],
      videoUrl: map['videoUrl'],
      sets: map['sets'],
      repeticiones: map['repeticiones'],
      descanso: map['descanso'],
      puntuacion: (map['puntuacion'] as num?)?.toDouble(),
      peso: (map['peso'] as num?)?.toDouble(),
      duracion: map['duracion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'title': title,
      'description': description,
      'photoPath': photoPath,
      'videoPath': videoPath,
      'videoUrl': videoUrl,
      'sets': sets,
      'repeticiones': repeticiones,
      'descanso': descanso,
      'puntuacion': puntuacion,
      'peso': peso,
      'duracion': duracion,
    };
  }
}
