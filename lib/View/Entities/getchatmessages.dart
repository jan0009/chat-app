import 'package:chatapp/View/Entities/chatmessages.dart';
import 'package:logger/logger.dart';

class MessageResponse {
  final List<ChatMessages> messages;
  final String? message;
  final String? status;
  final int code;

  MessageResponse({
    required this.messages,
    required this.message,
    required this.status,
    required this.code,
  });

  factory MessageResponse.empty() {
    return MessageResponse(
      messages: [],
      message: '',
      status: 'error',
      code: -1,
    );
  }

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    // final logger = Logger();
    List<dynamic> messages = json['messages'];

    // for (final message in messages) {
    //   logger.e(message.toString());
    // }

    // List<ChatMessages> liste =
    //     messages.map((m) => ChatMessages.fromJson(m)).toList();

    // for (final item in liste) {
    //   logger.e(item.toString());
    // }
 

    return MessageResponse(
      // messages:
      //     (json['messages'] as List)
      //         .map((m) => ChatMessages.fromJson(m))
      //         .toList(),
      messages: messages.map((m) => ChatMessages.fromJson(m)).toList(),
      message: json['message'],
      status: json['status'],
      code: json['code'],
    );
  }
}
