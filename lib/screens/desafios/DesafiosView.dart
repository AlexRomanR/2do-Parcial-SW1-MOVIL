import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/estadisticaEstudiante.dart';
import 'package:gestion_asistencia_docente/screens/desafios/IniciarDesafioView.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/services/api/cursosServices.dart';
import 'package:gestion_asistencia_docente/services/api/desafioEstudianteService.dart';
import 'package:gestion_asistencia_docente/services/api/estadisticasEstudianteService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DesafiosView extends StatefulWidget {
  const DesafiosView({super.key});

  @override
  State<DesafiosView> createState() => _DesafiosViewState();
}

class _DesafiosViewState extends State<DesafiosView> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Server servidor = Server();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final desafioEstudianteService = Provider.of<DesafioEstudianteService>(context, listen: false);
    final estadisticaEstudianteService = Provider.of<EstadisticaEstudianteService>(context, listen: false);
    final cursoService = Provider.of<CursoService>(context, listen: false);

    // Obtener el curso del estudiante
    final cursos = await cursoService.loadCursosPorEstudiante(context);
    if (cursos.isNotEmpty) {
      final cursoId = cursos[0].id;

      // Cargar desafíos y estadísticas usando el cursoId obtenido
      await desafioEstudianteService.loadDesafioEstudiantes(context);
      await estadisticaEstudianteService.loadEstadisticaEstudiantes(context, cursoId);
    } else {
      print("No se encontró curso para el estudiante.");
    }
  }

  Future<String?> _getSessionId() async {
    return await _storage.read(key: 'session_id');
  }

  Future<void> _startDesafio(int desafioId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IniciarDesafioView(desafioId: desafioId),
      ),
    );
  
    if (result == true) {
      // Vuelve a cargar los datos si _Finalizar() indicó una actualización
      _loadData();
    }
  }


  // Método para encontrar el puntaje promedio basado en estudiante_companero_id
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
            Icon(Icons.emoji_events, color: Colors.yellowAccent),
            SizedBox(width: 8),
            Text('Mis desafios aceptados', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
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
                        _startDesafio(desafioEstudiante.desafioId);
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
                        "Comenzar",
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
