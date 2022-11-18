import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/application/app_state.dart';
import 'package:doctorapp/infrastructure/models/appointment_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AppointmentServices {
  CollectionReference<Map<String, dynamic>> _categoryServices =
      FirebaseFirestore.instance.collection('doctorAppointments');

  ///Get Appointment
  Stream<List<AppointmentModel>> streamAppointments(String uid) {
    return _categoryServices.where('doctorID', isEqualTo: uid).snapshots().map(
        (event) => event.docs
            .map((e) => AppointmentModel.fromJson(e.data()))
            .toList());
  }

  ///Update Appointment Status
  Future<void> acceptAppointment(BuildContext context,
      {required String docID}) async {
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsBusy);
    await _categoryServices
        .doc(docID)
        .update({'isApproved': true, 'isPending': false});
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsFree);
  }

  ///Update Appointment Status
  Future<void> rejectAppointment(BuildContext context,
      {required String docID}) async {
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsBusy);
    await _categoryServices
        .doc(docID)
        .update({'isApproved': false, 'isPending': false});
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsFree);
  }
}
