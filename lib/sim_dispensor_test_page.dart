import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:fmt_test_sofeware/barcode_for_sim_dispenser.dart';
import 'package:fmt_test_sofeware/provider/set_string_provider/set_string_provider.dart';
import 'package:hex/hex.dart';
import 'package:provider/provider.dart';

class SimDispensorTestPage extends StatefulWidget {
  const SimDispensorTestPage({Key? key}) : super(key: key);

  @override
  State<SimDispensorTestPage> createState() => _SimDispensorTestPageState();
}

class _SimDispensorTestPageState extends State<SimDispensorTestPage> {
  SetStringProvider setStringProvider = SetStringProvider();
  double size = 0.0;
  List<String>? devices;
  String? deviceSelect;
  SerialPort? port;
  List<int> response = [];
  List<String> reformateString = [];
  Timer? timer1;
  Timer? timer2;

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
    timer1?.cancel();
    timer2?.cancel();
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
        title: const Text('SIM Dispenser'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
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
                child: Image.asset("images/MTK.jpg"),
              ),
              const Text(
                "SIM Dispenser",
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
                            setStringProvider.setString(deviceSelect!);
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
              const Text(
                "Reset",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 2,
                    fontSize: 30,
                    color: Color.fromARGB(255, 0, 16, 236)),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'Reset &Capture card into capture box',
                  resetAndCaptureCardIntoCaptureBox,
                ),
              ),
              const Text(
                "Card Movement",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 2,
                    fontSize: 30,
                    color: Color.fromARGB(255, 0, 16, 236)),
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
                  'Move capture card',
                  moveCaptureCard,
                ),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'test',
                  callMoveCardeEvery5Seconds,
                ),
              ),
              const Text(
                "Inquire Status",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 2,
                    fontSize: 30,
                    color: Color.fromARGB(255, 0, 16, 236)),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'Get current status of machine',
                  currentStatusOfMachine,
                ),
              ),
              SizedBox(
                width: size > 600 ? size * 0.4 : size * 0.8,
                child: buttonGanareter(
                  context,
                  'Get basic status of machine',
                  basicStatusOfMachine,
                ),
              ),
              BarcodeForSimDispenser()
            ],
          ),
        ),
      )),
    );
  }

  callMoveCardeEvery5Seconds() {
    timer1 = Timer.periodic(const Duration(seconds: 4), (Timer t) {
      callTest();
    });
  }

  callTest() {
    int dataInt;
    dataInt = 0xF2 ^ 0x00 ^ 0x00 ^ 0x03 ^ 0x43 ^ 0x32 ^ 0x31 ^ 0x03;
    final Uint8List unit8List = Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x31, 0x03, dataInt]);
    port!.write(unit8List);
    timer2 = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      final Uint8List unit8List = Uint8List.fromList(
          [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x39, 0x03, 0xBA]);
      port!.write(unit8List);
    });
  }

  resetAndCaptureCardIntoCaptureBox() {
    final Uint8List unit8List = Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x30, 0x31, 0x03, 0xB0]);
    port!.write(unit8List);
    String tempData = HEX.encode(unit8List);
    var buffer = StringBuffer();
    for (int i = 0; i < tempData.length; i++) {
      buffer.write(tempData[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != tempData.length) {
        buffer.write(', ');
      }
    }

    setStringProvider.setString(buffer.toString());
    response.clear();
  }

  basicStatusOfMachine() {
    final Uint8List unit8List = Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x31, 0x31, 0x03, 0xB1]);
    port!.write(unit8List);
    String tempData = HEX.encode(unit8List);
    var buffer = StringBuffer();
    for (int i = 0; i < tempData.length; i++) {
      buffer.write(tempData[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != tempData.length) {
        buffer.write(', ');
      }
    }

    setStringProvider.setString(buffer.toString());
    response.clear();
  }

  currentStatusOfMachine() {
    final Uint8List unit8List = Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x31, 0x30, 0x03, 0xB0]);
    port!.write(unit8List);
    String tempData = HEX.encode(unit8List);
    var buffer = StringBuffer();
    for (int i = 0; i < tempData.length; i++) {
      buffer.write(tempData[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != tempData.length) {
        buffer.write(', ');
      }
    }

    setStringProvider.setString(buffer.toString());
    response.clear();
  }

  moveCaptureCard() {
    final Uint8List unit8List = Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x33, 0x03, 0xB0]);
    port!.write(unit8List);
    String tempData = HEX.encode(unit8List);
    var buffer = StringBuffer();
    for (int i = 0; i < tempData.length; i++) {
      buffer.write(tempData[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != tempData.length) {
        buffer.write(', ');
      }
    }
    setStringProvider.setString(buffer.toString());
    response.clear();
  }

  moveCardAndHoldCardAtBezel() {
    final Uint8List unit8List = Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x30, 0x03, 0xB3]);
    port!.write(unit8List);
    String tempData = HEX.encode(unit8List);
    var buffer = StringBuffer();
    for (int i = 0; i < tempData.length; i++) {
      buffer.write(tempData[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != tempData.length) {
        buffer.write(', ');
      }
    }
    setStringProvider.setString(buffer.toString());
    response.clear();
  }

  moveCardToContentICposition() {
    int checkXOR;
    checkXOR = 0xF2 ^ 0x00 ^ 0x00 ^ 0x03 ^ 0x43 ^ 0x32 ^ 0x31 ^ 0x03;
    final Uint8List unit8List = Uint8List.fromList(
        [0xF2, 0x00, 0x00, 0x03, 0x43, 0x32, 0x31, 0x03, checkXOR]);
    port!.write(unit8List);
    String tempData = HEX.encode(unit8List);
    var buffer = StringBuffer();
    for (int i = 0; i < tempData.length; i++) {
      buffer.write(tempData[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != tempData.length) {
        buffer.write(', ');
      }
    }
    setStringProvider.setString(buffer.toString());
    response.clear();
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
      setStringProvider.setString("success to open");
      port!.config.baudRate = 9600;
      port!.config.bits = 8;
      port!.config.parity = SerialPortParity.none;
      port!.config.stopBits = 1;

      try {
        //TODO: Read on port
        SerialPortReader reader = SerialPortReader(port!);
        Stream<Uint8List> upcommingData = reader.stream.map((data) {
          return data;
        });

        upcommingData.listen((data) {
          response.addAll(data);
          Future.delayed(const Duration(milliseconds: 300), () async {
            print(response);
          });
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
