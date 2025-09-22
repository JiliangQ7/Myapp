class Peso {
  final int? id;
  final String username;
  final double peso;
  final String fecha;

  Peso({
    this.id,
    required this.username,
    required this.peso,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'peso': peso,
      'fecha': fecha,
    };
  }

  factory Peso.fromMap(Map<String, dynamic> map) {
    return Peso(
      id: map['id'],
      username: map['username'],
      peso: map['peso'],
      fecha: map['fecha'],
    );
  }
}
