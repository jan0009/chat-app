import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/View/Entities/user_register.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:chatapp/View/Widgets/login.dart';
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

  Future<UserRegister?> handleRegister(BuildContext context) async {
    return await fetchApiRegister();
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
        UserRegister userRegister = UserRegister.fromJson(
          jsonDecode(response.body),
        );
        await secureStorage.write(key: "auth_token", value: userRegister.token);
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32.0, 
                  color: AppColors.iconBlack,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),

              //Logo
              Center(child: Image.asset('lib/images/Logo.png', height: 182, width: 200,)),

              const SizedBox(height: 40),

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

              const SizedBox(height: 40),

              //Sign in Button
              MyButton(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  UserRegister? userRegister = await handleRegister(context);

                  if (userRegister != null && userRegister.success) {
                    await Future.delayed(Duration(milliseconds: 200));
                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                HomePage(userId: userNameController.text),
                      ),
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