import 'package:flutter/material.dart';

class WidgetTestPage extends StatelessWidget {
  const WidgetTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        leading: Icon(Icons.chat, color: Colors.white, size: 30),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        title: Text("LinkUp"),
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}
