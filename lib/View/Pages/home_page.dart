//stless
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/View/Entities/user_logout.dart';
import 'package:chatapp/View/Widgets/login.dart';
import 'package:chatapp/components/MyButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  Future<void> handleLogout(BuildContext context) async {
    // Store ScaffoldMessengerState before async operation
    final messenger = ScaffoldMessenger.of(context);

    // Retrieve the token
    String? token = await secureStorage.read(key: "auth_token");

    if (token != null) {
      try {
        UserLogout? userLogout = await fetchApiLogout(token);
        if(userLogout != null ){
          messenger.showSnackBar(
            SnackBar(
              content: Text(userLogout.message),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (error) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Fehler beim Logout: $error"),
            duration: Duration(seconds: 3),
          ),
        );
      }

    // Token nach erfolgreichem Logout löschen
    await secureStorage.delete(key: "auth_token");
    }
  }

  // void handleLogout() async {
  // UserLogin? userLogin = await fetchApiLogin();

  // if (userLogin == null) {
  //   logger.e('❌ Fehler: Login-API hat null zurückgegeben.');
  //   return false; // Falls die API fehlschlägt, wird `false` zurückgegeben
  // }

  // return userLogin.success;

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
      logger.e('🚨 Fehler beim Abrufen der API: $e');
      logger.e('📜 Stacktrace: $stacktrace');
      return null; // Verhindert App-Absturz
    }
  }

  void deregister() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFb9d0e2),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //Logo
              Center(child: Image.asset('lib/images/Logo.png', height: 50)),

              //Welcome
              Text(
                'Welcome!',
                style: TextStyle(color: Color(0xFF16425B), fontSize: 20),
              ),

              const SizedBox(height: 50),

              //Sign in Button
              MyButton(
                onTap: () async {
                  await handleLogout(context);
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                buttonText: "Log-Out",
                fontSize: 14,
                backgroundColor: Color(0xFF3A7CA5),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
              ),

              const SizedBox(height: 50),

              //Register
              MyButton(
                onTap: deregister,
                buttonText: "Deregister",
                fontSize: 14,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                backgroundColor: Color(0xFF3A7CA5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
