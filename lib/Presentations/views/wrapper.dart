import 'package:doctorapp/Presentations/views/appointment_list.dart';
import 'package:doctorapp/Presentations/views/sign_in.dart';
import 'package:doctorapp/application/auth_state.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool isLoggedIn = false;

  Future<bool?> getUserLoginState() async {
    return await UserLoginStateHandler.getUserLoggedInSharedPreference();
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserLoginState().then((value) {
      if (value == null) {
        isLoggedIn = false;
      } else {
        isLoggedIn = value;
      }

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? AppointmentList() : SignIn();
  }
}
