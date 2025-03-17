import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {

 final Function()? onTap;
 final String buttonText;
 final double fontSize;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const MyButton({
    super.key,
     required this.onTap,
      required this.buttonText,
      required this.fontSize,
      this.margin = const EdgeInsets.symmetric(horizontal: 25),
      this.padding = const EdgeInsets.all(25),
      this.backgroundColor = Colors.black, 
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
        child: Text(
          buttonText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize
          ),
        )
      )
      ),
    );
  }
}