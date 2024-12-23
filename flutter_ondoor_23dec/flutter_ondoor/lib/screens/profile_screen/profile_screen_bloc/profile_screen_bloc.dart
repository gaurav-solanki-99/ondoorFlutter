import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/models/get_profile_response.dart';
import 'package:ondoor/screens/profile_screen/profile_screen_bloc/profile_screen_event.dart';
import 'package:ondoor/screens/profile_screen/profile_screen_bloc/profile_screen_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

import '../../../utils/Connection.dart';

class ProfileScreenBloc extends Bloc<ProfileScreenEvent, ProfileScreenState> {
  String userName = "";
  String email = "";
  String userMobileNumber = "";
  String userLocality = "";
  String customer_id = "";
  String token_type = "";
  String access_token = "";
  String token = "";
  bool isLoading = false;
  ProfileData data = ProfileData();
  ProfileScreenBloc() : super(ProfileScreenInitialState()) {
    on<ProfileScreenLoadingEvent>(
        (event, emit) => emit(ProfileScreenLoadingState()));
    on<ProfileScreenLoadedEvent>(
      (event, emit) {
        emit(ProfileScreenLoadingState());
        emit(ProfileScreenLoadedState(data: event.data));
      },
    );
  }
  void getprofileData(context) async {
    print("getProfileData");
    if (await Network.isConnected()) {
      customer_id =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      token_type = await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      token = "$token_type $access_token";
      GetProfileResponse profileDataresponse = GetProfileResponse();
      profileDataresponse = await ApiProvider().getProfileData(() async {
        getprofileData(context);
      });
      data = profileDataresponse.data!;
      SharedPref.setStringPreference(Constants.sp_FirstNAME, data.firstname!);
      SharedPref.setStringPreference(Constants.sp_LastName, data.lastname!);
      SharedPref.setStringPreference(Constants.sp_EMAIL, data.email!);
      SharedPref.setStringPreference(Constants.sp_MOBILE_NO, data.telephone!);
      SharedPref.setStringPreference(Constants.sp_Company_Name, "");
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      add(ProfileScreenLoadedEvent(data: data));
    } else {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      MyDialogs.showInternetDialog(context, () {
        getprofileData(context);
        Navigator.pop(context);
      });
    }
  }
}
