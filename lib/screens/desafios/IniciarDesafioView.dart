import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/categoriasService.dart';
import 'package:gestion_asistencia_docente/services/api/preguntasService.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class IniciarDesafioView extends StatefulWidget {
  final int desafioId;
  const IniciarDesafioView({Key? key, required this.desafioId}) : super(key: key);

  @override
  State<IniciarDesafioView> createState() => _IniciarDesafioViewState();
}

class _IniciarDesafioViewState extends State<IniciarDesafioView> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionId;
  bool _hasSelectedOption = false;
  bool _isFirstTime = false;
  StreamController<int> _selectedCategoryStream = StreamController<int>();
  List<String> _categories = [];
  late ConfettiController _confettiController;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Server servidor = Server();
  late Timer _timer = Timer(Duration.zero, () {}); // Inicialización segura
  int _timeLeft = 60; // Tiempo en segundos
  bool _hasFinished = false;



  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _loadData(); // Cargar datos de inmediato al ingresar
    _startTimer(); // Iniciar el temporizador

  }
  
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          // Asignar el ID de la primera opción si no hay ninguna seleccionada
          if (_selectedOptionId == null && _currentQuestionIndex < context.read<PreguntaService>().preguntas.length) {
            final opciones = context.read<PreguntaService>().preguntas[_currentQuestionIndex].opciones;
            _selectedOptionId = (opciones.isNotEmpty) ? opciones.first.id : null;
          }
  
          // Llamar a _Siguiente o _Finalizar dependiendo de si estamos en la última pregunta
          if (!_hasFinished) {
            // Aquí llamamos a _Finalizar si estamos en la última pregunta
            if (_currentQuestionIndex == context.read<PreguntaService>().preguntas.length - 1) {
              _Finalizar(_selectedOptionId!);
            } else {
              _Siguiente(_selectedOptionId!, avanzar: true);
            }
          }
        }
      });
    });
  }




  Future<void> _loadData() async {
    await _checkIfFirstTime(); // Revisar si es la primera vez

    final preguntaService = Provider.of<PreguntaService>(context, listen: false);
    final categoriaService = Provider.of<CategoriaService>(context, listen: false);

    await categoriaService.loadCategorias(context);
    _categories = categoriaService.categorias.map((categoria) => categoria.nombre).toList();
    print("Categorías disponibles: $_categories");

    await preguntaService.loadPreguntasByDesafio(context, widget.desafioId);

    final preguntas = preguntaService.preguntas;
    if (preguntas.isNotEmpty) {
      String initialCategory = preguntas[0].categoriaNombre;
      int targetIndex = _categories.indexOf(initialCategory);
      print("Categoría de la primera pregunta: $initialCategory");

      // Iniciar la ruleta y detenerla en la categoría de la primera pregunta
      Future.delayed(Duration(seconds: 2), () {
        _selectedCategoryStream.add(targetIndex);
      });
    }

    // Mostrar el diálogo después de que se carguen todos los datos
    if (_isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstTimeDialog();
      });
    }
  }

  Future<String?> _getSessionId() async {
    return await _storage.read(key: 'session_id');
  }


  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'desafio_${widget.desafioId}_first_time';
    _isFirstTime = prefs.getBool(key) ?? true;

    if (_isFirstTime) {
      await prefs.setBool(key, false); // Actualizar para que no vuelva a mostrarse
    }
  }

  void _showFirstTimeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(1), // Oscurece completamente el fondo
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(
              "¡Descubre la categoría!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [Colors.orange, Colors.teal, Colors.yellow, Colors.pink],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "¡Suerte!",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FortuneBar(
                        selected: _selectedCategoryStream.stream,
                        items: [
                          for (var category in _categories)
                            FortuneItem(
                              child: Text(
                                category,
                                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                              ),
                            ),
                        ],
                        styleStrategy: UniformStyleStrategy(
                          borderWidth: 2,
                          borderColor: Colors.orange,
                        ),
                        onAnimationEnd: () {
                          _confettiController.play();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _selectedCategoryStream.close();
                _confettiController.stop();
              },
              child: Text(
                "Continuar",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _selectedCategoryStream.close();
    super.dispose();
    _confettiController.dispose();
    if (_timer.isActive) {
      _timer.cancel(); // Cancelar solo si el temporizador está activo
    }
  }


  Future<void> _Siguiente(int opcionId, {bool avanzar = true}) async {
    int userId = Provider.of<AuthService>(context, listen: false).user.id;
    final url = Uri.parse('${servidor.baseURL}/api/seleccionar_opcion/$userId/$opcionId');
    final sessionId = await _getSessionId();

    if (sessionId == null) {
      print("No se encontró el session_id");
      return;
    }
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId',
        },
        body: jsonEncode({}), 
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);
        if (data['result']['status'] == 'success') {
          print('oppcion seleccionada exitosamente ');
          print("Opción seleccionada: $opcionId");
          if (avanzar) {
            _nextQuestion();
          }
        } else {
          print('Error al marcar como leído: ${data['error']}');
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al marcar como leído: $e');
    }
  }

  // Función para manejar la acción de "Finalizar"
  Future<void> _Finalizar(int opcionId) async {
    if (_hasFinished) return;
    _hasFinished = true;
    _timer?.cancel();

    await _Siguiente(opcionId, avanzar: false);
    int userId = Provider.of<AuthService>(context, listen: false).user.id;
    final url = Uri.parse('${servidor.baseURL}/api/desafio/${widget.desafioId}/calcular_puntaje/$userId');
    final sessionId = await _getSessionId();

    if (sessionId == null) {
      print("No se encontró el session_id");
      return;
    }
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': 'session_id=$sessionId',
        })
        ..body = jsonEncode({});
  
      final response = await http.Response.fromStream(await request.send());
  
      print(response.body);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result']['status'] == 'success') {
          final int puntaje = data['result']['puntaje'];
          final int totalPreguntas = data['result']['total_preguntas'];
          final int respuestasCorrectas = data['result']['respuestas_correctas'];
            _confettiController.play();
          // Mostrar diálogo con los resultados
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.9), 
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.black87,
                title: Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.orangeAccent),
                    SizedBox(width: 10),
                    Text(
                      "¡Desafío Finalizado!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200, // Ajusta la altura según sea necesario
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        colors: [Colors.orange, Colors.teal, Colors.yellow, Colors.pink],
                        numberOfParticles: 20,
                        maxBlastForce: 10,
                        minBlastForce: 5,
                      ),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/utils/finalizado.png', // Ruta de la imagen
                              height: 100,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "¡Has completado el desafío!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Puntaje: $puntaje",
                              style: TextStyle(fontSize: 16, color: Colors.tealAccent),
                            ),
                            Text(
                              "Respuestas correctas: $respuestasCorrectas / $totalPreguntas",
                              style: TextStyle(fontSize: 16, color: Colors.tealAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      Navigator.pop(context, true); // Regresa a la vista anterior y recarga
                    },
                    child: Text(
                      "¡Bien!",
                      style: TextStyle(color: Colors.orangeAccent, fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          print('Error al finalizar desafío: ${data['error']}');
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al marcar como leído: $e');
    }

  }

void _nextQuestion() {
  if (_currentQuestionIndex < context.read<PreguntaService>().preguntas.length - 1) {
    setState(() {
      _currentQuestionIndex++;
      _selectedOptionId = null;
      _hasSelectedOption = false;
      
      // Reiniciar el tiempo y cancelar el temporizador anterior
      _timeLeft = 60; 
      _timer.cancel();
      _startTimer(); // Iniciar el temporizador de nuevo para la nueva pregunta
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final preguntaService = Provider.of<PreguntaService>(context);
    final preguntas = preguntaService.preguntas;

    if (preguntaService.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.grey)),
      );
    }

    if (preguntas.isEmpty) {
      return Scaffold(
        body: Center(child: Text("No hay preguntas disponibles", style: TextStyle(color: Colors.grey))),
      );
    }

    final preguntaActual = preguntas[_currentQuestionIndex];
    double progress = _timeLeft / 60;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.question_answer, color: Colors.grey[400]),
            SizedBox(width: 8),
            Text('Pregunta ${_currentQuestionIndex + 1} de ${preguntas.length}', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.tealAccent,
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  "$_timeLeft s",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 1, blurRadius: 6, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 30, color: Colors.grey[500]),
                  SizedBox(height: 8),
                  Text(
                    preguntaActual.texto,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: preguntaActual.opciones.length,
                itemBuilder: (context, index) {
                  final opcion = preguntaActual.opciones[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOptionId = opcion.id;
                        _hasSelectedOption = true;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedOptionId == opcion.id ? Colors.tealAccent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          opcion.texto,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        leading: Radio<int>(
                          value: opcion.id,
                          groupValue: _selectedOptionId,
                          onChanged: (value) {
                            setState(() {
                              _selectedOptionId = value;
                              _hasSelectedOption = true;
                            });
                          },
                          activeColor: Colors.tealAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _hasSelectedOption
                  ? () {
                      if (_currentQuestionIndex == preguntas.length - 1) {
                        _Finalizar(_selectedOptionId!); // Llama a la función _Finalizar si es la última pregunta
                      } else {
                        _Siguiente(_selectedOptionId!, avanzar: true); // Llama a _Siguiente con el ID de la opción seleccionada
                      }
                    }
                  : null,
              icon: Icon(
                _currentQuestionIndex == preguntas.length - 1 ? Icons.flag : Icons.arrow_forward,
                color: Colors.white,
              ),
              label: Text(
                _currentQuestionIndex == preguntas.length - 1 ? "Finalizar" : "Siguiente",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
