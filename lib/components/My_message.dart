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
    final isOwn = message.author.id == currentUserId;
    final time = DateFormat('HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isOwn ? const Color(0xFF3A7CA5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isOwn) // Name nur anzeigen, wenn es nicht die eigene Nachricht ist
              Text(
                senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            if (!isOwn) const SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                color: isOwn ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isOwn ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}