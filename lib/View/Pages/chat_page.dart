import 'package:chatapp/components/My_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:chatapp/view/pages/home_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chatapp/components/My_message.dart';

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
      MaterialPageRoute(builder: (context) => HomePage()),
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

          setState(() {
            _messages =
                messagesData.map<types.Message>((msg) {
                  return types.TextMessage(
                    author: types.User(id: msg['userid'].toString()),
                    createdAt:
                        DateFormat(
                          "yyyy-MM-dd_HH-mm-ss",
                        ).parse(msg['time']).millisecondsSinceEpoch,
                    id: msg['id'].toString(),
                    text: msg['text'].toString(),
                  );
                }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.chatName} ${widget.chatId}',
        onBackPressed: () => goToHome(context),
      ),

      backgroundColor: const Color(0xFFb9d0e2),

      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: types.User(id: widget.userId),
        customMessageBuilder: (message, {required int messageWidth}) {
          return MyMessage(
            message: message as types.TextMessage,
            currentUserId: widget.userId,
          );
        },
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
    final textMessage = types.TextMessage(
      author: types.User(id: widget.userId),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'some-unique-id',
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });
  }
}
