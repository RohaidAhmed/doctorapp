import 'package:flutter/cupertino.dart';

class DoctorProvider extends ChangeNotifier {
  String doctorName = "";

  void saveName(String name) {
    doctorName = name;
    notifyListeners();
  }

  String getName() => doctorName;
}
