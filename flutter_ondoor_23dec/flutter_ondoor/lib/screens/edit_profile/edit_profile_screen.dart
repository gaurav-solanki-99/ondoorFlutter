import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/get_profile_response.dart';
import 'package:ondoor/screens/edit_profile/edit_profile_bloc/edit_profile_bloc.dart';
import 'package:ondoor/screens/edit_profile/edit_profile_bloc/edit_profile_state.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/themeData.dart';
import 'package:ondoor/utils/validator.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';

import '../../utils/SizeConfig.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  EditProfileBloc editProfileBloc = EditProfileBloc();
  ProfileData data = ProfileData();
  bool isLoading = false;
  @override
  void initState() {
    Appwidgets.setStatusBarColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: Appwidgets.MyAppBar(
            context,
            "Edit Profile",
            () {},
          ),
          body: BlocBuilder(
            bloc: editProfileBloc,
            builder: (context, state) {
              if (state is EditProfileInitialState) {
                isLoading = false;

                editProfileBloc.getprofileData(context);
              }
              if (state is EditProfileLoadingState) {
                isLoading = true;
              }
              if (state is EditProfileSuccessState) {
                isLoading = false;
              }
              if (state is GetProfileState) {
                isLoading = false;
                data = state.data!;
                editProfileBloc.firstNameController.text = data.firstname!;
                editProfileBloc.lastNameController.text = data.lastname!;
                editProfileBloc.mobileController.text = data.telephone!;
                editProfileBloc.emailController.text = data.email!;
                editProfileBloc.gst_number_Controller.text = data.gstNo!;
                editProfileBloc.firmNameController.text = data.gstFirmName!;
              }
              return SingleChildScrollView(
                child: Container(
                  width: Sizeconfig.getWidth(context),
                  //height: Sizeconfig.getHeight(context)*0.51,
                  // height: Sizeconfig.getHeight(context) * 1.018,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0))),

                  child: Form(
                    key: _formKey,
                    child: Wrap(
                      // spacing: 10,
                      runSpacing: 10,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Appwidgets.TextMedium(
                              StringContants.lbl_first_name+" *",
                              ColorName.black,
                            ),
                            5.toSpace,
                            Appwidgets.commonTextForFieldforEditProfile(
                                controller: editProfileBloc.firstNameController,
                                maxlines: 1,
                                context: context,
                                hintText:
                                    "Enter ${StringContants.lbl_first_name}",
                                maxLength: 25,
                                textInputType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'''^[\w\'\’\"_,.()&!*|:/\\–%-]*(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]*)*\s?$''')
                                  ),
                                ],
                                validatorFunc: (p0)
                                {
                                  if (p0!.isEmpty) {
                                    return 'Please enter full name';
                                  }
                                }),
                            5.toSpace,
                            Appwidgets.TextMedium(
                              StringContants.lbl_last_name+" *",
                              ColorName.black,
                            ),
                            5.toSpace,
                            Appwidgets.commonTextForFieldforEditProfile(
                                controller: editProfileBloc.lastNameController,
                                maxlines: 1,
                                context: context,
                                hintText:
                                    "Enter ${StringContants.lbl_last_name}",
                                maxLength: 25,
                                textInputType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'''^[\w\'\’\"_,.()&!*|:/\\–%-]*(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]*)*\s?$''')
                                  ),
                                ],
                                validatorFunc: (p0) {
                                  if (p0!.isEmpty) {
                                    return 'Please enter Last name';
                                  }
                                }),
                            5.toSpace,
                            Appwidgets.TextMedium(
                              StringContants.lbl_Mobile,
                              ColorName.black,
                            ),
                            5.toSpace,
                            Appwidgets.commonTextForFieldforEditProfile(
                                context: context,
                                controller: editProfileBloc.mobileController,
                                maxlines: 1,
                                hintText: "Enter Mobile number",
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textInputType: TextInputType.number,
                                validatorFunc: (p0) {
                                  if (p0!.isEmpty) {
                                    return 'Please enter Mobile number';
                                  } else if (p0.length < 10) {
                                    return 'Please enter valid Mobile number';
                                  }
                                  else if (int.parse(p0[0]) < 5) {
                                    return 'Please enter valid Mobile number';
                                  }
                                }),
                            5.toSpace,
                            Appwidgets.TextMedium(
                              StringContants.lbl_email,
                              ColorName.black,
                            ),
                            5.toSpace,
                            Appwidgets.commonTextForFieldforEditProfile(
                                context: context,
                                controller: editProfileBloc.emailController,
                                maxlines: 1,
                                hintText: StringContants.lbl_exapmle,
                                maxLength: 100,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9@a-zA-Z.]")),
                                ],
                                textInputType: TextInputType.emailAddress,
                                validatorFunc: (value) {
                                  // if (value!.isEmpty) {
                                  //   return 'Please enter Email';
                                  // } else

                                    if (value!.isNotEmpty&&Validator.emailValidator(value) !=
                                      null) {
                                    return 'Please enter valid Email';
                                  }
                                }),
                            5.toSpace,
                            Appwidgets.TextMedium(
                              StringContants.lbl_gst,
                              ColorName.black,
                            ),
                            5.toSpace,
                            Appwidgets.commonTextForFieldforEditProfile(
                                context: context,
                                controller:
                                    editProfileBloc.gst_number_Controller,
                                maxlines: 1,
                                hintText: "Enter ${StringContants.lbl_gst}",
                                maxLength: 15,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'''^[\w\'\’\"_,.()&!*|:/\\–%-]+(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]+)*?\s?$'''))
                                ],
                                textInputType: TextInputType.text,
                                validatorFunc: (value) {
                                  if (value!.isEmpty&&editProfileBloc.firmNameController.text.isNotEmpty) {
                                    return 'Please enter GST No.';
                                  }
                                  else if (Validator.gstValidator(value) != null) {
                                        return 'Please enter valid GST No.';
                                      }
                                }),
                            5.toSpace,
                            Appwidgets.TextMedium(
                              StringContants.lbl_firm_name,
                              ColorName.black,
                            ),
                            5.toSpace,
                            Appwidgets.commonTextForFieldforEditProfile(
                                context: context,
                                controller: editProfileBloc.firmNameController,
                                maxlines: 1,
                                hintText:
                                    "Enter ${StringContants.lbl_firm_name}",
                                maxLength: 100,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'''^[\w\'\’\"_,.()&!*|:/\\–%-]+(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]+)*?\s?$'''))
                                ],
                                textInputType: TextInputType.text,
                                validatorFunc: (value) {
                                  if (value!.isEmpty&&editProfileBloc.gst_number_Controller.text.isNotEmpty) {
                                    return 'Please enter Firm Name';
                                  } /* else if (Validator.emailValidator(
                                          value) !=
                                          null) {
                                        return 'Please enter valid Email';
                                      }*/
                                }),
                            5.toSpace
                            /*  Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                              ],
                            ),*/
                            /*     Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                              ],
                            ),*/
                            /*       Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                              ],
                            ),*/
                            /*     Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                              ],
                            ),*/
                            /*Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                              ],
                            ),*/
                            /*          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                              ],
                            ),
                            5.toSpace*/
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: isLoading
                                  ? const CommonLoadingWidget()
                                  : InkWell(
                                      onTap: () async {
                                        OndoorThemeData.keyBordDow();

                                        // if (_formKey.currentState!.validate()) {


                                        // firstNameController.text,
                                        // lastNameController.text,
                                        // emailController.text
                                        //
                                        // if(editProfileBloc.firmNameController.text=="")
                                        //   {
                                        //
                                        //   }
                                        // else  if(editProfileBloc.lastNameController.text=="")
                                        //   {
                                        //
                                        //   }
                                        // else  if(editProfileBloc.emailController.text=="")
                                        // {
                                        //
                                        // }
                                        // else  if(editProfileBloc.emailController.text!="")
                                        // {
                                        //
                                        // }




                                        if (_formKey
                                            .currentState!
                                            .validate()){
                                          if (await Network.isConnected()) {
                                            editProfileBloc.updateProfileData(context);
                                          } else {
                                            MyDialogs.showInternetDialog(context,
                                                    () {
                                                  Navigator.pop(context);
                                                });
                                          }
                                        }



                                        // }
                                      },
                                      child: Container(
                                          width: Sizeconfig.getWidth(context),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              color: ColorName.ColorPrimary),
                                          child: Center(
                                            child: Appwidgets.TextLagre(
                                                StringContants.lbl_update,
                                                Colors.white),
                                          )),
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}
