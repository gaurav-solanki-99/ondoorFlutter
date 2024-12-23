import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/get_profile_response.dart';
import 'package:ondoor/screens/edit_profile/edit_profile_bloc/edit_profile_event.dart';
import 'package:ondoor/screens/edit_profile/edit_profile_bloc/edit_profile_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

import '../../../utils/Connection.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  String userLocality = "";
  String customer_id = "";
  String token_type = "";
  String access_token = "";
  String token = "";
  String userName = "";
  String userMobileNumber = "";
  String email = "";
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController gst_number_Controller = TextEditingController();
  TextEditingController firmNameController = TextEditingController();
  EditProfileBloc() : super(EditProfileInitialState()) {
    on<EditProfileInitialEvent>(
        (event, emit) => emit(EditProfileInitialState()));
    on<EditProfileLoadingEvent>(
        (event, emit) => emit(EditProfileLoadingState()));
    on<EditProfileSuccessEvent>(
        (event, emit) => emit(EditProfileSuccessState()));
    on<GetProfileEvent>(
        (event, emit) => emit(GetProfileState(data: event.data)));
  }
  getprofileData(context) async {
    userLocality = await SharedPref.getStringPreference(Constants.LOCALITY);
    customer_id = await SharedPref.getStringPreference(Constants.sp_CustomerId);
    token_type = await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    token = "$token_type $access_token";
    if (await Network.isConnected()) {
      EasyLoading.show();
      GetProfileResponse? profileDataresponse =
          await ApiProvider().getProfileData(() async {
        getprofileData(context);
      });

      userName =
          "${profileDataresponse.data?.firstname!} ${profileDataresponse.data?.lastname!}";
      userMobileNumber = profileDataresponse.data!.telephone!;
      email = profileDataresponse.data!.email!;
      EasyLoading.dismiss();
      add(GetProfileEvent(data: profileDataresponse.data!));
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getprofileData(context);
      });
    }
  }

  updateProfileData(context) async {
    if (await Network.isConnected()) {
      add(EditProfileLoadingEvent());
      var updateProfile = await ApiProvider().updateProfile(
          firstNameController.text,
          lastNameController.text,
          emailController.text,
          gst_number_Controller.text,
          firmNameController.text, () {
        updateProfileData(context);
      });
      if (updateProfile["success"] == true) {
        add(EditProfileSuccessEvent());
        Appwidgets.showToastMessage(
            StringContants.lbl_profile_updated_successfully);
        Navigator.pop(context);
      } else {
        add(EditProfileInitialEvent());
        MyDialogs.commonDialog(
            context: context,
            actionTap: () {
              Navigator.pushReplacementNamed(context, Routes.home_page);
            },
            titleText: "Something Went Wrong !",
            actionText: StringContants.lbl_continue_shopping);
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        updateProfileData(context);
      });
    }
  }
}
