import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:fmt_test_sofeware/provider/set_string_provider/set_string_provider.dart';
import 'package:hex/hex.dart';
import 'package:provider/provider.dart';

class SimDispensorTestPage extends StatefulWidget {
  const SimDispensorTestPage({Key? key}) : super(key: key);

  @override
  State<SimDispensorTestPage> createState() => _SimDispensorTestPageState();
}

class _SimDispensorTestPageState extends State<SimDispensorTestPage> {
  double size = 0.0;
  List<String>? devices;
  String? status = "";
  String? deviceSelect;
  SerialPort? port;
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
    port?.close();
    super.dispose();
  }

  _getPort() async {
    List<String> availablePort = SerialPort.availablePorts;

    if (availablePort.isNotEmpty) {
      setState(() {
        devices = availablePort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("SIM DISPENSOR"),
      ),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const Text(
            "SIM DISPENSOR",
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
                        devices!.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value..toString(),
                        child: Text(
                          value..toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        deviceSelect = value;
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
              'Move card to content IC position',
              moveCardToContentICposition,
            ),
          ),
          SizedBox(
            width: size > 600 ? size * 0.4 : size * 0.8,
            child: buttonGanareter(
              context,
              'Move card & hold card at bezel',
              moveCardAndHoldCardAtBezel,
            ),
          ),
          SizedBox(
            width: size > 600 ? size * 0.4 : size * 0.8,
            child: buttonGanareter(
              context,
              'Move card out of bezel',
              moveCardOutOfBezel,
            ),
          ),
          SizedBox(
            width: size > 600 ? size * 0.4 : size * 0.8,
            child: buttonGanareter(
              context,
              'Get Machine status ( current status)',
              getMachineStatusCurrentStatus,
            ),
          ),
        ],
      )),
    );
  }

  getMachineStatusCurrentStatus() {
    port!.config.baudRate = 9600;
    port!.config.bits = 8;
    port!.config.parity = SerialPortParity.none;
    port!.config.stopBits = 1;

    port!.write(Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x31, 0x30, 0x03, 0xB0]));
  }

  moveCardOutOfBezel() {
    port!.config.baudRate = 9600;
    port!.config.bits = 8;
    port!.config.parity = SerialPortParity.none;
    port!.config.stopBits = 1;

    port!.write(Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x39, 0x03, 0xBA]));
  }

  moveCardAndHoldCardAtBezel() {
    port!.config.baudRate = 9600;
    port!.config.bits = 8;
    port!.config.parity = SerialPortParity.none;
    port!.config.stopBits = 1;

    port!.write(Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x30, 0x03, 0xB3]));
  }

  moveCardToContentICposition() {
    port!.config.baudRate = 9600;
    port!.config.bits = 8;
    port!.config.parity = SerialPortParity.none;
    port!.config.stopBits = 1;

    port!.write(Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x31, 0x03, 0xB2]));
  }

  connectPort() {
    int index = devices!.indexWhere((element) => element == deviceSelect);

    if (index != null) {
      port = SerialPort(devices![index].toString());
    }

    bool openResult = port!.open(mode: SerialPortMode.readWrite);
    if (!openResult) {
      print("Failed to open");

      return;
    } else {
      print("success to open");

      try {
        //TODO: Read on port

        SerialPortReader reader = SerialPortReader(port!);
        Stream<Uint8List> upcommingData = reader.stream.map((data) {
          return data;
        });

        upcommingData.listen((data) {
          response.addAll(data);
          if (response.isNotEmpty &&
              HEX.encode(response).contains("06f20000065032313231300397")) {
            port!.config.baudRate = 9600;
            port!.config.bits = 8;
            port!.config.parity = SerialPortParity.none;
            port!.config.stopBits = 1;

            port!.write(Uint8List.fromList([0x06]));
            setStringProvider.setString(HEX.encode(response));
            response.clear();
          } else if (response.isNotEmpty &&
              HEX.encode(response).contains("06f20000065032303131300395")) {
            port!.config.baudRate = 9600;
            port!.config.bits = 8;
            port!.config.parity = SerialPortParity.none;
            port!.config.stopBits = 1;

            port!.write(Uint8List.fromList([0x06]));
            setStringProvider.setString(HEX.encode(response));
            response.clear();
          }
        });
      } on SerialPortError catch (err, _) {
        print(SerialPort.lastError);
        port!.close();
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
