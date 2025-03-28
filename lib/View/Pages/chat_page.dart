import 'package:chatapp/View/Entities/getchatmessages.dart';
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
import 'package:chatapp/View/Entities/chatmessages.dart';

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
  // List<types.Message> _messages = [];

  late MessageResponse messageResponse;
  bool _isLoaded = false;
  List<types.Message> _messages = [];


  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final logger = Logger();
  @override
  void initState() {
    super.initState();
    _loadMessages(); // Holt die Nachrichten beim Seitenstart
  }

  void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<MessageResponse> fetchMessagesFromServer() async {
    // const String apiUrl = '${ApiConstants.baseUrl}getmessages';

    String? token = await secureStorage.read(key: "auth_token");
    if (token == null) {
      logger.e("Kein Token gefunden");
      return MessageResponse.empty();
    }

    // try {
    //   final uri = Uri.parse('$apiUrl&token=$token&chatid=${0}');
    //   final response = await http.get(uri);

    //   if (response.statusCode == 200) {
    //     return MessageResponse.fromJson(jsonDecode(response.body));
    //   } else {
    //     logger.d('API Fehler: ${response.statusCode} - $apiUrl');
    //     return null;
    //   }
    // } catch (e) {
    //   logger.e('Fehler beim Abrufen der Nachrichten: $e');
    // }
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.getmessages}'
          '&token=$token';

      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(jsonDecode(response.body));
      } else {
        logger.d('API Fehler: ${response.statusCode} - $apiUrl');
        return MessageResponse.empty();
      }
    } catch (e, stacktrace) {
      logger.e('Fehler beim Abrufen der API: $e');
      logger.e('Stacktrace: $stacktrace');
      return MessageResponse.empty();
    }
  }

  void _loadMessages() async {
    messageResponse = await fetchMessagesFromServer();
    _messages =
        messageResponse.messages.map((msg) {
          return types.TextMessage(
            id: msg.id.toString(),
            author: types.User(id: msg.userid),
            text: msg.text,
            createdAt:
                DateFormat(
                  "yyyy-MM-dd_HH-mm-ss",
                ).parse(msg.time).millisecondsSinceEpoch,
            metadata: {'senderName': msg.usernick},
          );
        }).toList();

    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!(_isLoaded)) {
      return const Scaffold(
        backgroundColor: Color(0xFFb9d0e2),
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
          final senderName =
              (message as types.TextMessage).metadata?['senderName'] ??
              'Unbekannt';

          return MyMessage(
            message: message as types.TextMessage,
            currentUserId: widget.userId,
            senderName: senderName,
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

      metadata: {'senderName': 'Du'},
    );

    setState(() {
      _messages.insert(0, textMessage);
    });
  }
}
