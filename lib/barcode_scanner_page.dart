import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:fmt_test_sofeware/provider/set_string_provider/set_string_provider.dart';
import 'package:hex/hex.dart';
import 'package:provider/provider.dart';
import 'package:usb_serial/usb_serial.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  double size = 0.0;
  List<UsbDevice>? devices;
  String? deviceSelect;
  UsbPort? port;
  List<int> response = [];
  SetStringProvider setStringProvider = SetStringProvider();

  @override
  void initState() {
    super.initState();
    _getPort();
    Future.delayed(Duration.zero, () async {
      Provider.of<SetStringProvider>(context, listen: false).setString("");
    });
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
    setStringProvider = Provider.of<SetStringProvider>(context);
    size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text(
                ' ${setStringProvider.getString}',
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
                        items: devices!
                            .map<DropdownMenuItem<String>>((UsbDevice value) {
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
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'Config to command trigger mode',
                  configTriggerMode,
                ),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'Start scan',
                  startScanner,
                ),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'Stop scan',
                  stopScanner,
                ),
              ),
            ],
          ),
        ),
      ),
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
      try {
        port!.setPortParameters(9600, 8, UsbPort.STOPBITS_1, 0);

        //TODO: Read on port
        port!.inputStream!.listen((Uint8List data) async {
          response.addAll(data);
          print(HEX.encode(response));
          if (response.isNotEmpty &&
              HEX
                  .encode(response)
                  .contains("0201303030302353434e54524731063b03")) {
            setStringProvider.setString("Start scan");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX
                  .encode(response)
                  .contains("0201303030302353434e54524730063b03")) {
            setStringProvider.setString("Stop scan");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX
                  .encode(response)
                  .contains("0201303030304053434e4d4f4430063b03")) {
            setStringProvider.setString("Config to command trigger mode");
            response.clear();
          } else {
            Uint8List uint8list = Uint8List.fromList(response);
            DecodingResult result = await CharsetDetector.autoDecode(uint8list);
            setStringProvider.setString(result.string);
            response.clear();
          }
        });
      } on SerialPortError catch (err, _) {
        print(SerialPort.lastError);
        if (port != null) {
          port!.close();
        }
      }
    }
  }

  startScanner() {
    if (port != null) {
      port!.write(Uint8List.fromList([
        0x7E,
        0x01,
        0x30,
        0x30,
        0x30,
        0x30,
        0x23,
        0x53,
        0x43,
        0x4E,
        0x54,
        0x52,
        0x47,
        0x31,
        0x3B,
        0x03
      ]));
    }
  }

  configTriggerMode() {
    if (port != null) {
      port!.write(Uint8List.fromList([
        0x7E,
        0x01,
        0x30,
        0x30,
        0x30,
        0x30,
        0x40,
        0x53,
        0x43,
        0x4E,
        0x4D,
        0x4F,
        0x44,
        0x30,
        0x3B,
        0x03
      ]));
    }
  }

  stopScanner() {
    if (port != null) {
      port!.write(Uint8List.fromList([
        0x7E,
        0x01,
        0x30,
        0x30,
        0x30,
        0x30,
        0x23,
        0x53,
        0x43,
        0x4E,
        0x54,
        0x52,
        0x47,
        0x30,
        0x3B,
        0x03
      ]));
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
