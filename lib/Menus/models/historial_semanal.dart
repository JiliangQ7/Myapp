class HistorialSemanal {
  final int? id;
  final String username;
  final String fechaInicio;
  final String fechaFin;
  final double puntuacionTotal;

  HistorialSemanal({
    this.id,
    required this.username,
    required this.fechaInicio,
    required this.fechaFin,
    required this.puntuacionTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'puntuacionTotal': puntuacionTotal,
    };
  }

  factory HistorialSemanal.fromMap(Map<String, dynamic> map) {
    return HistorialSemanal(
      id: map['id'],
      username: map['username'],
      fechaInicio: map['fechaInicio'],
      fechaFin: map['fechaFin'],
      puntuacionTotal: map['puntuacionTotal'],
    );
  }
}
