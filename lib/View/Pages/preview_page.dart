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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              widget.imageBytes,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 64,
            left: 24,
            child: SizedBox(
              width: 56,  
              height: 56, 
              child: FloatingActionButton(
                heroTag: "close_btn",
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 32),
              ),
            ),
          ),

          // Eingabebereich im Vordergrund unten
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(40, 16, 20, 48),
              decoration: const BoxDecoration(
                color: Color(0xFF2F6690),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Message",
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}