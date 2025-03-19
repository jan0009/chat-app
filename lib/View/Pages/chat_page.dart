import 'package:chatapp/components/My_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:chatapp/view/pages/home_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;



class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}


class ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Chat", onBackPressed: () => goToHome(context),),

      backgroundColor: const Color(0xFFb9d0e2),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          primaryColor: const Color(0xFF3A7CA5),        
          backgroundColor: const Color(0xFFD9DCD6),       
          inputBackgroundColor: const Color(0xFF2F6690),    
          
          receivedMessageBodyTextStyle: const TextStyle(
            color: Color(0xFF16425B),  
          ),
          sentMessageBodyTextStyle: const TextStyle(
            color: Colors.white,
          ),
         
        
        )
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'some-unique-id',
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });
  }
}