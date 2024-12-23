import 'package:equatable/equatable.dart';
import 'package:ondoor/models/get_profile_response.dart';

class ProfileScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileScreenInitialState extends ProfileScreenState {
  @override
  List<Object?> get props => [];
}

class ProfileScreenLoadingState extends ProfileScreenState {
  @override
  List<Object?> get props => [];
}

class ProfileScreenLoadedState extends ProfileScreenState {
  ProfileData data;
  ProfileScreenLoadedState({required this.data});
  @override
  List<Object?> get props => [data];
}
