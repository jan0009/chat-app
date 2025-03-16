import 'package:flutter/material.dart';

class ContainerText extends StatelessWidget {
  const ContainerText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(color: Colors.black, width: 4),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
