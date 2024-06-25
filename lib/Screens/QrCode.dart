import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 300 - 2).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          _buildOverlay(),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: (scannedData != null)
                  ? Text(
                      'Scanned Data: $scannedData',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  : Text(
                      'Scan a code for check in/check out',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        scannedData = scanData.code;
      });

      // Assume scanned data contains the punch status
      if (scannedData != null) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt('punch_Status', scannedData == 'check_in' ? 1 : 0);

        // Show a static message for demonstration purposes
        String message =
            scannedData == 'check_in' ? 'Checked In' : 'Checked Out';
        String currentTime = TimeOfDay.now().format(context);

        // Display a snackbar with the static message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$message at $currentTime"),
          backgroundColor: Colors.greenAccent,
        ));

        Navigator.pop(context);
      }
    });
  }

  Widget _buildOverlay() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 300,
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: _animation.value,
                child: Container(
                  width: 300,
                  height: 2,
                  color: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void handleQRCodeResult(String qrCode) {
    // Simulate processing the QR code result
    // For example, update the punch status based on QR code data

    // This is where you handle the QR code result locally for now
    print("Scanned QR Code: $qrCode");

    // Display a snackbar or update the UI as needed
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("QR Code Scanned: $qrCode"),
      backgroundColor: Colors.greenAccent,
    ));

    // Update shared preferences or local state
    // For example, toggling punch status
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final cornerLength = 20.0;

    // Top left corner
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);

    // Top right corner
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom left corner
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom right corner
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
