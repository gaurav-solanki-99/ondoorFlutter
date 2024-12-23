import 'package:equatable/equatable.dart';
import 'package:ondoor/models/get_profile_response.dart';

class ProfileScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileScreenInitialEvent extends ProfileScreenEvent {
  @override
  List<Object?> get props => [];
}

class ProfileScreenLoadingEvent extends ProfileScreenEvent {
  @override
  List<Object?> get props => [];
}

class ProfileScreenLoadedEvent extends ProfileScreenEvent {
  ProfileData data;
  ProfileScreenLoadedEvent({required this.data});
  @override
  List<Object?> get props => [data];
}
