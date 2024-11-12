import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/screens/categorias/crearCategoriaView.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/categoriasService.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CategoriasView extends StatefulWidget {
  const CategoriasView({super.key});

  @override
  State<CategoriasView> createState() => _CategoriasViewState();
}

class _CategoriasViewState extends State<CategoriasView> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Server servidor = Server();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _loadData());
  }
  
  Future<void> _loadData() async {
    final categoriaService = Provider.of<CategoriaService>(context, listen: false);
    await categoriaService.loadCategorias(context);
  }

  Future<String?> _getSessionId() async => await _storage.read(key: 'session_id');
  
  Future<void> _deleteCategoria(int idCategoria) async {
    final uri = Uri.parse('${servidor.baseURL}api/categoria/delete/$idCategoria');
    final sessionId = await _getSessionId();

    if (sessionId == null) {
      print("No se encontró el session_id");
      return;
    }
    
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId', // Agrega session_id aquí
        },
        body: jsonEncode({}), // Envía el body vacío como se requiere
      );
    

    if (response.statusCode == 200) {
      final categoriaService = Provider.of<CategoriaService>(context, listen: false);
      categoriaService.categorias.removeWhere((categoria) => categoria.id == idCategoria);
      categoriaService.notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría eliminada exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la categoría')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriaService = Provider.of<CategoriaService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CrearCategoria()),
              );
              if (result == true) _loadData();
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: categoriaService.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: categoriaService.categorias.length,
              itemBuilder: (context, index) {
                final categoria = categoriaService.categorias[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          categoria.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategoria(categoria.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
