import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/comunicados.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // Importa path_provider
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
class VerComunicadoViews extends StatefulWidget {
  final Comunicado comunicado;

  const VerComunicadoViews({Key? key, required this.comunicado}) : super(key: key);

  @override
  _VerComunicadoViewsState createState() => _VerComunicadoViewsState();
}

class _VerComunicadoViewsState extends State<VerComunicadoViews> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  VideoPlayerController? _videoController;
  late AudioPlayer _audioPlayer;
  late String mediaURL;
  bool isPlaying = false;
  bool isVideoInitialized = false;
  bool isPdfLoading = true;
  String? pdfFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    mediaURL = (widget.comunicado.publicURL ?? '').replaceAll('dl=0', 'dl=1');
    print('El URL de media es: $mediaURL');

    if (widget.comunicado.formatoarchivo == 'mp4' || widget.comunicado.formatoarchivo == 'mp3') {
      _initializeMediaFromPublicURL();
    } else if (widget.comunicado.formatoarchivo == 'pdf') {
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        isPdfLoading = true;
      });

      final response = await http.get(Uri.parse(mediaURL));
      final bytes = response.bodyBytes;
      final file = File('${(await getTemporaryDirectory()).path}/temp.pdf');
      await file.writeAsBytes(bytes);
      setState(() {
        pdfFilePath = file.path;
        isPdfLoading = false;
      });
    } catch (e) {
      print('Error al cargar PDF: $e');
      setState(() {
        isPdfLoading = false;
      });
    }
  }

  void _initializeMediaFromPublicURL() async {
    if (mediaURL.isNotEmpty) {
      if (widget.comunicado.formatoarchivo == 'mp4') {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaURL))
          ..initialize().then((_) {
            setState(() {
              isVideoInitialized = true;
            });
            _videoController?.play();
          });
      } else if (widget.comunicado.formatoarchivo == 'mp3') {
        try {
          await _audioPlayer.setUrl(mediaURL);
          setState(() {});
        } catch (e) {
          print('Error al reproducir audio desde mediaURL: $e');
        }
      }
    }
  }

  Future<String?> _getSessionId() async {
    return await _storage.read(key: 'session_id');
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildPdfViewer() {
    if (isPdfLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (pdfFilePath == null) {
      return Text(
        'No se pudo cargar el PDF',
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      );
    } else {
      return Expanded(
        child: PDFView(
          filePath: pdfFilePath!,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageSnap: true,
          pageFling: true,
          onRender: (_pages) {
           
          },
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: $error');
          },
        ),
      );
    }
  }

  Widget _buildAudioControls() {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.positionStream,
      builder: (context, snapshot) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        final position = snapshot.data ?? Duration.zero;
        
        return Column(
          children: [
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.orange),
                  onPressed: () {
                    final newPosition = position - Duration(seconds: 10);
                    _audioPlayer.seek(newPosition);
                  },
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.orange),
                  onPressed: () {
                    setState(() {
                      isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
                      isPlaying = !isPlaying;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.orange),
                  onPressed: () {
                    final newPosition = position + Duration(seconds: 10);
                    _audioPlayer.seek(newPosition);
                  },
                ),
              ],
            ),
            Text(
              "${position.toString().split('.').first} / ${duration.toString().split('.').first}",
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return [
      if (hours > 0) twoDigits(hours),
      twoDigits(minutes),
      twoDigits(seconds),
    ].join(':');
  }

  Widget _buildVideoControls() {
    return Column(
      children: [
        if (_videoController != null && _videoController!.value.isInitialized) ...[
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          VideoProgressIndicator(
            _videoController!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.orange,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_videoController!.value.position),
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  _formatDuration(_videoController!.value.duration),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.replay_10, color: Colors.orange),
                onPressed: () {
                  final newPosition = _videoController!.value.position - Duration(seconds: 10);
                  _videoController!.seekTo(newPosition);
                },
              ),
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.orange,
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.forward_10, color: Colors.orange),
                onPressed: () {
                  final newPosition = _videoController!.value.position + Duration(seconds: 10);
                  _videoController!.seekTo(newPosition);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ] else
          Center(child: CircularProgressIndicator()),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final Server servidor = Server();
    String imageUrl = servidor.baseURLSin + widget.comunicado.archivoUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Comunicado', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                widget.comunicado.motivo,
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                widget.comunicado.texto,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<String?>(
              future: _getSessionId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Text(
                    'No se pudo cargar el contenido',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  );
                }
                final sessionId = snapshot.data!;
                if (widget.comunicado.formatoarchivo == 'jpg' || widget.comunicado.formatoarchivo == 'png') {
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    headers: {
                      'Cookie': 'session_id=$sessionId',
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'No se pudo cargar la imagen',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      );
                    },
                  );
                } else if (widget.comunicado.formatoarchivo == 'mp4') {
                  return _buildVideoControls();
                } else if (widget.comunicado.formatoarchivo == 'mp3') {
                  return _buildAudioControls();
                } else if (widget.comunicado.formatoarchivo == 'pdf') {
                  return _buildPdfViewer();  
                } else {
                  return Text(
                    'Formato no soportado o contenido no disponible',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
