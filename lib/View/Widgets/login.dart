//stless
import 'package:chatapp/components/MyButton.dart';
import 'package:chatapp/components/MyTextField.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //text editing controllers
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  //Sign In
  void signUserIn(){}

  void startRegister(){}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFb9d0e2),
      body: SafeArea(
        child: Center(
          child: Column(
          children:  [
            const SizedBox(height: 100),

            //Logo
            Center(
              child: Image.asset(
              'lib/images/Logo.png',
              height: 250,
              ),
            ),
          

          
            const SizedBox(height: 15),

            //Welcome 
            Text(
              'Welcome!',
              style: TextStyle(
                color: Color(0xFF16425B),
                fontSize: 20,
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
              backgroundColor: Color(0xFF3A7CA5),
            ),

            const SizedBox(height: 150),

            //Register
            MyButton(onTap: startRegister,
             buttonText: "Register here!",
             fontSize: 14,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              backgroundColor: Color(0xFF3A7CA5),
              )
            
                ],),
        ),
    ) 
    );
  }
}