//stless
import 'package:chatapp/components/MyButton.dart';
import 'package:chatapp/components/MyTextField.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});

  
void logout(){}  
void deregister(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFb9d0e2),
      body: SafeArea(
        child: Center(
          child: Column(
          children:  [

            //Logo
            Center(
              child: Image.asset(
              'lib/images/Logo.png',
              height: 50,
              ),
            ),
          
            //Welcome 
            Text(
              'Welcome!',
              style: TextStyle(
                color: Color(0xFF16425B),
                fontSize: 20,
                ),
              ),

            const SizedBox(height: 50),

            //Sign in Button
            MyButton(
              onTap: logout,
              buttonText: "Log-Out",
              fontSize: 14,
              backgroundColor: Color(0xFF3A7CA5),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
            ),

            const SizedBox(height: 50),

            //Register
            MyButton(
              onTap: deregister,
              buttonText: "Deregister",
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