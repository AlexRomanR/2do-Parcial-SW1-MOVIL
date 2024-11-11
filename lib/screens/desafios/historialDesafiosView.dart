import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/models/desafioEstudiante.dart';
import 'package:gestion_asistencia_docente/models/estadisticaEstudiante.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/cursosServices.dart';
import 'package:gestion_asistencia_docente/services/api/desafioEstudianteService.dart';
import 'package:gestion_asistencia_docente/services/api/estadisticasEstudianteService.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HistorialDesafiosView extends StatefulWidget {
  const HistorialDesafiosView({super.key});

  @override
  State<HistorialDesafiosView> createState() => _HistorialDesafiosViewState();
}

class _HistorialDesafiosViewState extends State<HistorialDesafiosView> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Server servidor = Server();
  late ConfettiController _confettiController;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final desafioEstudianteService = Provider.of<DesafioEstudianteService>(context, listen: false);
    final estadisticaEstudianteService = Provider.of<EstadisticaEstudianteService>(context, listen: false);
    final cursoService = Provider.of<CursoService>(context, listen: false);

    final cursos = await cursoService.loadCursosPorEstudiante(context);
    if (cursos.isNotEmpty) {
      final cursoId = cursos[0].id;

      await desafioEstudianteService.loadDesafioCompletadoEstudiantes(context);
      await estadisticaEstudianteService.loadEstadisticaEstudiantes(context, cursoId);
    } else {
      print("No se encontró curso para el estudiante.");
    }
  }

Future<void> _VerInformacion(int desafioId, desafioEstudiante) async {
  final prefs = await SharedPreferences.getInstance();
  bool isRevealed = prefs.getBool('desafio_revealed_$desafioId') ?? false;
  bool hasRevealed = isRevealed;
  ConfettiController _confettiController = ConfettiController(duration: Duration(seconds: 2));
  final authService = Provider.of<AuthService>(context, listen: false);
  final user = authService.user;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Color.fromARGB(255, 36, 36, 36),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Resultados",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/utils/user1.png'),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${user.name}',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${desafioEstudiante.puntajeEstudiante}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text("VS", style: TextStyle(color: Colors.white, fontSize: 20)),
                        ],
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/utils/user2.png'),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${desafioEstudiante.estudianteCompaneroNombre}',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          if (hasRevealed)
                            Text(
                              '${desafioEstudiante.puntajeCompanero}',
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (desafioEstudiante.puntajeCompanero == 0)
                    Text(
                      "Esperando oponente",
                      style: TextStyle(color: Colors.orangeAccent, fontSize: 16),
                    )
                  else if (!hasRevealed)
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          hasRevealed = true;
                        });
                        await prefs.setBool('desafio_revealed_$desafioId', true);
                        _confettiController.play();
                      },
                      child: Text("Revelar"),
                    ),
                  if (hasRevealed)
                    ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: [Colors.orange, Colors.teal, Colors.yellow, Colors.pink],
                    ),
                  if (hasRevealed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        desafioEstudiante.puntajeEstudiante > desafioEstudiante.puntajeCompanero ? "+2" : "-2",
                        style: TextStyle(
                          color: desafioEstudiante.puntajeEstudiante > desafioEstudiante.puntajeCompanero
                              ? Colors.green
                              : Colors.red,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),  
                ],
              ),
            ),
            
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cerrar", style: TextStyle(color: Colors.orangeAccent)),
              ),
            ],
          );
        },
      );
    },
  );
}


  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Método para obtener el puntaje promedio
  int _getPromedioPuntaje(int estudianteCompaneroId, List<EstadisticaEstudiante> estadisticas) {
    final estadistica = estadisticas.firstWhere(
      (e) => e.estudianteId == estudianteCompaneroId,
      orElse: () => EstadisticaEstudiante(
        estudianteId: estudianteCompaneroId,
        nombre: '',
        promedioDiasEntrega: 0,
        promedioPuntaje: 0,
      ),
    );
    return estadistica.promedioPuntaje;
  }

  @override
  Widget build(BuildContext context) {
    final desafioEstudianteService = Provider.of<DesafioEstudianteService>(context);
    final estadisticaEstudianteService = Provider.of<EstadisticaEstudianteService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.history, color: Colors.yellowAccent),
            SizedBox(width: 8),
            Text('Historial de Desafíos', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: desafioEstudianteService.isLoading || estadisticaEstudianteService.isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : ListView.builder(
              itemCount: desafioEstudianteService.desafiosEstudiantes.length,
              itemBuilder: (context, index) {
                final desafioEstudiante = desafioEstudianteService.desafiosEstudiantes[index];
                final promedioPuntaje = _getPromedioPuntaje(
                  desafioEstudiante.estudianteCompaneroId,
                  estadisticaEstudianteService.estadisticas,
                );

                return Card(
                  elevation: 4,
                  color: Color.fromARGB(255, 29, 29, 29),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      child: Icon(Icons.sports_kabaddi, color: Colors.white),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '👤 ${desafioEstudiante.estudianteCompaneroNombre}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '⭐ Puntaje Estudiantil: $promedioPuntaje',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '💬 "¡Oponente!"',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        _VerInformacion(desafioEstudiante.desafioId, desafioEstudiante);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.rocket_launch, color: Colors.white, size: 16),
                      label: Text(
                        "Ver Resumen",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
