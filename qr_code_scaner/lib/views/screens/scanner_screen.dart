import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:torch_light/torch_light.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isFlashOn = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.amber,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          _buildOverlay(),
          Positioned(
            top: 50.h,
            left: (MediaQuery.of(context).size.width.h - 250.h) / 2.h,
            child: Container(
              height: 40.h,
              width: 230.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Color(0xff424141),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.image, color: Colors.white)),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Center(
              child: (result != null)
                  ? Text('Skanerlash natijasi: ${result!.code}')
                  : Text('Skanerlaydigan kodni joylashtiring'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        Center(
          child: ClipPath(
            clipper: _QRCodeClipper(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFlash() async {
    try {
      if (isFlashOn) {
        await TorchLigt.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      // Handle error if torch is not available or something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chiroqni yoqish/o\'chirishda xato ro\'y berdi: $e')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class _QRCodeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cutOutSize = 300;
    Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH((size.width - cutOutSize) / 2,
          (size.height - cutOutSize) / 2, cutOutSize, cutOutSize));
    return path..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
