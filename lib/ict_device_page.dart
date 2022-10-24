import 'package:flutter/material.dart';
import 'package:fmt_test_sofeware/ict_nk77_test_page.dart';
import 'package:fmt_test_sofeware/ict_uca2_test_page.dart';

class IctDevicePage extends StatefulWidget {
  const IctDevicePage({Key? key}) : super(key: key);

  @override
  State<IctDevicePage> createState() => _IctDevicePageState();
}

class _IctDevicePageState extends State<IctDevicePage> {
  double size = 0.0;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("ICT Device test"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'bill acceptor NK77',
                testBillAcceptorNK77,
              ),
            ),
            SizedBox(
              width: size > 600 ? size * 0.4 : size * 0.8,
              child: buttonGanareter(
                context,
                'coin acceptor UCA2',
                testCoinAcceptorUCA2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  testCoinAcceptorUCA2() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IctUCA2TextPage(),
        ));
  }

  testBillAcceptorNK77() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IctNk77TestPage(),
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
