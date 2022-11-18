import 'dart:io';

import 'package:booster/booster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/Configurations/app_config.dart';
import 'package:doctorapp/Configurations/backEdnConfigs.dart';
import 'package:doctorapp/Presentations/elements/appDrawer.dart';
import 'package:doctorapp/Presentations/elements/appointment_tile.dart';
import 'package:doctorapp/Presentations/elements/loading_widget.dart';
import 'package:doctorapp/Presentations/elements/navigation_dialog.dart';
import 'package:doctorapp/Presentations/elements/noData.dart';
import 'package:doctorapp/application/auth_state.dart';
import 'package:doctorapp/application/doctor_provider.dart';
import 'package:doctorapp/application/uid_provider.dart';
import 'package:doctorapp/infrastructure/models/appointment_model.dart';
import 'package:doctorapp/infrastructure/models/doctor_profile_model.dart';
import 'package:doctorapp/infrastructure/services/appointment_services.dart';
import 'package:doctorapp/infrastructure/services/authServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class AppointmentList extends StatefulWidget {
  const AppointmentList({
    Key? key,
  }) : super(key: key);

  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  AppointmentServices _appointmentServices = AppointmentServices();
  DoctorProfileModel userModel = DoctorProfileModel();
  String txt = '';
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future _getData() async {
    await storage.ready;
    return await storage.getItem(BackEndConfigs.userDetailsLocalStorage);
  }

  bool isDataLoaded = false;

  Future<void> _initFcm() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    _firebaseMessaging.getToken().then((token) {
      FirebaseFirestore.instance.collection('deviceTokens').doc(uid).set(
        {
          'deviceTokens': token,
        },
      );
    });
  }

  AuthServices _authServices = AuthServices.instance();

  String userID = "";

  @override
  void initState() {
    _initFcm();
    UserLoginStateHandler.getUserIDSharedPreference().then((value) {
      setState(() {});
      print("User id : $userID");
    });
    // TODO: implement initState
    _getData().then((value) {
      isDataLoaded = true;
      setState(() {});
      print("value: $value");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showNavigationDialog(context,
            message: "Do you really want to exit?",
            buttonText: "Yes", navigation: () {
          exit(0);
        }, secondButtonText: "No", showSecondButton: true);
      },
      child: Scaffold(
        body: !isDataLoaded
            ? LoadingWidget()
            : FutureBuilder(
                future: storage.ready,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!initialized) {
                    _getData();
                    var items =
                        storage.getItem(BackEndConfigs.userDetailsLocalStorage);
                    print(items);
                    if (items != null) {
                      userModel = DoctorProfileModel(
                        docId: items['docID'],
                      );
                    }

                    initialized = true;
                  }
                  return snapshot.data == null
                      ? CircularProgressIndicator()
                      : createUI(context, userModel);
                }),
      ),
    );
  }

  Widget createUI(BuildContext context, DoctorProfileModel profileModel) {
    var userIDProvider = Provider.of<UserID>(context);
    var doctorProvider = Provider.of<DoctorProvider>(context);
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          centerTitle: true,
          title: Text('Appointment List'),
          backgroundColor: AppConfigurations.color,
        ),
        body: StreamProvider.value(
          value: _appointmentServices
              .streamAppointments(userIDProvider.getUserID()),
          initialData: [AppointmentModel()],
          builder: (context, child) {
            return context.watch<List<AppointmentModel>>().isNotEmpty
                ? context.watch<List<AppointmentModel>>()[0].docID == null
                    ? Center(
                        child: Container(
                            height: Booster.screenHeight(context) - 100,
                            width: Booster.screenWidth(context),
                            child: Center(
                              child: CircularProgressIndicator(),
                            )))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            context.watch<List<AppointmentModel>>().length,
                        itemBuilder: (ctxt, i) {
                          return AppointmentTile(
                              doctorName: doctorProvider.getName(),
                              appointmentModel:
                                  context.watch<List<AppointmentModel>>()[i]);
                        })
                : NoData();
          },
        ));
  }
}
