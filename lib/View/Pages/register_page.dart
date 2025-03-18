import 'package:flutter/material.dart';
import 'package:chatapp/components/MyButton.dart';
import 'package:chatapp/components/MyTextField.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final nickNameController = TextEditingController();
  final fullNameController = TextEditingController();

  void register(){}

  void login(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFb9d0e2),
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xFFb9d0e2),
        
      ) ,
      body: SafeArea(
        child: Center(
          child: Column(
          children:  [
            const SizedBox(height: 10),

            //Logo
            Center(
              child: Image.asset(
              'lib/images/Logo.png',
              height: 250,
              ),
            ),
          
             
            Text(
              'Register',
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

            const SizedBox(height: 10),
            //Nickname Textfield
            MyTextField(
              controller: nickNameController,
               hintText: 'Nickname',
               obscureText: false
            ),

            const SizedBox(height: 10),

            //Fullname Textfield
            MyTextField(
              controller: fullNameController,
               hintText: 'Fullname',
               obscureText: false
            ),

            
            const SizedBox(height: 25),

            //Sign in Button
            MyButton(
              onTap: register,
              buttonText: "Register",
              fontSize: 16,
              backgroundColor: Color(0xFF3A7CA5),
            ),  
          ],),
        ),
    ) 
    );
  }
}