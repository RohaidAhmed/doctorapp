import 'package:booster/booster.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctorapp/Configurations/backEdnConfigs.dart';
import 'package:doctorapp/Presentations/elements/loading_widget.dart';
import 'package:doctorapp/infrastructure/models/doctor_profile_model.dart';
import 'package:doctorapp/infrastructure/services/authServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class DoctorProfileScreen extends StatelessWidget {
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;

  DoctorProfileModel userModel = DoctorProfileModel();

  AuthServices _authServices = AuthServices.instance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!initialized) {
              var items =
                  storage.getItem(BackEndConfigs.userDetailsLocalStorage);
              print(items);
              if (items != null) {
                userModel = DoctorProfileModel(
                  docId: items['docId'],
                  name: items['name'],
                  categoryId: items['categoryId'],
                  categoryName: items['category_name'],
                  location: items['location'],
                  email: items['email'],
                  qualification: items['qualification'],
                  profilePic: items['profile_pic'],
                );
              }

              initialized = true;
            }
            return snapshot.data == null
                ? CircularProgressIndicator()
                : createUI(context, userModel);
          }),
    );
  }

  Widget createUI(BuildContext context, DoctorProfileModel profileModel) {
    return SafeArea(
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
                                label: "Doctor Profile",
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
                                  imageUrl: profileModel.profilePic.toString(),
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
                          Booster.verticalSpace(10),
                          Booster.verticalSpace(25),
                          Booster.dynamicFontSize(
                              label: profileModel.name.toString(),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          Booster.verticalSpace(8),
                          Booster.dynamicFontSize(
                              label: profileModel.categoryName.toString(),
                              fontSize: 15,
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
                        label: profileModel.email.toString(),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
          Booster.verticalSpace(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              thickness: 0.5,
            ),
          ),
          Booster.verticalSpace(10),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/degree_icon.jpg',
                  height: 25,
                  width: 25,
                ),
                Booster.horizontalSpace(20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Booster.dynamicFontSize(
                        label: "Qualification",
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    Booster.verticalSpace(5),
                    Booster.dynamicFontSize(
                        label: profileModel.qualification.toString(),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
          Booster.verticalSpace(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              thickness: 0.5,
            ),
          ),
          Booster.verticalSpace(10),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                ),
                Booster.horizontalSpace(20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Booster.dynamicFontSize(
                        label: "Location",
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    Booster.verticalSpace(5),
                    Booster.dynamicFontSize(
                        label: profileModel.location.toString(),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
          Booster.verticalSpace(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              thickness: 0.5,
            ),
          ),
          Booster.verticalSpace(10),
        ]),
      ),
    );
  }
}
