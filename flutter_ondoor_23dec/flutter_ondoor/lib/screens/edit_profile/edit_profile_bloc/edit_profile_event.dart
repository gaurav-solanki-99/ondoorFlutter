import 'package:ondoor/models/get_profile_response.dart';

class EditProfileEvent {}

class EditProfileInitialEvent extends EditProfileEvent {}

class EditProfileLoadingEvent extends EditProfileEvent {}

class GetProfileEvent extends EditProfileEvent {
  ProfileData? data;
  GetProfileEvent({required this.data});
}

class EditProfileSuccessEvent extends EditProfileEvent {}

class EditProfileFailureEvent extends EditProfileEvent {}
