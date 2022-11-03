import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:hex/hex.dart';
import 'package:usb_serial/usb_serial.dart';

class BarcodeForSimDispenser extends StatefulWidget {
  const BarcodeForSimDispenser({Key? key}) : super(key: key);

  @override
  State<BarcodeForSimDispenser> createState() => _BarcodeForSimDispenserState();
}

class _BarcodeForSimDispenserState extends State<BarcodeForSimDispenser> {
  double size = 0.0;
  List<UsbDevice>? devices;
  String? deviceSelect;
  UsbPort? port;
  String result = '';

  @override
  void initState() {
    super.initState();
    _getPort();
  }

  @override
  void dispose() {
    if (port != null) {
      port!.close();
    }
    super.dispose();
  }

  _getPort() async {
    List<UsbDevice>? availablePort = await UsbSerial.listDevices();
    if (availablePort.isNotEmpty) {
      setState(() {
        devices = availablePort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Text(
          result,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              height: 2,
              fontSize: 20,
              color: Color.fromARGB(255, 0, 16, 236)),
        ),
        SizedBox(
          width: size > 600 ? size * 0.4 : size * 0.4,
          child: Image.asset("images/FM430.png"),
        ),
        const Text(
          "Newland NLS-FM430",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              height: 2,
              fontSize: 30,
              color: Color.fromARGB(255, 0, 16, 236)),
        ),
        devices != null
            ? SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: DropdownButton(
                  isExpanded: true,
                  value: deviceSelect,
                  items:
                      devices!.map<DropdownMenuItem<String>>((UsbDevice value) {
                    return DropdownMenuItem<String>(
                      value: value.deviceName.toString(),
                      child: Text(
                        value.productName.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      deviceSelect = value;
                      print("onChanged");
                      print(deviceSelect);
                    });
                  },
                ),
              )
            : Container(),
        SizedBox(
          width: size > 600 ? size * 0.4 : size * 0.8,
          child: buttonGanareter(
            context,
            'connect Port',
            connectPort,
          ),
        ),
      ],
    );
  }

  connectPort() async {
    int index =
        devices!.indexWhere((element) => element.deviceName == deviceSelect);

    if (index != -1) {
      port = await devices![index].create();
    }

    bool openResult = await port!.open();
    if (!openResult) {
      print("Failed to open");
      return;
    } else {
      print("success to open");
      setState(() {
        result = ("success to open");
      });
      try {
        port!.setPortParameters(9600, 8, UsbPort.STOPBITS_1, 0);

        //TODO: Read on port
        port!.inputStream!.listen((Uint8List data) async {
          DecodingResult tempResult = await CharsetDetector.autoDecode(data);
          print("result = ${tempResult.string}");
          setState(() {
            result = tempResult.string;
          });
        });
      } on SerialPortError catch (err, _) {
        print(SerialPort.lastError);
        if (port != null) {
          port!.close();
        }
      }
    }
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
