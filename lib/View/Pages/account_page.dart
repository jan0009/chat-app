import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/View/Entities/user_logout.dart';
import 'package:chatapp/components/ButtonWithIcon.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/View/Pages/home_page.dart';
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

  Future<void> handleLogout(BuildContext context) async {
    // Store ScaffoldMessengerState before async operation
    final messenger = ScaffoldMessenger.of(context);

    // Get token from Secure Storage
    String? token = await secureStorage.read(key: "auth_token");

    if (token != null) {
      try {
        UserLogout? userLogout = await fetchApiLogout(token);
        if (userLogout != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userLogout.message,
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

          if (userLogout.success == true) {
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

  void createLogoutDialog(BuildContext context) {
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
                  "Möchten Sie sich wirklich abmelden ?",
                  style: TextStyle(
                    fontSize: 22,
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
                        "Nein",
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
                        await handleLogout(context);
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
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
                        "Ja",
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

  void createDeregisterDialog(BuildContext context) {
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
                  "Möchten Sie Ihr Konto wirklich löschen?",
                  style: TextStyle(
                    fontSize: 22,
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
                        await handleDeregister(context);
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // alles nach rechts schieben
                children: [
                  const SizedBox(width: 60),
                  Icon(
                    Icons.account_circle,
                    size: 64,
                    color: AppColors.greyTextColor,
                  ),
                  const SizedBox(width: 40),
                  const Text(
                    "Einstellungen",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Text ganz links
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Themenfarben",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Buttno für die Farbschema
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      // deine Aktion in Zukunft mehrere Auswahl möglichkeiten
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.themeColorLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48),
                      ),
                    ),
                    child: const Text(
                      "hell",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ),
                ),
              ),

              Spacer(),

              // Logout
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ButtonWithIcon(
                  onTap: () => createLogoutDialog(context),
                  icon: Icons.logout,
                  iconColor: AppColors.greyTextColor,
                  iconSize: 40,
                  buttonText: "Logout",
                  paddingToText: 88,
                  fontSize: 24,
                  backgroundColor: AppColors.lightgreyTextBox,
                ),
              ),

              // Deregister
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: ButtonWithIcon(
                  onTap: () => createDeregisterDialog(context),
                  icon: Icons.delete_forever,
                  iconColor: AppColors.greyTextColor,
                  iconSize: 40,
                  buttonText: "Deregister",
                  paddingToText: 72,
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
