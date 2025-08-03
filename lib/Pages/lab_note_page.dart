import 'package:flutter/material.dart';

class LabNotePage extends StatelessWidget {
  const LabNotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Note'),
        backgroundColor: Colors.greenAccent.shade400,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Lab Note Page Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 