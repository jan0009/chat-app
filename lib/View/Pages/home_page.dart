//stless
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/View/Entities/user_deregister.dart';
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

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  

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
      logger.e('🚨 Fehler beim Abrufen der API: $e');
      logger.e('📜 Stacktrace: $stacktrace');
      return null; // Verhindert App-Absturz
    }
  }

  // Future<UserDeregister?> fetchApiDeregister(String token) async {
  //   try {
  //     String apiUrl =
  //         '${ApiConstants.baseUrl}'
  //         '${ApiConstants.getDeregister}'
  //         '&token=$token';

  //     final uri = Uri.parse(apiUrl);
  //     final response = await http.get(uri);

  //     if (response.statusCode == 200) {
  //       return UserDeregister.fromJson(jsonDecode(response.body));
  //     } else {
  //       logger.d('API Fehler: ${response.statusCode} - $apiUrl');
  //       return null;
  //     }
  //   } catch (e, stacktrace) {
  //     logger.e('🚨 Fehler beim Abrufen der API: $e');
  //     logger.e('📜 Stacktrace: $stacktrace');
  //     return null; // Verhindert App-Absturz
  //   }
  // }

  //Funktion für Weiterleitung an die CHat Page 
  void goToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ChatPage(),
        ),
      ),
    );
  }

void goToAccountPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountPage(),
      ),
    );
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
          onPressed: () => handleLogout(context), 
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
      body: SafeArea(
        child: Center(
          child: Column(
            children: [

              //Logo
              Center(child: Image.asset('lib/images/Logo.png', height: 200)),

              

              const SizedBox(height: 50),

              /*//Log out Button
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
              */

              //Register
              // MyButton(
              //   onTap: () async {
              //     await handleDeregister(context);
              //     if (!context.mounted) return;
              //     Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoginPage()),
              //     );
              //   },
              //   buttonText: "Deregister",
              //   fontSize: 14,
              //   margin: const EdgeInsets.symmetric(horizontal: 10),
              //   padding: const EdgeInsets.all(10),
              //   backgroundColor: Color(0xFF3A7CA5),
              // ),

              // const SizedBox(height: 50),

              MyButton(
                onTap: () => goToChat(context),
                buttonText: "Chat",
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
