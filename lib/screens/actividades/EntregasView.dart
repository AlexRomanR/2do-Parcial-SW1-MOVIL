import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/actividades.dart';
import 'package:gestion_asistencia_docente/models/entregas.dart';
import 'package:gestion_asistencia_docente/screens/actividades/puntuarEntrega.dart';
import 'package:gestion_asistencia_docente/screens/actividades/verEntrega.dart';


class EntregasView extends StatelessWidget {
  final Actividad actividad;
  final List<Entrega> entregas;

  const EntregasView({
    Key? key,
    required this.actividad,
    required this.entregas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregas de ${actividad.motivo}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
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
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Divider(),
            Text(
              'Entregas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: entregas.length,
                itemBuilder: (context, index) {
                  final entrega = entregas[index];
                  return ListTile(
                    title: Text(entrega.estudianteNombre, 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 212, 212, 212))
                    ),
                    subtitle: Text('Puntaje: ${entrega.puntaje}',
                    style: TextStyle(color: Color.fromARGB(255, 212, 212, 212))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerEntregaViews(entrega: entrega),
                              ),
                            );
                          },
                          child: Text('Ver Archivo', style: TextStyle(color: Colors.blue)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PuntuarEntrega(entrega: entrega),
                              ),
                            );
                          },
                          child: Text('Puntuar', style: TextStyle(color: Colors.green)),
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