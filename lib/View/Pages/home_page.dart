//stless
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/View/Entities/user_logout.dart';
import 'package:chatapp/View/Pages/account_page.dart';
import 'package:chatapp/View/Pages/chat_page.dart';
import 'package:chatapp/View/Widgets/login.dart';
import 'package:chatapp/components/MyButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchChatsFromServer();
  }

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

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
            if (hasToken) {
              await secureStorage.delete(key: "auth_token");
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
            title: const Text("Neuen Chat erstellen"),
            content: TextField(
              controller: _chatNameController,
              decoration: const InputDecoration(hintText: "Chatname"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Abbrechen"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = _chatNameController.text.trim();
                  if (name.isNotEmpty) {
                    await _createChat(name);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Erstellen"),
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

  List<Map<String, dynamic>> _chats = [];

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A7CA5),
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            handleLogout(context);
            goToLogin(context);
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => goToAccountPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Neuen Chat erstellen',
            onPressed: () => goToCreateChatDialog(context),
          ),
        ],

        elevation: 4.0,
      ),

      backgroundColor: Color(0xFFb9d0e2),
      body:
          _chats.isEmpty
              ? const Center(
                child: Text("Keine Chats verfügbar oder Fehler beim Laden."),
              ) // Ladeanzeige
              : ListView.builder(
                padding: const EdgeInsets.only(top: 20.0),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyButton(
                            onTap:
                                () => goToChat(
                                  context,
                                  chat['chatid'],
                                  chat['chatname'],
                                ),
                            buttonText:
                                chat['chatname'], // Dynamischer Chatname
                            fontSize: 14,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: const Color(0xFF3A7CA5),
                          ),
                        ),
                        if (chat['chatid'] != "0")
                          IconButton(
                            icon: Icon(Icons.delete, color: Color(0xDD16425B)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Chat löschen"),
                                    content: const Text(
                                      "Möchtest du diesen Chat wirklich löschen?",
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Abbrechen"),
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "Löschen",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pop(); // Dialog schließen
                                          deleteChat(
                                            chat['chatid'],
                                          ); // Chat löschen
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
    heroTag: 'inboxFab',
    tooltip: 'Einladungen',
    backgroundColor: const Color(0xFF3A7CA5),
    onPressed: _openInviteInbox,
    child: const Icon(Icons.mail_outline),
  ),
    );
  }
  Future<void> _openInviteInbox() async {
  final token = await secureStorage.read(key: 'auth_token');
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kein Token gefunden.')),
    );
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
}

