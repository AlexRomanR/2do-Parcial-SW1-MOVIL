import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_asistencia_docente/services/api/notificaciones.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final notificacionesService =
        Provider.of<NotificacionesService>(context, listen: false);
    await notificacionesService.loadNotificaciones(context);
  }

  @override
  Widget build(BuildContext context) {
    final notificacionesService = Provider.of<NotificacionesService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () async {
              await notificacionesService.marcarTodasComoLeidas(context);
              notificacionesService.loadNotificaciones(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notificacionesService.notificaciones.length,
        itemBuilder: (context, index) {
          final notificacion = notificacionesService.notificaciones[index];
          final isRead = notificacion.readAt != false;

          return GestureDetector(
            onTap: () async {
              await notificacionesService.marcarComoLeida(
                  context, notificacion.id.toString());
              notificacionesService.loadNotificaciones(context);
              if (notificacion.type == 'entrevista') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificacionesScreen()), // Reemplazar con la vista de la entrevista
                );
              } else if (notificacion.type == 'nueva_tarea') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificacionesScreen()), // Reemplazar con la vista del contrato
                );
              }
            },
            child: Card(
              color: isRead ? Colors.grey[900] : Colors.white,
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
                      notificacion.type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isRead ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notificacion.data,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
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
