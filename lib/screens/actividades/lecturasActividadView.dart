import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/actividades.dart';
import 'package:gestion_asistencia_docente/models/lectoresActividades.dart';

class LecturasActividadView extends StatelessWidget {
  final Actividad actividad;
  final List<LectorActividad> lecturas;

  const LecturasActividadView({
    Key? key,
    required this.actividad,
    required this.lecturas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lecturas de ${actividad.motivo}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad: ${actividad.motivo}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              actividad.texto,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const Divider(color: Colors.grey),
            Text(
              'Lecturas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: lecturas.length,
                itemBuilder: (context, index) {
                  final lectura = lecturas[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        // Icono de estado de lectura
                        Icon(
                          lectura.leido ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: lectura.leido ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 10),
                        // Nombre del usuario y estado
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lectura.nombre,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lectura.leido ? 'Leído' : 'No leído',
                                style: TextStyle(
                                  color: lectura.leido ? Colors.green : Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Estado de envío
                        Text(
                          lectura.enviado ? 'Enviado' : 'No enviado',
                          style: TextStyle(
                            color: lectura.enviado ? Colors.blue : Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
