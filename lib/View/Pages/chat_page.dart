import 'package:chatapp/components/My_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String userId;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.userId,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final logger = Logger();
  @override
  void initState() {
    super.initState();
    fetchMessagesFromServer(); // Holt die Nachrichten beim Seitenstart
  }

  void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
    );
  }

  Future<void> fetchMessagesFromServer() async {
    const String apiUrl = '${ApiConstants.baseUrl}getmessages';

    String? token = await secureStorage.read(key: "auth_token");
    if (token == null) {
      logger.e("Kein Token gefunden");
      return;
    }

    try {
      final uri = Uri.parse('$apiUrl&token=$token&chatid=${widget.chatId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['messages'] != null) {
          final List<dynamic> messagesData = responseData['messages'];

          final List<types.Message> loadedMessages = [];

          for (final msg in messagesData.reversed) {
            final senderId = msg['userid'].toString();
            final isOwnMessage = senderId == widget.userId;
            final photoId = msg['photoid'];
            final text = msg['text'].toString();
            final createdAt =
                DateFormat(
                  "yyyy-MM-dd_HH-mm-ss",
                ).parse(msg['time']).millisecondsSinceEpoch;

            final author = types.User(
              id: senderId,
              firstName: msg['usernick'] ?? 'Unbekannt',
            );

            if (photoId != null && photoId.toString().isNotEmpty) {
              final photoUrl =
                  '${ApiConstants.baseUrl}getphoto&token=$token&photoid=$photoId';

              loadedMessages.add(
                types.ImageMessage(
                  author: author,
                  createdAt: createdAt,
                  id: msg['id'].toString(),
                  name: "Bild",
                  size: 0,
                  uri: photoUrl,
                  metadata: {'text': text},
                ),
              );
            }

            if (text.isNotEmpty) {
              loadedMessages.add(
                types.TextMessage(
                  author: author,
                  createdAt: createdAt,
                  id: msg['id'].toString() + '_text',
                  text: text,
                  metadata: {'senderName': senderId, 'isOwn': isOwnMessage},
                ),
              );
            }
          }

          setState(() {
            _messages = loadedMessages;
          });
        } else {
          logger.e("Keine Nachrichten im Chat gefunden.");
        }
      } else {
        logger.e("Fehler beim Abrufen der Nachrichten: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Fehler beim Abrufen der Nachrichten: $e");
    }
  }

  Future<void> sendMessageToServer(String messageText) async {
    const String apiUrl = '${ApiConstants.postUrl}';

    String? token = await secureStorage.read(key: "auth_token");
    if (token == null) {
      logger.e("Kein Token gefunden");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'request': "postmessage",
          'token': token,
          'text': messageText,
          'chatid': "0",
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'ok') {
          logger.i("Nachricht erfolgreich gesendet");

          // Nachricht zur lokalen Anzeige hinzufÃ¼gen
          final textMessage = types.TextMessage(
            author: types.User(id: widget.userId),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: responseData['message-id'].toString(),
            text: messageText,
            metadata: {'senderName': 'Du'},
          );

          setState(() {
            _messages.insert(0, textMessage);
          });
        } else {
          logger.e(
            "Fehler beim Senden der Nachricht: ${responseData['message']}",
          );
        }
      } else {
        logger.e(
          "Serverfehler beim Senden der Nachricht: ${response.statusCode}",
        );
      }
    } catch (e) {
      logger.e("Fehler beim Senden der Nachricht: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.chatName} ',//${widget.chatId}
        onBackPressed: () => goToHome(context),
      ),

      backgroundColor: const Color(0xFFb9d0e2),

      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: types.User(id: widget.userId),
        showUserNames: true,
        showUserAvatars: false,
        theme: DefaultChatTheme(
          primaryColor: const Color(0xFF3A7CA5),
          backgroundColor: const Color(0xFFD9DCD6),
          inputBackgroundColor: const Color(0xFF2F6690),
          receivedMessageBodyTextStyle: const TextStyle(
            color: Color(0xFF16425B),
          ),
          sentMessageBodyTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    sendMessageToServer(message.text);
  }
}
