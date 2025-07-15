import 'package:flutter/material.dart';

class AIPage extends StatelessWidget {
  const AIPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Handwriting Recognition'),
        backgroundColor: Colors.greenAccent.shade400,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'AI Handwriting Recognition Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}