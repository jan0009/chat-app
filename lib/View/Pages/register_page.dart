import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/View/Entities/user_register.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/components/MyButton.dart';
import 'package:chatapp/components/MyTextField.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final nickNameController = TextEditingController();
  final fullNameController = TextEditingController();

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  void startRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  Future<bool> handleRegister(BuildContext context) async {
    UserRegister? userRegister = await fetchApiRegister();

    if (userRegister == null) {
      logger.e('❌ Fehler: Login-API hat null zurückgegeben.');
      return false; // Falls die API fehlschlägt, wird `false` zurückgegeben
    }

    return userRegister.success;
  }

  Future<UserRegister?> fetchApiRegister() async {
    try {
      String userid = userNameController.text;
      String password = passwordController.text;
      String nickname = nickNameController.text;
      String fullname = fullNameController.text;

      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.getRegister}'
          '&userid=$userid'
          '&password=$password'
          '&nickname=$nickname'
          '&fullname=$fullname';

      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        UserRegister userRegister = UserRegister.fromJson(jsonDecode(response.body));
        await secureStorage.write(key: "auth_token", value: userRegister.token);
        await secureStorage.write(key: "userid", value: userid);
        await secureStorage.write(key: "password", value: password);
        return userRegister;
      } else {
        logger.d('API Fehler: ${response.statusCode} - $apiUrl');
        return null;
      }
    } catch (e, stacktrace) {
      logger.e('🚨 Fehler beim Abrufen der API: $e');
      logger.e('📜 Stacktrace: $stacktrace');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFb9d0e2),
      appBar: AppBar(title: Text('Home'), backgroundColor: Color(0xFFb9d0e2)),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),

              //Logo
              Center(child: Image.asset('lib/images/Logo.png', height: 250)),

              Text(
                'Register',
                style: TextStyle(color: Color(0xFF16425B), fontSize: 20),
              ),

              const SizedBox(height: 25),

              //Username Textfiled
              MyTextField(
                controller: userNameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //Passwort textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),
              //Nickname Textfield
              MyTextField(
                controller: nickNameController,
                hintText: 'Nickname',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //Fullname Textfield
              MyTextField(
                controller: fullNameController,
                hintText: 'Fullname',
                obscureText: false,
              ),

              const SizedBox(height: 25),

              //Sign in Button
              MyButton(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  bool loginSuccess = await handleRegister(context);

                  if (loginSuccess) {
                    navigator.pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Register failed. Please try again.'),
                      ),
                    );
                  }
                },
                buttonText: "Register",
                fontSize: 16,
                backgroundColor: Color(0xFF3A7CA5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
