
import '../db/ejercicio_database.dart';

class LogrosController {
  Future<Map<String, dynamic>?> obtenerRegistroSemanaActual(String username) async {
    final fechaInicio = _inicioDeSemana(DateTime.now());
    final fechaFin = _finDeSemana(DateTime.now());

    final historialExistente = await EjercicioDatabase.instance.leerHistorialSemanal(username);

    Map<String, dynamic>? registro;

    try {
      registro = historialExistente.firstWhere(
        (registro) {
          DateTime inicioRegistro = DateTime.parse(registro['fecha_inicio']);
          DateTime finRegistro = DateTime.parse(registro['fecha_fin']);
          return inicioRegistro == fechaInicio && finRegistro == fechaFin;
        },
      );
    } catch (e) {
      registro = null;
    }

    if (registro == null) {
      final puntuacion = await EjercicioDatabase.instance.calcularPuntosSemanales(username);

      await EjercicioDatabase.instance.guardarHistorialSemanal(
        username: username,
        fechaInicio: fechaInicio.toIso8601String(),
        fechaFin: fechaFin.toIso8601String(),
        puntuacionTotal: puntuacion,
      );

      final nuevoHistorial = await EjercicioDatabase.instance.leerHistorialSemanal(username);

      try {
        registro = nuevoHistorial.firstWhere(
          (r) {
            DateTime inicioRegistro = DateTime.parse(r['fecha_inicio']);
            DateTime finRegistro = DateTime.parse(r['fecha_fin']);
            return inicioRegistro == fechaInicio && finRegistro == fechaFin;
          },
        );
      } catch (e) {
        registro = null;
      }
    }

    return registro;
  }

  DateTime _inicioDeSemana(DateTime fecha) {
    return fecha.subtract(Duration(days: fecha.weekday - 1));
  }

  DateTime _finDeSemana(DateTime fecha) {
    return _inicioDeSemana(fecha).add(const Duration(days: 6));
  }
}
