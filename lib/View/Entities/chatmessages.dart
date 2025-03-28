class ChatMessages {
  final int id;
  final String userid;
  final String time;
  final int chatid;
  final String text;
  final String usernick;
  final String userhash;

  ChatMessages({
    required this.id,
    required this.userid,
    required this.time,
    required this.chatid,
    required this.text,
    required this.usernick,
    required this.userhash,
  });

  factory ChatMessages.fromJson(Map<String, dynamic> json) {

    return ChatMessages(
      id: json['id'],
      userid: json['userid'],
      time: json['time'],
      chatid: json['chatid'],
      text:  json['text'],
      usernick: json['usernick'],
      userhash: json['userhash'],
    );
  }
}
