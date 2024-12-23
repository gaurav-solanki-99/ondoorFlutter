import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:ondoor/models/MyAddress.dart';

class LocationEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationInitialEvent extends LocationEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationUserLoginEvent extends LocationEvent {
  bool isLogin;
  @override
  // TODO: implement props
  List<Object?> get props => [isLogin];
  LocationUserLoginEvent({required this.isLogin});
}

class LocationNullEvent extends LocationEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationNullEvent2 extends LocationEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CurrentLocationEvent extends LocationEvent {
  final CameraPosition cameraPosition;
  CurrentLocationEvent(this.cameraPosition);
  @override
  List<Object?> get props => [cameraPosition];
}

class GetCocoCodeEvent extends LocationEvent {
  GetCocoCodeEvent();
  @override
  List<Object?> get props => [];
}

class SearchingPlacesEvent extends LocationEvent {
  bool searchingOn;
  List<Prediction> prediction;
  SearchingPlacesEvent({required this.searchingOn, required this.prediction});
  @override
  List<Object?> get props => [searchingOn, prediction];
}

/*class SearchLocationLoadingEvent extends LocationEvent {
  SearchLocationLoadingEvent();
  @override
  List<Object?> get props => [];
}*/

class NoLocationFoundEvent extends LocationEvent {
  String noLocationFoundText;
  NoLocationFoundEvent(this.noLocationFoundText);
  @override
  List<Object?> get props => [noLocationFoundText];
}

class CurrentLocationErrorEvent extends LocationEvent {
  final String error;
  CurrentLocationErrorEvent(this.error);
  @override
  List<Object?> get props => [error];
}

class MapLoadingEvent extends LocationEvent {
  MapLoadingEvent();
  @override
  List<Object?> get props => [];
}

class NoInternetEvent extends LocationEvent {
  NoInternetEvent();
  @override
  List<Object?> get props => [];
}
