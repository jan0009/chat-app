import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:chatapp/View/Pages/invite_page.dart';
import 'package:chatapp/components/ButtonWithIcon.dart';
import 'package:chatapp/components/MyButton.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:chatapp/components/My_app_bar.dart';
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
        // await fetchChatsFromServer();
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userId: userId)),
        (route) => false, // entfernt alle vorherigen Seiten vom Stack
      );
      } else {
        logger.e("Fehler beim Löschen: ${response.statusCode}");
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
                          fontWeight: FontWeight.bold),
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
                    fontWeight: FontWeight.bold
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
                        elevation: 0, // Optional: kein Schatten, damit er wie der TextButton wirkt
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

              // const SizedBox(height: 120),
              Spacer(),

              //Delete Chat
              Padding(
                padding: const EdgeInsets.only(bottom: 64), 
                child: ButtonWithIcon(
                    onTap: () => goToCreateDeleteDialog(context),
                    // onTap: () {
                    //   showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return AlertDialog(
                    //         title: const Text("Chat löschen"),
                    //         content: const Text(
                    //           "Möchtest du diesen Chat wirklich löschen?",
                    //         ),
                    //         actions: [
                    //           TextButton(
                    //             child: const Text("Abbrechen"),
                    //             onPressed: () => Navigator.of(context).pop(),
                    //           ),
                    //           TextButton(
                    //             child: const Text(
                    //               "Löschen",
                    //               style: TextStyle(color: Colors.red),
                    //             ),
                    //             onPressed: () {
                    //               Navigator.of(context).pop(); // Dialog schließen
                    //               deleteChat(chatId, context); // Chat löschen
                    //             },
                    //           ),
                    //         ],
                    //       );
                    //     },
                    //   );
                    // },
                    icon: Icons.delete_forever,
                    iconColor: AppColors.greyTextColor,
                    iconSize: 40,
                    buttonText: "Chat löschen",
                    paddingToText: 48,    
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
