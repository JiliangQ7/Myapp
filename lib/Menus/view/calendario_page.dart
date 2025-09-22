import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'AgregarEditarEventoPage.dart';
import '../models/evento.dart';

class CalendarioPage extends StatefulWidget {
  final String username;

  const CalendarioPage({super.key, required this.username});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Evento>> _eventosPorDia = {};

  @override
  Widget build(BuildContext context) {
    final eventos = _eventosPorDia[_selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario - Usuario: ${widget.username}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                   //Si no hay eventos ese día, se inicializa la lista
                _eventosPorDia.putIfAbsent(_selectedDay!, () => []);
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 20),
          // muestra los eventos del día elegido
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventos del ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Si no hay eventos muestra un mensaje

                  eventos.isEmpty
                      ? const Text('No hay eventos asignados para este día.')
                      : Column(
                          children: eventos.asMap().entries.map((entry) {
                            final index = entry.key;
                            final evento = entry.value;
                            return ListTile(
                              leading: const Icon(Icons.event, color: Colors.blue),
                              title: Text('${evento.descripcion} - ${evento.hora.format(context)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () {
                                      _formularioEditarEvento(context, index);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _eventosPorDia[_selectedDay!]!.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 10),
                  // boton para agregar un evento
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      _formularioEvento(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar evento'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _formularioEvento(BuildContext context) async {
    if (_selectedDay == null) return;

    final nuevoEvento = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarEditarEventoPage(),
      ),
    );

    if (nuevoEvento != null) {
      setState(() {
        _eventosPorDia[_selectedDay!]!.add(nuevoEvento);
      });
    }
  }

  void _formularioEditarEvento(BuildContext context, int index) async {
    if (_selectedDay == null) return;

    final eventosDelDia = _eventosPorDia[_selectedDay!];

    if (eventosDelDia == null) return;
    if (index < 0 || index >= eventosDelDia.length) return;

    final eventoActual = eventosDelDia[index];

    final eventoEditado = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarEditarEventoPage(evento: eventoActual),
      ),
    );

    if (eventoEditado != null) {
      setState(() {
        eventosDelDia[index] = eventoEditado;
      });
    }
  }
}
