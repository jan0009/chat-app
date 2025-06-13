import 'dart:async';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/View/Entities/user_logout.dart';
import 'package:chatapp/View/Pages/account_page.dart';
import 'package:chatapp/View/Pages/chat_page.dart';
import 'package:chatapp/View/Widgets/login.dart';
import 'package:chatapp/components/ChatButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:chatapp/View/Pages/inbox_page.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final String userId;
  List<Map<String, dynamic>> _chats = [];
  Timer? _refreshTimer;

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchChatsFromServer();
    

    _refreshTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) => fetchChatsFromServer(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> handleLogout(BuildContext context) async {
    // Store ScaffoldMessengerState before async operation
    final messenger = ScaffoldMessenger.of(context);

    // Get token from Secure Storage
    String? token = await secureStorage.read(key: "auth_token");

    if (token != null) {
      try {
        UserLogout? userLogout = await fetchApiLogout(token);
        if (userLogout != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(userLogout.message),
              duration: Duration(seconds: 4),
            ),
          );
          if (userLogout.success == true) {
            bool hasToken = await secureStorage.containsKey(key: "auth_token");
            bool hasUserId = await secureStorage.containsKey(key: "userid");
            bool hasPassword = await secureStorage.containsKey(key: "password");
            
            if (hasToken) {
              await secureStorage.delete(key: "auth_token");
            }
            if(hasUserId){
              await secureStorage.delete(key: "userid");
            }
            if(hasPassword){
              await secureStorage.delete(key: "password");
            }
          }
        }
      } catch (error) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Fehler beim Logout: $error"),
            duration: Duration(seconds: 8),
          ),
        );
      }

      // Token nach erfolgreichem Logout löschen
      await secureStorage.delete(key: "auth_token");
    }
  }

  Future<UserLogout?> fetchApiLogout(String token) async {
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.getLogout}'
          '&token=$token';

      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return UserLogout.fromJson(jsonDecode(response.body));
      } else {
        logger.d('API Fehler: ${response.statusCode} - $apiUrl');
        return null;
      }
    } catch (e, stacktrace) {
      logger.e('Fehler beim Abrufen der API: $e');
      logger.e('Stacktrace: $stacktrace');
      return null;
    }
  }

  void goToChat(BuildContext context, String chatId, String chatName) {
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ChatPage(chatId: chatId, chatName: chatName, userId: userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: Keine userId gefunden.')));
    }
  }

  void goToAccountPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountPage(userId: userId)),
    );
  }

  void goToCreateChatDialog(BuildContext context) {
    final TextEditingController _chatNameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ), 
            title: Row(
                children: const [
                  Icon(Icons.chat, color: AppColors.blue, size: 40),
                  SizedBox(width: 8), // Abstand zwischen Icon und Text
                  Text(
                    "Neuen Chat erstellen",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            content: TextField(
              controller: _chatNameController,
              decoration: const InputDecoration(hintText: "Chatname"),
            ),
            actions: [
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
              SizedBox(
                width: 128,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _chatNameController.text.trim();
                    if (name.isNotEmpty) {
                      await _createChat(name);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48),
                    ),
                    elevation: 0, // Optional: kein Schatten, damit er wie der TextButton wirkt
                  ),
                  child: const Text(
                    "Erstellen",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<String?> getToken() async {
    final token = await secureStorage.read(key: "auth_token");
    if (token == null) {
      logger.e("Kein Token gefunden (Token null)");
    }
    return token;
  }

  // List<Map<String, dynamic>> _chats = [];

  Future<void> fetchChatsFromServer() async {
    const String apiUrl = '${ApiConstants.baseUrl}${ApiConstants.getChats}';

    String? token = await getToken();

    if (token == null) {
      logger.e("Kein Token gefunden");
      return;
    }

    try {
      final uri = Uri.parse('$apiUrl&token=$token');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('chats')) {
          setState(() {
            _chats =
                (data['chats'] as List<dynamic>).map<Map<String, dynamic>>((
                  chat,
                ) {
                  return {
                    'chatid': chat['chatid'].toString(),
                    'chatname': chat['chatname'] ?? 'Unbekannter Chat',
                  };
                }).toList();
          });
        } else {
          logger.e("Kein 'chats'-Schlüssel in der Antwort gefunden.");
        }
      } else {
        logger.e("Fehler beim Abrufen der Chats: ${response.statusCode}");
        logger.e("Response Body: ${response.body}");
      }
    } catch (e) {
      logger.e("Fehler beim Abrufen der Chats: $e");
    }
  }

  Future<void> _createChat(String chatName) async {
    final token = await secureStorage.read(key: "auth_token");

    if (token == null) {
      logger.e("Kein Token gefunden.");
      return;
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}createchat&token=$token&chatname=$chatName',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        logger.i("✅ Chat erfolgreich erstellt.");
        fetchChatsFromServer();
      } else {
        logger.e("❌ Fehler beim Erstellen des Chats: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("❌ Ausnahme bei createchat: $e");
    }
  }

  Future<void> deleteChat(String chatId) async {
    final token = await secureStorage.read(key: "auth_token");
    if (token == null) {
      logger.e("Kein Token gefunden");
      return;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}deletechat&token=$token&chatid=$chatId',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        logger.i("Chat $chatId gelöscht");
        await fetchChatsFromServer();
      } else {
        logger.e("Fehler beim Löschen: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("❌ Fehler beim Löschen des Chats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: const Color(0xFF3A7CA5),
    //     title: const Text(
    //       "Home",
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontSize: 20,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     centerTitle: true,

    //     leading: IconButton(
    //       icon: const Icon(Icons.logout, color: Colors.white),
    //       onPressed: () async {
    //         handleLogout(context);
    //         goToLogin(context);
    //       },
    //     ),

    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.account_circle, color: Colors.white),
    //         onPressed: () => goToAccountPage(context),
    //       ),
    //     ],

    //     elevation: 4.0,
    //   ),

  // neue Appbar hier ist jetzt aber in der Navigation
  return Scaffold(
  //   appBar: AppBar(
  //     automaticallyImplyLeading: false,
  //     backgroundColor: AppColors.lightgreyTextBox,
  //     toolbarHeight: 132,
  //     flexibleSpace: Builder(
  //       builder: (context) {
  //         final topPadding = MediaQuery.of(context).padding.top + 24; // Dynamisch + extra Abstand
  //         return Padding(
  //           padding: EdgeInsets.only(top: topPadding, left: 48),
  //           child: Align(
  //             alignment: Alignment.topLeft,
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Image.asset(
  //                   'lib/images/Chatalyst-Icon.png',
  //                   width: 84,
  //                   height: 84,
  //                 ),
  //                 const SizedBox(width: 32),
  //                 Image.asset(
  //                   'lib/images/Chatalyst-Text.png',
  //                   width: 166,
  //                   height: 48,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   ),

      backgroundColor: AppColors.white,
      body:
          _chats.isEmpty
              ? const Center(
                child: Text("Keine Chats verfügbar oder Fehler beim Laden."),
              ) // Ladeanzeige
              : ListView.builder(
                padding: const EdgeInsets.only(top: 0.0),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: 24.0, right: 16, left: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChatButton(
                            onTap:
                                () => goToChat(
                                  context,
                                  chat['chatid'],
                                  chat['chatname'],
                                ),
                            buttonText:
                                chat['chatname'], // Dynamischer Chatname
                            fontSize: 18,
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            padding: const EdgeInsets.all(0),
                            backgroundColor: AppColors.lightgreyTextBox,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          backgroundColor: AppColors.blue,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
          onPressed: () => goToCreateChatDialog(context),
        ),
      ),
      // bottomNavigationBar: GNav(
      //   backgroundColor: AppColors.lightgreyTextBox,
      //   color: AppColors.ligthgreyBackgroundcolor,
      //   activeColor: AppColors.black,
      //   gap: 8,
      //   padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),

      //   tabMargin: const EdgeInsets.fromLTRB(0, 0, 0, 48),
      //   tabs: const [
      //     GButton(icon: Icons.today, iconSize: 48),
      //     GButton(icon: Icons.chat, iconSize: 48),
      //     GButton(icon: Icons.groups, iconSize: 48),
      //     GButton(icon: Icons.settings, iconSize: 48),
      // ]),
    );
  }

  Future<void> _openInviteInbox() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kein Token gefunden.')));
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InboxPage(token: token, userId: userId),
      ),
    );
  }

  // void _showFabMenu(BuildContext ctx) {
  //   showModalBottomSheet(
  //     context: ctx,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder:
  //         (_) => Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.mail_outline),
  //               title: const Text('Einladungen'),
  //               onTap: () {
  //                 Navigator.pop(ctx); // Bottom-Sheet schließen
  //                 _openInviteInbox(); // vorhandene Funktion
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.add),
  //               title: const Text('Neuen Chat erstellen'),
  //               onTap: () {
  //                 Navigator.pop(ctx);
  //                 goToCreateChatDialog(ctx); // vorhandene Funktion
  //               },
  //             ),
  //           ],
  //         ),
  //   );
  // }
}
