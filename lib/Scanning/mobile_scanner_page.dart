import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerPage extends StatefulWidget {
  const MobileScannerPage({super.key});

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage> {
  bool _isProcessing = false;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code Scanner',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.greenAccent.shade400,
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) async {
          if (_isProcessing) return;
          
          _isProcessing = true;
          await _controller?.stop();

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final String scannedData = barcode.rawValue!;
              
              if (mounted) {
                // Return the scanned data back to HomePage instead of using pushReplacement
                Navigator.pop(context, scannedData);
              }
              break;
            }
          }
        },
      ),
    );
  }
}