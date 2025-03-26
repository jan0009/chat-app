import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

class MyMessage extends StatelessWidget {
  final types.TextMessage message;
  final String currentUserId;
  final String senderName;

  const MyMessage({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    // Zeit formatieren (z.B. "10:44 Uhr")
    final time = DateFormat('HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0),
    );

    print("$senderName");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$senderName Â· $time', // Absender & Uhrzeit
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4), 
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: message.author.id == currentUserId
                ? const Color(0xFF3A7CA5) // Eigene Nachricht
                : Colors.white,           // Empfangene Nachricht
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.author.id == currentUserId
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}