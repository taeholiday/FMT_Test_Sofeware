import 'package:flutter/material.dart';
import 'package:fmt_test_sofeware/barcode_scanner_page.dart';
import 'package:fmt_test_sofeware/camera_and_gallery_page.dart';
import 'package:fmt_test_sofeware/ict_device_page.dart';
import 'package:fmt_test_sofeware/thermal_printer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double size = 0.0;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("FMT Test Sofeware"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'Camera and gallery',
                testCameraFunction,
              ),
            ),
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'Thermal printer',
                testPrinter,
              ),
            ),
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'ICT Device Test',
                testICTDevice,
              ),
            ),
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'Barcode scanner',
                testBarcodeScanner,
              ),
            ),
          ],
        ),
      ),
    );
  }

  testBarcodeScanner() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerPage(),
        ));
  }

  testICTDevice() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IctDevicePage(),
        ));
  }

  testPrinter() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ThermalPrinterPage(),
        ));
  }

  testCameraFunction() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraAndGalleryPage(),
        ));
  }

  buttonGanareter(BuildContext context, String buttonName, Function function) {
    return ElevatedButton(
      onPressed: () {
        function();
      },
      child: Text(buttonName),
    );
  }
}
