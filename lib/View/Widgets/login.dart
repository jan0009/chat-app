//stless
import 'package:chatapp/Shared/Constants/apiconstants.dart';
import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/View/BottomNavBar/navigation.dart';
import 'package:chatapp/View/Entities/user_login.dart';
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
        await secureStorage.write(key: "userid", value: userNameController.text);
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
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 120),

              //Logo
              Center(child: Image.asset('lib/images/Logo.png', height: 182, width: 200,)),

              const SizedBox(height: 40),

              //Username Textfiled
              MyTextField(
                controller: userNameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 16),

              //Passwort textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 16),

              //Sign in Button
              MyButton(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  //bool loginSuccess = await handleLogin(context);
                  UserLogin? userLogin = await handleLogin(context);

                  if (userLogin != null && userLogin.success) {
                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                Navigation(userId: userNameController.text, token: userLogin.token),
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
                buttonText: "Login",
                fontSize: 24,
                backgroundColor: AppColors.blue,
              ),

              const SizedBox(height: 80),

              //Welcome
              Text(
                'Noch nicht dabei ? -  Registrieren dich jetzt ! ',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.greyTextColor, fontSize: 14),
              ),

              const SizedBox(height: 16),

              //Register
              MyButton(
                onTap: () async {
                  final navigator = Navigator.of(context);

                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                buttonText: "Register Now",
                fontSize: 24,
                backgroundColor: AppColors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}