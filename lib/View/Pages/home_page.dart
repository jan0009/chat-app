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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchChatsFromServer();
    _loadUserId();
  }

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  Future<void> _loadUserId() async {
    String? storedUserId = await secureStorage.read(key: "userId");
    setState(() {
      userId = storedUserId;
    });
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

  // Future<void> handleDeregister(BuildContext context) async {
  //   // Store ScaffoldMessengerState before async operation
  //   final messenger = ScaffoldMessenger.of(context);

  //   // Get token from Secure Storage
  //   String? token = await secureStorage.read(key: "auth_token");

  //   if (token != null) {
  //     try {
  //       UserDeregister? userDeregister = await fetchApiDeregister(token);
  //       if (userDeregister != null) {
  //         messenger.showSnackBar(
  //           SnackBar(
  //             content: Text(userDeregister.message),
  //             duration: Duration(seconds: 4),
  //           ),
  //         );
  //         if (userDeregister.success == true) {
  //           bool hasToken = await secureStorage.containsKey(key: "auth_token");
  //           bool hasUserId = await secureStorage.containsKey(key: "userid");
  //           bool hasPassword = await secureStorage.containsKey(key: "password");

  //           if (hasToken) {
  //             await secureStorage.delete(key: "auth_token");
  //           }
  //           if (hasUserId) {
  //             await secureStorage.delete(key: "auth_token");
  //           }
  //           if (hasPassword) {
  //             await secureStorage.delete(key: "auth_token");
  //           }
  //         }
  //       }
  //     } catch (error) {
  //       messenger.showSnackBar(
  //         SnackBar(
  //           content: Text("Fehler beim Logout: $error"),
  //           duration: Duration(seconds: 8),
  //         ),
  //       );
  //     }
  //   }
  // }

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
                  ChatPage(chatId: chatId, chatName: chatName, userId: userId!),
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
      MaterialPageRoute(builder: (context) => AccountPage()),
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
                    'chatid':
                        chat['chatid'].toString(), // ✅ Typ in String umwandeln
                    'chatname': chat['chatname'] ?? 'Unbekannter Chat',
                    'role':
                        chat['role'] ??
                        'Unbekannte Rolle', // Optional hinzugefügt
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

                  return MyButton(
                    onTap:
                        () =>
                            goToChat(context, chat['chatid'], chat['chatname']),
                    buttonText: chat['chatname'], // Dynamischer Chatname
                    fontSize: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    backgroundColor: const Color(0xFF3A7CA5),
                  );
                },
              ),
    );
  }
}