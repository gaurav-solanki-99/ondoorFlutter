import 'package:ondoor/models/get_profile_response.dart';

class EditProfileState {}

class EditProfileInitialState extends EditProfileState {}

class EditProfileLoadingState extends EditProfileState {}

class GetProfileState extends EditProfileState {
  ProfileData? data;
  GetProfileState({required this.data});
}

class EditProfileSuccessState extends EditProfileState {}

class EditProfileFailureState extends EditProfileState {}
