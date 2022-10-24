// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:image/image.dart';

class ThermalPrinterPage extends StatefulWidget {
  const ThermalPrinterPage({Key? key}) : super(key: key);

  @override
  State<ThermalPrinterPage> createState() => _ThermalPrinterPageState();
}

class _ThermalPrinterPageState extends State<ThermalPrinterPage> {
  List<Map<String, dynamic>> devices = [];
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool connected = false;

  @override
  initState() {
    super.initState();
    _getDevicelist();
  }

  _getDevicelist() async {
    List<Map<String, dynamic>> results = [];
    results = await FlutterUsbPrinter.getUSBDeviceList();

    print(" length: ${results.length}");
    setState(() {
      devices = results;
    });
  }

  _connect(int vendorId, int productId) async {
    bool? returned = false;
    try {
      returned = await flutterUsbPrinter.connect(vendorId, productId);
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
    if (returned!) {
      setState(() {
        connected = true;
      });
    }
  }

  testTicket() async {
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    bytes +=
        generator.text('Reverse text', styles: const PosStyles(reverse: true));
    bytes += generator.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    bytes += generator.text('Align left',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    final ByteData data = await rootBundle.load('images/barcode.png');
    final Uint8List byte = data.buffer.asUint8List();
    final image = decodeImage(byte);

    bytes += generator.image(image!);

    bytes += generator.qrcode('google.com', size: QRSize.Size8);

    bytes += generator.feed(2);
    bytes += generator.cut(mode: PosCutMode.partial);
    return bytes;
  }

  _print() async {
    try {
      var data = Uint8List.fromList(await testTicket());
      await flutterUsbPrinter.write(data);
      // await flutterUsbPrinter.printText("Testing ESC POS printer...");
      // await flutterUsbPrinter.printRawText("Testing ESC POS ");
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB PRINTER'),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _getDevicelist()),
          connected == true
              ? IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () {
                    _print();
                  })
              : Container(),
        ],
      ),
      body: devices.isNotEmpty
          ? ListView(
              scrollDirection: Axis.vertical,
              children: _buildList(devices),
            )
          : null,
    );
  }

  List<Widget> _buildList(List<Map<String, dynamic>> devices) {
    return devices
        .map((device) => ListTile(
              onTap: () {
                _connect(int.parse(device['vendorId']),
                    int.parse(device['productId']));
              },
              leading: const Icon(Icons.usb),
              title: Text(device['productName']),
              subtitle: Text(device['vendorId'] + " " + device['productId']),
            ))
        .toList();
  }
}
