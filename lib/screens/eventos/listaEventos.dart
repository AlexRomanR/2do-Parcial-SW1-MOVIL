import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_asistencia_docente/services/api/eventosService.dart';
import 'package:gestion_asistencia_docente/screens/eventos/verEventoView.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final eventosService = Provider.of<EventosService>(context, listen: false);
    await eventosService.loadEventos(context);
  }

  @override
  Widget build(BuildContext context) {
    final eventosService = Provider.of<EventosService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: eventosService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: eventosService.eventos.length,
              itemBuilder: (context, index) {
                final evento = eventosService.eventos[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventoDetalleScreen(eventoId: evento.id),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.grey[900],
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evento.tipo,
                            style: TextStyle(
                              color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            evento.descripcion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Fecha: ${evento.fecha}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
