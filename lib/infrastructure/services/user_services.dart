import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/Configurations/backEdnConfigs.dart';
import 'package:doctorapp/application/app_state.dart';
import 'package:doctorapp/infrastructure/models/doctor_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class UserServices {
  ///Instantiate LocalDB
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  DoctorProfileModel _doctorProfileModel = DoctorProfileModel();

  DoctorProfileModel get doctorModel => _doctorProfileModel;

  ///Collection Reference of Bikers
  final CollectionReference<Map<String, dynamic>> _ref =
      FirebaseFirestore.instance.collection('doctorsData');

  ///Add Doctors data to Cloud Firestore
  Future<void> addDoctorData(
      User user, DoctorProfileModel doctorModel, BuildContext context) {
    return _ref.doc(user.uid).set(doctorModel.toJson(user.uid));
  }

  ///Stream a LoggedIn User
  Stream<DoctorProfileModel> streamDoctorData(String docID) {
    return _ref
        .doc(docID)
        .snapshots()
        .map((snap) => DoctorProfileModel.fromJson(snap.data()!));
  }

  ///Upload User Profile Pic
  Future uploadFile(BuildContext context,
      {required File image, required DoctorProfileModel userModel}) async {
    try {
      Provider.of<AppState>(context, listen: false)
          .stateStatus(StateStatus.IsBusy);
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('doctorPics/${image.path.split('/').last}');
      UploadTask uploadTask = storageReference.putFile(image);
      return uploadTask.whenComplete(() async {
        Provider.of<AppState>(context, listen: false)
            .stateStatus(StateStatus.IsFree);
      });
    } catch (e) {
      Provider.of<AppState>(context, listen: false)
          .stateStatus(StateStatus.IsError);
    }
  }
}
