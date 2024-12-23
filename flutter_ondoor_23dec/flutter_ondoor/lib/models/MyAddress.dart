import 'dart:core';

class MyAddress {
  String? placeId;
  String? lattitude;
  String? longituude;
  String? city;
  String? state;
  String? country;
  String? description;

  MyAddress(
      {required this.placeId,
      required this.lattitude,
      required this.longituude,
      required this.city,
      required this.state,
      required this.country,
      required this.description});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['placeId'] = placeId;
    data['lattitude'] = lattitude;
    data['longituude'] = longituude;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['description'] = description;
    return data;
  }
}
