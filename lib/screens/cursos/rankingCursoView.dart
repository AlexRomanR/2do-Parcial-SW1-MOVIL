import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/cursos.dart';
import 'package:gestion_asistencia_docente/services/api/estadisticasEstudianteService.dart';
import 'package:gestion_asistencia_docente/services/api/resultadosService.dart';
import 'package:gestion_asistencia_docente/services/api/solicitudesDesafioService.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RankingCurso extends StatefulWidget {
  final Curso curso;

  const RankingCurso({
    Key? key,
    required this.curso,
  }) : super(key: key);

  @override
  State<RankingCurso> createState() => _RankingCursoState();
}

class _RankingCursoState extends State<RankingCurso> {
  bool isLoading = true;
  late ResultadoService resultadoService;
  late Map<int, int> puntajesTotales; // Mapa para almacenar puntajes totales de cada estudiante
  late Set<int> processedIds; // Conjunto para almacenar IDs procesados

  @override
  void initState() {
    super.initState();
    resultadoService = Provider.of<ResultadoService>(context, listen: false);
    puntajesTotales = {}; // Inicializar mapa de puntajes
    processedIds = {}; // Inicializar el conjunto de IDs procesados
    Future.delayed(Duration.zero, () {
      _loadData();
      final solicitudEnviadasService = Provider.of<SolicitudesDesafiosService>(context, listen: false);
      solicitudEnviadasService.loadSolicitudDesafioEnviado(context);
    });
  }

Future<void> _loadData() async {
  final estadisticaService = Provider.of<EstadisticaEstudianteService>(context, listen: false);
  await estadisticaService.loadEstadisticaEstudiantes(context, widget.curso.id);

  // Obtener lista completa de estudiantes
  final estudiantes = estadisticaService.estadisticas;
  final estudianteIds = estudiantes.map((e) => e.estudianteId).toSet(); // Usar `toSet` para evitar duplicados

  // Imprimir lista de IDs obtenidos
  print("Estudiante IDs obtenidos: $estudianteIds");

  // Procesar cada estudianteId y calcular puntaje total
  for (var estudianteId in estudianteIds) {
    if (!processedIds.contains(estudianteId)) {
      processedIds.add(estudianteId);
      final estudiante = estudiantes.firstWhere((e) => e.estudianteId == estudianteId);
      
      final puntajeTotal = await _calcularPuntajeTotal(estudianteId, estudiante.promedioPuntaje);
      puntajesTotales[estudianteId] = puntajeTotal;
    }
  }

  // Imprimir IDs procesados y puntajes totales para verificación
  print("Processed IDs: $processedIds");
  print("Puntajes Totales: $puntajesTotales");

  setState(() {
    isLoading = false;
  });
}


  Future<int> _calcularPuntajeTotal(int estudianteId, int promedioPuntaje) async {
    await resultadoService.loadResultado(context, estudianteId);
    if (resultadoService.resultado != null) {
      final puntosGanados = resultadoService.resultado!.puntosGanados;
      final puntosPerdidos = resultadoService.resultado!.puntosPerdidos;
      return (promedioPuntaje + puntosGanados) - puntosPerdidos;
    }
    return promedioPuntaje;
  }

  Future<void> _showDesafiarDialog(int desafianteId, int desafiadoId) async {
    final TextEditingController mensajeController = TextEditingController(text: "¡Te desafío!");
    final solicitudService = Provider.of<SolicitudesDesafiosService>(context, listen: false);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enviar Desafío"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enviale un mensaje a tu oponente:"),
              SizedBox(height: 10),
              TextField(
                controller: mensajeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Escribe tu mensaje aquí",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await solicitudService.createSolicitud(
                  context,
                  desafianteId,
                  desafiadoId,
                  mensajeController.text,
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.all(20),
                      title: Row(
                        children: [
                          Icon(Icons.star, color: Colors.orangeAccent),
                          SizedBox(width: 10),
                          Text("¡Desafío Enviado!"),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/utils/desafiar.png',
                            height: 100,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Desafío enviado exitosamente. Esperando respuesta.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "¡Entendido!",
                            style: TextStyle(color: Colors.orangeAccent),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final estadisticaService = Provider.of<EstadisticaEstudianteService>(context);
    final estudiantesOrdenados = estadisticaService.estadisticas
      ..sort((a, b) => (puntajesTotales[b.estudianteId] ?? b.promedioPuntaje)
          .compareTo(puntajesTotales[a.estudianteId] ?? a.promedioPuntaje));

    return Scaffold(
      appBar: AppBar(
        title: Text('Rankings del curso: ${widget.curso.displayName}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : ListView.builder(
              itemCount: estudiantesOrdenados.length,
              itemBuilder: (context, index) {
                final estudiante = estudiantesOrdenados[index];
                final puntajeTotal = puntajesTotales[estudiante.estudianteId] ?? estudiante.promedioPuntaje;
                IconData? medalIcon;
                Color? medalColor;

                if (index == 0) {
                  medalIcon = Icons.emoji_events;
                  medalColor = Colors.amber;
                } else if (index == 1) {
                  medalIcon = Icons.emoji_events;
                  medalColor = Colors.grey;
                } else if (index == 2) {
                  medalIcon = Icons.emoji_events;
                  medalColor = Colors.brown;
                }

                return Card(
                  color: Colors.grey[850],
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (medalIcon != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Icon(medalIcon, color: medalColor, size: 24),
                          ),
                      ],
                    ),
                    title: Text(
                      estudiante.nombre,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Promedio días de entrega: ${estudiante.promedioDiasEntrega}\nPuntaje total: $puntajeTotal',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Consumer<SolicitudesDesafiosService>(
                      builder: (context, solicitudEnviadasService, child) {
                        final isDesafiado = solicitudEnviadasService.estudiantesDesafiadosIds.contains(estudiante.estudianteId);
                        return isDesafiado
                            ? SizedBox.shrink()
                            : IconButton(
                                icon: Icon(MdiIcons.sword, color: Colors.orangeAccent),
                                onPressed: () {
                                  _showDesafiarDialog(
                                    Provider.of<AuthService>(context, listen: false).user.id,
                                    estudiante.estudianteId,
                                  );
                                },
                              );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
