import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/View/Entities/user_validateToken.dart';
import 'package:chatapp/View/Widgets/login.dart';
import 'package:chatapp/view/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }


  Future<String?> getToken() async {
    final token = await secureStorage.read(key: "auth_token");
    if (token == null) {
      logger.e("Kein Token gefunden (Token null)");
      return null;
    }
    return token;
  }

  Future<String?> getUserId() async {
    final userid = await secureStorage.read(key: "userid");
    if (userid == null) {
      logger.e("Kein userid gefunden (userid null)");
      return null;
    }
    return userid;
  }

  Future<bool> validateToken() async {
    final token = await getToken();
    if (token == null) {
      return false;
    }
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.validateToken}'
          '&token=$token';

      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        ValidateToken validateToken = ValidateToken.fromJson(
          jsonDecode(response.body),
        );
        return validateToken.success;
      } else {
        logger.d('API Fehler: ${response.statusCode} - $apiUrl');
        return false;
      }
    } catch (e, stacktrace) {
      logger.e('🚨 Fehler beim Abrufen der API: $e');
      logger.e('📜 Stacktrace: $stacktrace');
      return false;
    }
  }

  Future<void> _checkAuth() async {
    bool isValid = await validateToken();
    String? userId = await getUserId();
    if (isValid && userId != null) {
      // Token ist gültig -> weiterleiten
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
      );
    } 
    else {
        setState(() {
          isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : LoginPage();
  }
}
