import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:ondoor/models/MyAddress.dart';

class LocationState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationInitialState extends LocationState {
  LocationInitialState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationUserLoginState extends LocationState {
  bool isLogin;
  @override
  // TODO: implement props
  List<Object?> get props => [isLogin];
  LocationUserLoginState({required this.isLogin});
}

class CurrentLocationState extends LocationState {
  CameraPosition cameraPosition;
  CurrentLocationState(this.cameraPosition);

  @override
  // TODO: implement props
  List<Object?> get props => [cameraPosition];
}

//
/*class SearchingState extends LocationState {
  bool isSearching;

  SearchingState(this.isSearching);

  @override
  // TODO: implement props
  List<Object?> get props => [isSearching];
}*/

class NoLocationFoundState extends LocationState {
  String noLocationFoundText;
  NoLocationFoundState(this.noLocationFoundText);

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetCocoCodeState extends LocationState {
  GetCocoCodeState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationNullState extends LocationState {
  LocationNullState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationNullState2 extends LocationState {
  LocationNullState2();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class MapLoadingState extends LocationState {
  MapLoadingState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SearchingPlacesState extends LocationState {
  bool searchingOn;
  List<Prediction> prediction;
  SearchingPlacesState({required this.searchingOn, required this.prediction});
  @override
  List<Object?> get props => [searchingOn];
}

class CurrentLocationErrorState extends LocationState {
  final String error;
  CurrentLocationErrorState(this.error);
  @override
  List<Object?> get props => [error];
}

class NoInternetState extends LocationState {
  NoInternetState();
  @override
  List<Object?> get props => [];
}
