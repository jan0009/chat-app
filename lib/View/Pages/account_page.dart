import 'package:flutter/material.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:chatapp/components/My_app_bar.dart';
import 'package:chatapp/components/MyButton.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:chatapp/View/Widgets/login.dart';
import 'package:chatapp/View/Entities/user_deregister.dart';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';

class AccountPage extends StatelessWidget {
  final String userId;
  AccountPage({super.key, required this.userId});

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
    );
  }

  Future<void> handleDeregister(BuildContext context) async {
    // Store ScaffoldMessengerState before async operation
    final messenger = ScaffoldMessenger.of(context);

    // Get token from Secure Storage
    String? token = await secureStorage.read(key: "auth_token");

    if (token != null) {
      try {
        UserDeregister? userDeregister = await fetchApiDeregister(token);
        if (userDeregister != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(userDeregister.message),
              duration: Duration(seconds: 4),
            ),
          );
          if (userDeregister.success == true) {
            bool hasToken = await secureStorage.containsKey(key: "auth_token");
            bool hasUserId = await secureStorage.containsKey(key: "userid");
            bool hasPassword = await secureStorage.containsKey(key: "password");

            if (hasToken) {
              await secureStorage.delete(key: "auth_token");
            }
            if (hasUserId) {
              await secureStorage.delete(key: "userid");
            }
            if (hasPassword) {
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
    }
  }

  Future<UserDeregister?> fetchApiDeregister(String token) async {
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.getDeregister}'
          '&token=$token';

      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return UserDeregister.fromJson(jsonDecode(response.body));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Account",
        onBackPressed: () => goToHome(context),
      ),

      backgroundColor: const Color(0xFFb9d0e2),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 30.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 400,
            height: 50,
            child: MyButton(
              onTap: () async {
                await handleDeregister(context);
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              buttonText: "Deregister",
              fontSize: 14,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.red.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
