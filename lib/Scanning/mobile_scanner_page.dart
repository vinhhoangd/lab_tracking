import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerPage extends StatelessWidget {
  const MobileScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner',
        style: TextStyle(
            color: Colors.black,
          ),),
        backgroundColor: Colors.greenAccent.shade400,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final String scannedData = barcode.rawValue!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scanned Data: $scannedData')),
              );

              // Navigate back with scanned data
              Navigator.pop(context, scannedData);
              break; // Exit the loop after handling the first valid barcode
            }
          }
        },
      ),
    );
  }
}