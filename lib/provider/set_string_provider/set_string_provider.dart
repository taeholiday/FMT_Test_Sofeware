import 'package:flutter/material.dart';

class SetStringProvider with ChangeNotifier {
  String? newString;

  String get getString => newString == null ? "" : newString!;

  setString(String string) {
    newString = string;
    notifyListeners();
  }
}
