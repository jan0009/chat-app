import 'package:camera/camera.dart';
import 'package:chatapp/View/Pages/preview_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {

  final String chatId;

  const CameraPage({
    super.key,
    required this.chatId,
    });


  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Stack(
        children: [
          // 📸 Kamera-Vorschau über den ganzen Screen
          Positioned.fill(child: CameraPreview(_controller)),
          // 🔘 Zurück-Button oben links
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: "close_btn",
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close),
            ),
          ),
          // 📷 Foto aufnehmen Button unten mittig
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                heroTag: "capture_btn",
                onPressed: _takePicture,
                child: const Icon(CupertinoIcons.camera),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final XFile file = await _controller.takePicture();
      final bytes = await file.readAsBytes();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PreviewPage(imageBytes: bytes, chatId: widget.chatId)),
      );
    } catch (e) {
      print('Fehler beim Aufnehmen: $e');
    }
  }
}
