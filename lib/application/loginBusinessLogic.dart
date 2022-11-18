import 'package:doctorapp/Configurations/backEdnConfigs.dart';
import 'package:doctorapp/Configurations/enums.dart';
import 'package:doctorapp/application/auth_state.dart';
import 'package:doctorapp/application/doctor_provider.dart';
import 'package:doctorapp/application/uid_provider.dart';
import 'package:doctorapp/infrastructure/services/authServices.dart';
import 'package:doctorapp/infrastructure/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'errorStrings.dart';

class LoginBusinessLogic {
  UserServices _userServices = UserServices();
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  Future loginUserLogic(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    var _authServices = Provider.of<AuthServices>(context, listen: false);
    var _error = Provider.of<ErrorString>(context, listen: false);
    var userID = Provider.of<UserID>(context, listen: false);
    var doctorName = Provider.of<DoctorProvider>(context, listen: false);
    var login = Provider.of<AuthServices>(context, listen: false);

    await login
        .signIn(context, email: email, password: password)
        .then((User? user) {
      if (user != null) {
        userID.saveUserID(user.uid);
        _userServices.streamDoctorData(user.uid).map((profileUser) async {
          if (profileUser.docId == null) {
            _authServices.setState(Status.Unauthenticated);
          } else {
            doctorName.saveName(profileUser.name!);
            UserLoginStateHandler.saveUserIDSharedPreference(user.uid);
            await storage.setItem(BackEndConfigs.userDetailsLocalStorage,
                profileUser.toJson(profileUser.docId!));
          }
        }).toList();
      } else {}
    });
  }
}
