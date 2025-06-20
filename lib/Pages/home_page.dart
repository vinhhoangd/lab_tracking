import 'package:flutter/material.dart';
import 'adjustment_page.dart';
import 'package:lab_tracking/Scanning/mobile_scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.greenAccent.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar with QR code scanner icon
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      // Navigate to the scanner page
                      final scannedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileScannerPage(),
                        ),
                      );

                      if (scannedData != null) {
                        // Navigate to the adjustment page with the scanned data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdjustmentPage(scannedData: scannedData),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save to Database button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                // Navigate directly to the adjustment page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdjustmentPage(
                      scannedData: '', // Pass an empty string or default value
                    ),
                  ),
                );
              },
              child: const Text(
                'Save to Database',
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