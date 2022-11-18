import 'dart:io';

import 'package:booster/booster.dart';
import 'package:doctorapp/Configurations/app_config.dart';
import 'package:doctorapp/Presentations/elements/app_button.dart';
import 'package:doctorapp/Presentations/elements/auth_text_field.dart';
import 'package:doctorapp/Presentations/elements/dialog.dart';
import 'package:doctorapp/Presentations/elements/flushBar.dart';
import 'package:doctorapp/Presentations/elements/loading_widget.dart';
import 'package:doctorapp/Presentations/elements/navigation_dialog.dart';
import 'package:doctorapp/application/errorStrings.dart';
import 'package:doctorapp/application/signUpBusinissLogic.dart';
import 'package:doctorapp/infrastructure/models/category_model.dart';
import 'package:doctorapp/infrastructure/models/doctor_profile_model.dart';
import 'package:doctorapp/infrastructure/services/authServices.dart';
import 'package:doctorapp/infrastructure/services/uploadFileServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import 'sign_in.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  List<CategoryModel> list = [
    CategoryModel(categoryId: "1", categoryName: "Skin Specialist"),
    CategoryModel(categoryId: "2", categoryName: "Heart Specialist"),
    CategoryModel(categoryId: "3", categoryName: "Child Specialist"),
  ];

  AuthServices _authServices = AuthServices.instance();

  bool isObscure = true;

  final _formKey = GlobalKey<FormState>();

  UploadFileServices _uploadFileServices = UploadFileServices();

  var node;

  File? image;

  CategoryModel? _selectedCategory;

  TextEditingController _emailController = TextEditingController();

  TextEditingController _pwdController = TextEditingController();

  TextEditingController _nameController = TextEditingController();

  TextEditingController _qualificationController = TextEditingController();

  TextEditingController _locationController = TextEditingController();

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    SignUpBusinessLogic signUp = Provider.of<SignUpBusinessLogic>(context);
    var user = Provider.of<User?>(context);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: LoadingWidget(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(children: [
                Booster.verticalSpace(80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Booster.dynamicFontSize(
                        label: "Sign Up",
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1E1A15),
                      )),
                ),
                Booster.verticalSpace(11),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Booster.dynamicFontSize(
                        label: "Create your Doctor account",
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff6B6E74),
                      )),
                ),
                Booster.verticalSpace(24),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 75),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      getTextFieldLabel('YOUR NAME'),
                    ],
                  ),
                ),
                Booster.verticalSpace(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: AuthTextField(
                    controller: _nameController,
                    validator: (val) =>
                        val.isEmpty ? "Field Cannot be empty." : null,
                  ),
                ),
                Booster.verticalSpace(23),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: getTextFieldLabel('QUALIFICATION'),
                  ),
                ),
                Booster.verticalSpace(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AuthTextField(
                      controller: _qualificationController,
                      validator: (val) =>
                          val.isEmpty ? "Field Cannot be empty." : null,
                    ),
                  ),
                ),
                Booster.verticalSpace(23),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: getTextFieldLabel('LOCATION'),
                  ),
                ),
                Booster.verticalSpace(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AuthTextField(
                      controller: _locationController,
                      validator: (val) =>
                          val.isEmpty ? "Field Cannot be empty." : null,
                    ),
                  ),
                ),
                Booster.verticalSpace(23),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: getTextFieldLabel('YOUR EMAIL'),
                  ),
                ),
                Booster.verticalSpace(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AuthTextField(
                      controller: _emailController,
                      validator: (val) =>
                          !val.isEmail ? "Email not valid." : null,
                    ),
                  ),
                ),
                Booster.verticalSpace(23),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: getTextFieldLabel("YOUR PASSWORD"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AuthTextField(
                      isPasswordField: true,
                      controller: _pwdController,
                      validator: (val) =>
                          val.isEmpty ? "Field Cannot be empty." : null,
                    ),
                  ),
                ),
                Booster.verticalSpace(40),
                _getImagePicker(context),
                Booster.verticalSpace(20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: AppConfigurations.color),
                        borderRadius: BorderRadius.circular(3)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<CategoryModel>(
                        value: _selectedCategory,
                        items: list.map((value) {
                          return DropdownMenuItem<CategoryModel>(
                            child: Text(value.categoryName.toString()),
                            value: value,
                          );
                        }).toList(),
                        onChanged: (item) {
                          _selectedCategory = item!;
                          setState(() {});
                        },
                        underline: SizedBox(),
                        hint: Text("Select Unit"),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
                Booster.verticalSpace(10),
                Booster.verticalSpace(37),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: AppButton(
                      text: "Sign Up",
                      onTap: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        if (image == null) {
                          getFlushBar(context,
                              title: "Kindly select profile image.",
                              icon: Icons.info_outline,
                              color: Colors.blue);
                          return;
                        }
                        if (_selectedCategory == null) {
                          getFlushBar(context,
                              title: "Kindly select category.",
                              icon: Icons.info_outline,
                              color: Colors.blue);
                          return;
                        }
                        _signUpUser(
                            context: context, signUp: signUp, user: user);
                      },
                    )),
                Booster.verticalSpace(40),
                _gettextrow(text: "Already have an account? ", text1: "Login"),
                Booster.verticalSpace(20),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  _getImagePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppConfigurations.color,
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Flexible(
                  child: Booster.dynamicFontSize(
                    label: image == null
                        ? "Attach Image"
                        : image!.path.split('/').last,
                    fontSize: 16,
                    isAlignCenter: false,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: () => getFile(),
                child: Icon(
                  Icons.attach_file,
                  color: AppConfigurations.color,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signUpUser(
      {required BuildContext context,
      required SignUpBusinessLogic signUp,
      required User? user}) {
    isLoading = true;
    setState(() {});
    _uploadFileServices.getUrl(context, file: image!).then((value) {
      signUp
          .registerNewUser(
              email: _emailController.text,
              password: _pwdController.text,
              userModel: DoctorProfileModel(
                  name: _nameController.text,
                  profilePic: value,
                  categoryId: _selectedCategory!.categoryId,
                  categoryName: _selectedCategory!.categoryName,
                  qualification: _qualificationController.text,
                  location: _locationController.text,
                  email: _emailController.text),
              context: context,
              user: user)
          .then((value) {
        if (signUp.status == SignUpStatus.Registered) {
          isLoading = false;
          setState(() {});
          showNavigationDialog(context,
              message: "Thanks for registration",
              buttonText: "Go to Login", navigation: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => SignIn()));
          }, secondButtonText: "", showSecondButton: false);
        } else if (signUp.status == SignUpStatus.Failed) {
          isLoading = false;
          setState(() {});
          print("Called");
          showErrorDialog(context,
              message: Provider.of<ErrorString>(context, listen: false)
                  .getErrorString());
        }
      });
    });
  }

  ImagePicker _imagePicker = ImagePicker();

  Future getFile() async {
    final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 40);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
}

_gettextrow({required String text, required String text1}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Booster.dynamicFontSize(
          label: text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black),
      Booster.horizontalSpace(3),
      InkWell(
        onTap: () {
          Get.to(SignIn(), transition: Transition.cupertino);
        },
        child: Booster.dynamicFontSize(
            label: text1,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppConfigurations.color,
            isUnderline: true),
      ),
    ],
  );
}
