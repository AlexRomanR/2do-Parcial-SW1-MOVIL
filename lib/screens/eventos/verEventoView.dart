import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_asistencia_docente/models/evento.dart';
import 'package:gestion_asistencia_docente/services/api/eventosService.dart';

class EventoDetalleScreen extends StatelessWidget {
  final int eventoId;

  const EventoDetalleScreen({super.key, required this.eventoId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Evento>(
      future: Provider.of<EventosService>(context, listen: false)
          .loadEvento(context, eventoId.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
                title: const Text('Detalle del Evento',
                    style: TextStyle(color: Colors.white))),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
                title: const Text('Detalle del Evento',
                    style: TextStyle(color: Colors.white))),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
                title: const Text('Detalle del Evento',
                    style: TextStyle(color: Colors.white))),
            body: const Center(child: Text('Evento no encontrado')),
          );
        } else {
          final evento = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
                title: Text('Evento: ${evento.tipo}',
                    style: TextStyle(color: Colors.white))),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      evento.descripcion,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fecha: ${evento.fecha}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (evento.resumen.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen:',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 0, 0),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          evento.resumen,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  // Mostrar el icono de "asistencia confirmada" si la confirmación está en true
                  if (evento.confirmacion)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Asistencia Confirmada',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  // Mostrar el botón para confirmar asistencia solo si no hay resumen y ambos están en falso
                  if (evento.resumen.isEmpty &&
                      evento.asistencia == false &&
                      evento.confirmacion == false)
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final response = await Provider.of<EventosService>(
                                  context,
                                  listen: false)
                              .confirmarAsistencia(context, eventoId.toString());
                          if (response == 'hecho') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Asistencia confirmada')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error al confirmar asistencia')),
                            );
                          }
                        },
                        child: const Text('Confirmar Asistencia'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
