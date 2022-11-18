import 'package:booster/booster.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctorapp/Presentations/elements/loading_widget.dart';
import 'package:doctorapp/infrastructure/models/patient_profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final PatientProfileModel profileModel;

  ProfileScreen(this.profileModel);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30)),
                    child: Image.asset(
                      'assets/images/profileBG.jpeg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Booster.verticalSpace(30),
                    Stack(
                      children: [
                        Column(
                          children: [
                            Center(
                              child: Booster.dynamicFontSize(
                                  label: "Profile",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Booster.verticalSpace(20),
                            Center(
                              child: Container(
                                height: 115,
                                width: 115,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.profileModel.patientPic
                                        .toString(),
                                    placeholder: (context, url) =>
                                        LoadingWidget(),
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color: Colors.white)),
                              ),
                            ),
                            Booster.verticalSpace(25),
                            Booster.dynamicFontSize(
                                label:
                                    widget.profileModel.patientName.toString(),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            Booster.verticalSpace(5),
                            Booster.dynamicFontSize(
                                label: "Patient",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
            Booster.verticalSpace(50),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Icon(
                    Icons.mail,
                  ),
                  Booster.horizontalSpace(20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Booster.dynamicFontSize(
                          label: "EMAIL",
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      Booster.verticalSpace(5),
                      Booster.dynamicFontSize(
                          label: widget.profileModel.patientEmail.toString(),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
            Booster.verticalSpace(15),
            Divider(),
            Booster.verticalSpace(15),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                  ),
                  Booster.horizontalSpace(20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Booster.dynamicFontSize(
                          label: "AGE",
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      Booster.verticalSpace(5),
                      Booster.dynamicFontSize(
                          label: widget.profileModel.patientAge.toString(),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
