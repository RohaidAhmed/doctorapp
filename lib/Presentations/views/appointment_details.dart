import 'package:booster/booster.dart';
import 'package:doctorapp/Configurations/app_config.dart';
import 'package:doctorapp/Presentations/elements/app_button.dart';
import 'package:doctorapp/Presentations/elements/flushBar.dart';
import 'package:doctorapp/Presentations/elements/meeting_widget.dart';
import 'package:doctorapp/Presentations/elements/navigation_dialog.dart';
import 'package:doctorapp/Presentations/views/appointment_list.dart';
import 'package:doctorapp/Presentations/views/profile_screen.dart';
import 'package:doctorapp/application/app_state.dart';
import 'package:doctorapp/application/notificationHandler.dart';
import 'package:doctorapp/infrastructure/models/appointment_model.dart';
import 'package:doctorapp/infrastructure/models/patient_profile_model.dart';
import 'package:doctorapp/infrastructure/services/appointment_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import 'chats/messages.dart';

class AppointmentDetail extends StatelessWidget {
  final AppointmentModel appointmentModel;
  final String doctorName;

  AppointmentDetail({required this.appointmentModel, required this.doctorName});

  AppointmentServices _appointmentServices = AppointmentServices();

  NotificationHandler _notificationHandler = NotificationHandler();

  @override
  Widget build(BuildContext context) {
    var status = Provider.of<AppState>(context);
    return LoadingOverlay(
      isLoading: status.getStateStatus() == StateStatus.IsBusy,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Details'),
          backgroundColor: AppConfigurations.color,
          actions: [
            if (appointmentModel.isApproved!)
              IconButton(
                  onPressed: () {
                    Get.to(() => MessagesView(
                        receiverID: appointmentModel.patientID.toString(),
                        myID: appointmentModel.doctorID.toString()));
                  },
                  icon: Icon(
                    Icons.chat,
                    size: 19,
                  )),
            if (appointmentModel.isApproved!)
              IconButton(
                  onPressed: () {
                    if (DateTime.now()
                        .isBefore(DateTime.parse(appointmentModel.date!))) {
                      getFlushBar(context,
                          title: "You cannot start meeting before time.",
                          icon: Icons.info_outline,
                          color: Colors.blue);
                      return;
                    }
                    joinMeeting(context,
                        meetingID: appointmentModel.meetingId.toString(),
                        meetingPassword: appointmentModel.meetingPwd.toString(),
                        name: doctorName.toString());
                  },
                  icon: Icon(
                    Icons.video_call,
                    size: 19,
                  )),
            IconButton(
                onPressed: () {
                  Get.to(() => ProfileScreen(PatientProfileModel(
                        patientEmail: appointmentModel.patientEmail,
                        patientAge: appointmentModel.patientAge,
                        patientName: appointmentModel.patientName,
                        patientPic: appointmentModel.patientPic,
                      )));
                },
                icon: Icon(
                  Icons.person,
                  size: 19,
                )),
          ],
        ),
        body: Column(
          children: [
            Booster.verticalSpace(30),
            _getContainer(
                text: 'Patient Name',
                text1: appointmentModel.patientName.toString()),
            Booster.verticalSpace(10),
            _getContainer(
                text: 'Appointment Date | Time',
                text1: DateFormat.yMEd().format(
                        DateTime.parse(appointmentModel.date.toString())) +
                    " | " +
                    appointmentModel.time.toString()),
            Booster.verticalSpace(10),
            _getContainer(
                text: 'Disease', text1: appointmentModel.disease.toString()),
            Booster.verticalSpace(10),
            _getContainer(
                text: 'Appointment Description',
                text1: appointmentModel.description.toString()),
            Booster.verticalSpace(10),
            _getContainer(
              text: 'Appointment Status',
              text1: appointmentModel.isPending!
                  ? "Pending"
                  : appointmentModel.isApproved!
                      ? "Accepted"
                      : "Rejected",
            ),
            Booster.verticalSpace(40),
            if (appointmentModel.isPending!)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: AppButton(
                    onTap: () async {
                      await showNavigationDialog(context,
                          message:
                              "Do you really want to approve this appointment?",
                          buttonText: "Yes", navigation: () async {
                        await _appointmentServices.acceptAppointment(context,
                            docID: appointmentModel.docID.toString());
                        Get.back();
                        if (status.getStateStatus() == StateStatus.IsFree) {
                          _notificationHandler.oneToOneNotificationHelper(
                              docID: appointmentModel.patientID!,
                              body:
                                  "Your appointment has been approved successfully.",
                              title: "Appointment Update!");
                          showNavigationDialog(context,
                              message:
                                  "Appointment has been approved successfully",
                              buttonText: "Okay", navigation: () {
                            Get.off(() => AppointmentList());
                          }, secondButtonText: "", showSecondButton: false);
                        }
                      }, secondButtonText: "No", showSecondButton: true);
                    },
                    text: "Approve Appointment"),
              ),
            if (appointmentModel.isPending!)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: AppButton(
                    onTap: () async {
                      await showNavigationDialog(context,
                          message:
                              "Do you really want to reject this appointment?",
                          buttonText: "Yes", navigation: () async {
                        await _appointmentServices.rejectAppointment(context,
                            docID: appointmentModel.docID.toString());
                        Get.back();
                        if (status.getStateStatus() == StateStatus.IsFree) {
                          _notificationHandler.oneToOneNotificationHelper(
                              docID: appointmentModel.patientID!,
                              body:
                                  "Sorry! Your appointment has been rejected.",
                              title: "Appointment Update!");
                          showNavigationDialog(context,
                              message:
                                  "Appointment has been rejected successfully",
                              buttonText: "Okay", navigation: () {
                            Get.off(() => AppointmentList());
                          }, secondButtonText: "", showSecondButton: false);
                        }
                      }, secondButtonText: "No", showSecondButton: true);
                    },
                    text: "Reject Appointment"),
              ),
          ],
        ),
      ),
    );
  }
}

joinMeeting(BuildContext context,
    {required String meetingID,
    required String meetingPassword,
    required String name}) async {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return MeetingWidget(
            name: name, meetingId: meetingID, meetingPassword: meetingPassword);
      },
    ),
  );
}

_getContainer({
  required String text,
  required String text1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Booster.dynamicFontSize(
            label: text,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      ),
      Booster.verticalSpace(8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Booster.dynamicFontSize(
            label: text1,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            isAlignCenter: false,
            lineHeight: 1.4),
      ),
      Booster.verticalSpace(8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Divider(),
          ],
        ),
      )
    ],
  );
}
