import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdjustmentPage extends StatefulWidget {
  final String scannedData;

  const AdjustmentPage({super.key, required this.scannedData});

  @override
  State<AdjustmentPage> createState() => _AdjustmentPageState();
}

class _AdjustmentPageState extends State<AdjustmentPage> {
  late TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _dataController = TextEditingController(text: widget.scannedData);
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _saveToDatabase(String data) async {
    try {
      final response = await Supabase.instance.client
          .from('scanned_data') // Replace with your Supabase table name
          .insert({
        'code_id': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully!')),
        );
        Navigator.pop(context); // Go back to the previous page
      } else {
        throw response.error!.message;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Adjust Data',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.greenAccent.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scanned Data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edit scanned data...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => _saveToDatabase(_dataController.text),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}