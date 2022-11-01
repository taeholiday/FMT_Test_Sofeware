import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:hex/hex.dart';

class IctNk77TestPage extends StatefulWidget {
  const IctNk77TestPage({Key? key}) : super(key: key);

  @override
  State<IctNk77TestPage> createState() => _IctNk77TestPageState();
}

class _IctNk77TestPageState extends State<IctNk77TestPage> {
  double size = 0.0;
  List<String>? devices;
  String? status = "";
  String? deviceSelect;
  SerialPort? port;
  List<int> tempDataAll = [];

  @override
  void initState() {
    super.initState();
    _getPort();
  }

  @override
  void dispose() {
    port!.close();
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
        title: const Text("bill acceptor NK77"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "สถานะ : $status",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 2,
                  fontSize: 20,
                  color: Color.fromARGB(255, 0, 16, 236)),
            ),
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.4,
              child: Image.asset("images/NK77.jpg"),
            ),
            const Text(
              "NK 77",
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
                          .map<DropdownMenuItem<String>>((String value) {
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
                'ส่งคำสั่ง 02',
                directions02,
              ),
            ),
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'ส่งคำสั่ง 5B',
                directions5B,
              ),
            ),
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'ส่งคำสั่ง 5C',
                directions5C,
              ),
            ),
          ],
        ),
      ),
    );
  }

  directions5C() {
    List<String> dataString = [];
    var newData;
    List<int> data5C = [];
    dataString
        .add("5b4e4b37372d2d2d2d49435430303000000000000000000000000000000000");
    if (dataString[0].indexOf('4e') != -1) {
      newData =
          HEX.decode(dataString[0].substring(dataString[0].indexOf('4e')));
    }
    data5C = newData;
    port!.config.baudRate = 9600;
    port!.config.bits = 7;
    port!.config.parity = SerialPortParity.even;
    port!.config.stopBits = 1;
    port!.config.setFlowControl(SerialPortFlowControl.none);

    port!.write(
        Uint8List.fromList([
          0x5C,
          0x4E,
          0x4B,
          0x37,
          0x37,
          0x2D,
          0x2D,
          0x2D,
          0x2D,
          0x49,
          0x43,
          0x54,
          0x30,
          0x30,
          0x30,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00
        ]),
        timeout: 5);

    // if (dataString.contains(
    //     '5b4e4b37372d2d2d2d494354303030 00 000 000 000 000 000 000 000 000 000 000')) {
    //   List<String> newData = dataString
    //       .where((element) =>
    //           element ==
    //           '4e4b37372d2d2d2d49435430303000000000000000000000000000000000')
    //       .toList();
    //       print(newData);
    // }
    // tempDataAll.removeAt(0);
    // print(HEX.encode(tempDataAll));
    // port!.write(Uint8List.fromList([0x5C, ...tempDataAll]));
    setState(() {
      status = "ส่งคำสั่ง 5C";
    });
  }

  directions5B() {
    port!.config.baudRate = 9600;
    port!.config.bits = 8;
    port!.config.parity = SerialPortParity.even;
    port!.config.stopBits = 1;
    port!.config.setFlowControl(SerialPortFlowControl.none);
    print("parity bit ${SerialPortParity.even}");

    port!.write(Uint8List.fromList([0x5B]));
    setState(() {
      status = "ส่งคำสั่ง 5B";
    });
  }

  directions02() {
    port!.config.baudRate = 9600;
    port!.config.bits = 8;
    port!.config.parity = SerialPortParity.even;
    port!.config.stopBits = 1;
    port!.config.setFlowControl(SerialPortFlowControl.none);

    print("parity bit ${SerialPortParity.even}");

    port!.write(Uint8List.fromList([0x02]));
    setState(() {
      status = "ส่งคำสั่ง 02";
    });
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
          print('Read Data :');
          print(HEX.encode(data));
          if (HEX.encode(data).length >= 6) {
            tempDataAll.addAll(data);
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
