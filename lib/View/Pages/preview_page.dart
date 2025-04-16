import 'dart:convert';
import 'dart:typed_data';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class PreviewPage extends StatefulWidget {
  final Uint8List imageBytes;
  final String chatId;


  const PreviewPage({
    super.key,
     required this.imageBytes,
     required this.chatId
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final TextEditingController _textController = TextEditingController();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final logger = Logger();

  Future<void> _send() async{
    final text = _textController.text.trim();
    final image = widget.imageBytes;

    await sendMessageToServerWithImage(text, image);
}

Future<void> sendMessageToServerWithImage(String messageText, Uint8List imageBytes) async {
  const String apiUrl = ApiConstants.postUrl;
  String? token = await secureStorage.read(key: "auth_token");

  if (token == null) {
    logger.e("Kein Token gefunden");
    return;
  }

  try {

    // Bild als base64-String kodieren
    String base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'request': "postmessage",
        'token': token,
        'text': messageText,
        'photo': base64Image,
        'chatid': widget.chatId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'ok') {
        logger.d("Nachricht mit Bild erfolgreich gesendet");

        if (!mounted) return;
        Navigator.pop(context); // PreviewPage
        Navigator.pop(context);

      } else {
        logger.e("Fehler: ${responseData['message']}");
      }
    } else {
      logger.e("HTTP-Fehler: ${response.statusCode}");
    }
  } catch (e) {
    logger.e("Fehler beim Senden mit Bild: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildvorschau"),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _send,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: "Nachricht hinzufügen...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
