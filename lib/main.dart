import 'package:flutter/material.dart';
import 'package:fmt_test_sofeware/home_page.dart';
import 'package:fmt_test_sofeware/provider/set_string_provider/set_string_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<SetStringProvider>(
            create: (context) => SetStringProvider()),
      ],
      child: const MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FMT Test Sofeware',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
