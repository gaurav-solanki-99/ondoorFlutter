import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/models/validate_app_version_response.dart';
import 'package:ondoor/screens/SplashScreen/splash_bloc/splash_events.dart';
import 'package:ondoor/screens/SplashScreen/splash_bloc/splash_states.dart';

import '../../../constants/Constant.dart';
import '../../../utils/sharedpref.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  String userId = "";
  SplashScreenBloc() : super(const SplashInitialState()) {
    on<SplashStartEvent>(showSplash);
  }
  void verifyUserLoggedIn(ValidateAppVersionResponse validateApp) async {
    //TODO to change a key
    // userId = await SharedPref.getStringPreference("key");
  }
  Future<String> getAddress() async {
    return await SharedPref.getStringPreference(Constants.ADDRESS) ?? "";
  }

  Future<bool> checkPreivousData() async {
    return await SharedPref.getBooleanPreference("IS_LOCATION_SELECT") ?? false;
  }

  Future<String> getTokenAndroid() async {
    return await SharedPref.getStringPreference("token") ?? "";
  }

    Future<String> getLocality() async {
    return await SharedPref.getStringPreference(Constants.LOCALITY) ?? "";
  }

  showSplash(SplashStartEvent event, Emitter<SplashScreenState> emit) async {
    emit(SplashLoadingState());
    emit(SplashStartState(
        animation: event.animation, imageAnimation: event.imageAnimation));
  }



}
