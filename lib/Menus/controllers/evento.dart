import 'package:flutter/foundation.dart';
import '../models/evento.dart';

class EventoController extends ChangeNotifier {
  final Map<DateTime, List<Evento>> _eventosPorDia = {};

  List<Evento> getEventos(DateTime dia) {
    return _eventosPorDia[dia] ?? [];
  }

  void agregarEvento(DateTime dia, Evento evento) {
    _eventosPorDia.putIfAbsent(dia, () => []);
    _eventosPorDia[dia]!.add(evento);
    notifyListeners();
  }

  void editarEvento(DateTime dia, int index, Evento evento) {
    if (_eventosPorDia[dia] != null && index < _eventosPorDia[dia]!.length) {
      _eventosPorDia[dia]![index] = evento;
      notifyListeners();
    }
  }

  void eliminarEvento(DateTime dia, int index) {
    _eventosPorDia[dia]?.removeAt(index);
    notifyListeners();
  }
}
