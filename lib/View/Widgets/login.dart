//stless
import 'package:chatapp/Shared/Constants/apiconstants.dart';
import 'package:chatapp/View/Entities/user_login.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:chatapp/View/Pages/register_page.dart';
import 'package:chatapp/components/MyButton.dart';
import 'package:chatapp/components/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //text editing controllers
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final logger = Logger();

  // //Sign In

  void startRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  Future<UserLogin?> handleLogin(BuildContext context) async {
    UserLogin? userLogin = await fetchApiLogin();

    if (userLogin == null) {
      logger.e('❌ Fehler: Login-API hat null zurückgegeben.');
      return null; // Falls die API fehlschlägt, wird `false` zurückgegeben
    }

    return userLogin;
  }

  Future<UserLogin?> fetchApiLogin() async {
    try {
      String userid = userNameController.text;
      String password = passwordController.text;

      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.getLogin}'
          '&userid=$userid'
          '&password=$password';

      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        UserLogin user = UserLogin.fromJson(jsonDecode(response.body));
        await secureStorage.write(key: "userid", value: user.userid);
        await secureStorage.write(key: "auth_token", value: user.token);

        //logger.e("token: ${user.token} ");

        return user;
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
      backgroundColor: Color(0xFFb9d0e2),

      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),

              //Logo
              Center(child: Image.asset('lib/images/Logo.png', height: 250)),

              const SizedBox(height: 15),

              //Welcome
              Text(
                'Welcome!',
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

              const SizedBox(height: 25),

              //Sign in Button
              MyButton(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  //bool loginSuccess = await handleLogin(context);
                  UserLogin? userLogin = await handleLogin(context);

                  // if (loginSuccess) {
                  //   navigator.pushReplacement(
                  //     MaterialPageRoute(builder: (context) => HomePage(userId: userLogin.userid)),
                  //   );
                  // } else {
                  //   messenger.showSnackBar(
                  //     SnackBar(
                  //       content: Text('Login failed. Please try again.'),
                  //     ),
                  //   );
                  if (userLogin != null && userLogin.success) {
                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                HomePage(userId: userNameController.text),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Login failed. Please try again.'),
                      ),
                    );
                  }
                },
                buttonText: "Sign In",
                fontSize: 16,
                backgroundColor: Color(0xFF3A7CA5),
              ),

              const SizedBox(height: 150),

              //Register
              MyButton(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  //bool loginSuccess = await handleLogin(context);
                  UserLogin? userLogin = await handleLogin(context);

                  if (userLogin != null && userLogin.success) {
                    navigator.pushReplacement(
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Login failed. Please try again.'),
                      ),
                    );
                  }
                },
                buttonText: "Register here!",
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
