import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/View/BottomNavBar/navigation.dart';
import 'package:chatapp/View/Pages/invite_page.dart';
import 'package:chatapp/components/ButtonWithIcon.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';

class ChatSettings extends StatelessWidget {
  final String token;
  final String chatId;
  final String userId;
  final String chatName;

  ChatSettings({
    Key? key,
    required this.token,
    required this.chatId,
    required this.userId,
    required this.chatName,
  }) : super(key: key);

  final logger = Logger();

  Future<void> deleteChat(String chatId, context) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}deletechat&token=$token&chatid=$chatId',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        logger.i("Chat $chatId gelöscht");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Chat erfolgreich gelöscht",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => Navigation(userId: userId, token: token),
          ),
          (route) => false,
        );
      } else {
        logger.e("Fehler beim Löschen: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Du hast den Chat nicht erstellt du kannst ihn nicht löschen",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            duration: Duration(seconds: 7),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      logger.e("❌ Fehler beim Löschen des Chats: $e");
    }
  }

  void goToCreateDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.red, size: 40),
                    SizedBox(width: 16), // Abstand zwischen Icon und Text
                    Expanded(
                      child: Text(
                        "Achtung",
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.greyTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Abstand zur Beschreibung
                Text(
                  "Möchtest du diesen Chat wirklich löschen?",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.greyTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 128,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyTextColor,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                      ),
                      child: const Text(
                        "Abbrechen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  SizedBox(
                    width: 128,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Dialog schließen
                        deleteChat(chatId, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                        elevation:
                            0, // Optional: kein Schatten, damit er wie der TextButton wirkt
                      ),
                      child: const Text(
                        "Löschen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Future<void> leaveChat(String chatId, context) async {
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.leaveChat}'
          '&token=$token'
          '&chatid=$chatId';

      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        logger.i("Chat $chatId verlassen");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Chat erfolgreich verlassen",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => Navigation(userId: userId, token: token),
          ),
          (route) => false,
        );
      } else {
        logger.e("Fehler beim Löschen: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Chat konnte nicht verlassen werden",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      logger.e("❌ Fehler beim Löschen des Chats: $e");
    }
  }

  void goToCreateLeaveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.red, size: 40),
                    SizedBox(width: 16), // Abstand zwischen Icon und Text
                    Expanded(
                      child: Text(
                        "Achtung",
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.greyTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Abstand zur Beschreibung
                Text(
                  "Möchtest du diesen Chat wirklich verlassen?",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.greyTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 128,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyTextColor,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                      ),
                      child: const Text(
                        "Abbrechen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  SizedBox(
                    width: 128,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Dialog schließen
                        leaveChat(chatId, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                        elevation:
                            0, // Optional: kein Schatten, damit er wie der TextButton wirkt
                      ),
                      child: const Text(
                        "Verlassen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Einstellungen",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greyTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightgreyTextBox,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 32,
            color: AppColors.greyTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Freunde einladen Button
              ButtonWithIcon(
                onTap: () async {
                  final navigator = Navigator.of(context);

                  navigator.push(
                    MaterialPageRoute(
                      builder:
                          (context) => InvitePage(
                            token: token,
                            chatId: chatId,
                            userId: userId,
                            chatName: chatName,
                          ),
                    ),
                  );
                },
                buttonText: "Lade deine Freunde ein",
                paddingToText: 16,
                fontSize: 24,
                backgroundColor: AppColors.lightgreyTextBox,
                icon: Icons.groups,
                iconColor: AppColors.blue,
                iconSize: 32,
              ),

              Spacer(),

              //Leave Chat
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ButtonWithIcon(
                  onTap: () => goToCreateLeaveChatDialog(context),
                  icon: Icons.logout,
                  iconColor: AppColors.greyTextColor,
                  iconSize: 40,
                  buttonText: "Chat verlassen",
                  paddingToText: 60,
                  fontSize: 24,
                  backgroundColor: AppColors.lightgreyTextBox,
                ),
              ),

              //Delete Chat
              Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: ButtonWithIcon(
                  onTap: () => goToCreateDeleteDialog(context),
                  icon: Icons.delete_forever,
                  iconColor: AppColors.greyTextColor,
                  iconSize: 40,
                  buttonText: "Chat löschen",
                  paddingToText: 60,
                  fontSize: 24,
                  backgroundColor: AppColors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
