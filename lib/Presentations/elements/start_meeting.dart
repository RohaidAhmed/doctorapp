import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_sdk/zoom_options.dart';
import 'package:flutter_zoom_sdk/zoom_view.dart';

class StartMeetingWidget extends StatefulWidget {
  ZoomOptions? zoomOptions;
  ZoomMeetingOptions? loginOptions;

  StartMeetingWidget({Key? key, meetingId}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "HfaO47YjhG8H7nPdQTfxFIE3YVsGoUqmpVww",
      appSecret:
          "OkABkWbNHmnDV0B6yuuA3L5e7wE3amHNw1w2", // Replace with with key got from the Zoom Marketplace ZOOM SDK Section
    );
    this.loginOptions = new ZoomMeetingOptions(
        userId:
            'm.ali.nizaami@gmail.com', // Replace with the user email or Zoom user ID of host for start meeting only.
        meetingPassword:
            '03419527440@Zoom', // Replace with the user password for your Zoom ID of host for start meeting only.
        disableDialIn: "false",
        disableDrive: "false",
        disableInvite: "false",
        disableShare: "false",
        disableTitlebar: "false",
        viewOptions: "false",
        noAudio: "false",
        noDisconnectAudio: "false");
  }

  @override
  _StartMeetingWidgetState createState() => _StartMeetingWidgetState();
}

class _StartMeetingWidgetState extends State<StartMeetingWidget> {
  Timer? timer;

  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid)
      result = status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    else
      result = status == "MEETING_STATUS_IDLE";

    return result;
  }

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading meeting '),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            _isLoading ? CircularProgressIndicator() : Container(),
            Expanded(
              child: ZoomView(onViewCreated: (controller) {
                print("Created the view");
                controller.zoomStatusEvents
                    .map((event) => print(event.toString()))
                    .toList();
                controller.initZoom(this.widget.zoomOptions!).then((results) {
                  print("results: $results");

                  if (results[0] == 0) {
                    controller.zoomStatusEvents.listen((status) {
                      print("Meeting Status Stream: " +
                          status[0] +
                          " - " +
                          status[1]);
                      if (_isMeetingEnded(status[0])) {
                        Navigator.pop(context);
                        timer?.cancel();
                      }
                    });

                    print("listen on event channel");

                    controller
                        .login(this.widget.loginOptions!)
                        .then((loginResult) {
                      print("LoginResultBool :- " + loginResult.toString());
                      if (loginResult) {
                        print("LoginResult :- Logged In");
                        setState(() {
                          _isLoading = false;
                        });
                      } else {
                        print("LoginResult :- Logged In Failed");
                      }
                    });
                  }
                }).catchError((error) {
                  print(error);
                });
              }),
            ),
          ],
        ),
      ),
    );
  }
}
