//stless
import 'package:chatapp/components/MyButton.dart';
import 'package:chatapp/components/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/View/Pages/register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //text editing controllers
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  //Sign In
  void signUserIn(){}

    void startRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
          children:  [
            const SizedBox(height: 50),

            //Logo
            const Icon(
            Icons.lock,
            size: 100,
            
            ),
            const SizedBox(height: 50),

            //Welcome 
            Text(
              'Welcome!',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                ),
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
              onTap: signUserIn,
              buttonText: "Sign In",
              fontSize: 16,
              
            ),

            const SizedBox(height: 300),

            //Register
            MyButton(
              onTap: () => startRegister(context),
              buttonText: "Register here!",
              fontSize: 14,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.black,
              )
            
                ],),
        ),
    ) 
    );
  }
}