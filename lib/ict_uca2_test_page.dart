import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:fmt_test_sofeware/provider/set_string_provider/set_string_provider.dart';
import 'package:hex/hex.dart';
import 'package:provider/provider.dart';

class IctUCA2TextPage extends StatefulWidget {
  const IctUCA2TextPage({Key? key}) : super(key: key);

  @override
  State<IctUCA2TextPage> createState() => _IctUCA2TextPageState();
}

class _IctUCA2TextPageState extends State<IctUCA2TextPage> {
  double size = 0.0;
  List<String>? devices;
  String? deviceSelect;
  SerialPort? port;
  List<int> response = [];
  SetStringProvider setStringProvider = SetStringProvider();
  String? version;

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
    List<String> availablePort = SerialPort.availablePorts;
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
        title: const Text("coin acceptor UCA2"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(
                setStringProvider.getString.contains('901b0355')
                    ? "version firmware from hex : ${setStringProvider.getString}"
                    : "สถานะ : ${setStringProvider.getString}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 2,
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 16, 236)),
              ),
              setStringProvider.getString.contains('901b0355')
                  ? Text(
                      "version firmware from char : ${version}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 2,
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 16, 236)),
                    )
                  : Container(),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.4,
                child: Image.asset("images/uca2.jpg"),
              ),
              const Text(
                "UCA2",
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
                  'สั่งให้เครื่องรับเหรียญทำงาน',
                  coinAcceptorEnable,
                ),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'สั่งให้เครื่องรับเหรียญปิดการทำงาน',
                  coinAcceptorDisable,
                ),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'เช็ค version firmware เครื่องรับเหรียญ',
                  checkVersionFirmware,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  checkVersionFirmware() {
    if (port != null) {
      port!.write(Uint8List.fromList([0x90, 0x05, 0x03, 0x03, 0x9B]));
    }
  }

  coinAcceptorEnable() {
    if (port != null) {
      port!.write(Uint8List.fromList([0x90, 0x05, 0x01, 0x03, 0x99]));
      setStringProvider.setString("เครื่องรับเหรียญทำงาน");
      response.clear();
    }
  }

  coinAcceptorDisable() {
    if (port != null) {
      port!.write(Uint8List.fromList([0x90, 0x05, 0x02, 0x03, 0x9A]));
      setStringProvider.setString("เครื่องรับเหรียญปิดการทำงาน");
      response.clear();
    }
  }

  connectPort() {
    int index = devices!.indexWhere((element) => element == deviceSelect);

    if (index != -1) {
      port = SerialPort(devices![index].toString());
    }

    bool openResult = port!.openReadWrite();
    if (!openResult) {
      print("Failed to open");
      return;
    } else {
      print("success to open");
      try {
        port!.config.baudRate = 9600;
        port!.config.bits = 8;
        port!.config.parity = SerialPortParity.none;
        port!.config.stopBits = 1;
        port!.config.setFlowControl(SerialPortFlowControl.none);

        //TODO: Read on port

        SerialPortReader reader = SerialPortReader(port!);
        Stream<Uint8List> upcommingData = reader.stream.map((data) {
          return data;
        });

        upcommingData.listen((data) async {
          response.addAll(data);
          print(HEX.encode(response));
          if (response.isNotEmpty &&
              HEX.encode(response).contains("9006120603b1")) {
            setStringProvider.setString("1 บาทไหม่");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX.encode(response).contains("9006120503b0")) {
            setStringProvider.setString("2 บาทไหม่");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX.encode(response).contains("9006120103ac")) {
            setStringProvider.setString("1 บาทเก่า");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX.encode(response).contains("9006120203ad")) {
            setStringProvider.setString("2 บาทเก่า");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX.encode(response).contains("9006120303ae")) {
            setStringProvider.setString("5 บาท");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX.encode(response).contains("9006120403af")) {
            setStringProvider.setString("10 บาท");
            response.clear();
          } else if (response.isNotEmpty &&
              HEX.encode(response).contains('901b0355')) {
            setStringProvider.setString(HEX.encode(response));
            Uint8List uint8list = Uint8List.fromList(response);
            DecodingResult result = await CharsetDetector.autoDecode(uint8list);
            setState(() {
              version = result.string;
            });

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

  buttonGanareter(BuildContext context, String buttonName, Function function) {
    return ElevatedButton(
      onPressed: () {
        function();
      },
      child: Text(buttonName),
    );
  }
}
