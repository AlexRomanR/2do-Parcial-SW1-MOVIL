import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/screens/cursos/rankingCursoView.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/cursosServices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';


  class CursosView extends StatefulWidget {
    const CursosView({super.key});

    @override
    State<CursosView> createState() => _CursosViewState();
  }

  class _CursosViewState extends State<CursosView> {
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
      final comunicadoService = Provider.of<CursoService>(context, listen: false);
      await comunicadoService.loadCursosPorDocente(context);

    }
  
    Future<String?> _getSessionId() async {
      return await _storage.read(key: 'session_id');
    }
  
    @override
    Widget build(BuildContext context) {
      final cursoService = Provider.of<CursoService>(context);
      // Obtén el servicio de autenticación

      return Scaffold(
        appBar: AppBar(
          title: Text('Cursos', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        body: cursoService.isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.orange))
            : ListView.builder(
                itemCount: cursoService.cursos.length,
                itemBuilder: (context, index) {
                  final curso = cursoService.cursos[index];

                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(
                        curso.displayName,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                      icon: Icon(Icons.bar_chart, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RankingCurso(curso: curso),
                          ),
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