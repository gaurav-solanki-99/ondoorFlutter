import 'dart:convert';

class ValidateAppVersionResponse {
  int creditprogram = 0;
  String success = "";
  List<CityList> cityList = [];
  String locationHeaderTxt = "";
  String deliveryLocationSearchHint = "";
  String currentLocationTxt = "";
  String savedAddress = "";
  String recentAddress = "";
  String currentlyServedTxt = "";
  String currentlyServedCityTxt = "";
  String setDeliveryLocationHeaderTxt = "";
  String noOfRecentItems = "";
  String showLocationRetryMessage = "";

  ValidateAppVersionResponse(
      {required this.creditprogram,
      required this.success,
      required this.cityList,
      required this.locationHeaderTxt,
      required this.deliveryLocationSearchHint,
      required this.currentLocationTxt,
      required this.savedAddress,
      required this.recentAddress,
      required this.currentlyServedTxt,
      required this.currentlyServedCityTxt,
      required this.setDeliveryLocationHeaderTxt,
      required this.noOfRecentItems,
      required this.showLocationRetryMessage});

  factory ValidateAppVersionResponse.fromJson(String str) =>
      ValidateAppVersionResponse.fromMap(json.decode(str));

  factory ValidateAppVersionResponse.fromMap(Map<String, dynamic> json) =>
      ValidateAppVersionResponse(
        creditprogram: json['creditprogram'] ?? 0,
        success: json['success'] ?? "",
        showLocationRetryMessage: json["show_location_retry_message"] ?? "",
        // cityList: json['city_list'] ?? [],
        cityList: json["city_list"] == null
            ? []
            : List<CityList>.from(
                json["city_list"].map((x) => CityList.fromMap(x))),

        locationHeaderTxt: json['location_header_txt'] ?? "",
        deliveryLocationSearchHint: json['delivery_location_search_hint'] ?? "",
        currentLocationTxt: json['current_location_txt'] ?? "",
        savedAddress: json['saved_address'] ?? "",
        recentAddress: json['recent_address'] ?? "",
        currentlyServedTxt: json['currently_served_txt'] ?? "",
        currentlyServedCityTxt: json['currently_served_city_txt'] ?? "",
        setDeliveryLocationHeaderTxt:
            json['set_delivery_location_header_txt'] ?? "",
        noOfRecentItems: json['no_of_recent_items'] ?? "",
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['creditprogram'] = creditprogram;
    data['success'] = success;
    data['city_list'] = cityList.map((v) => v.toJson()).toList();
    data['location_header_txt'] = locationHeaderTxt;
    data['delivery_location_search_hint'] = deliveryLocationSearchHint;
    data['current_location_txt'] = currentLocationTxt;
    data['saved_address'] = savedAddress;
    data['recent_address'] = recentAddress;
    data['currently_served_txt'] = currentlyServedTxt;
    data['currently_served_city_txt'] = currentlyServedCityTxt;
    data['set_delivery_location_header_txt'] = setDeliveryLocationHeaderTxt;
    data['no_of_recent_items'] = noOfRecentItems;
    data['show_location_retry_message'] = showLocationRetryMessage;
    return data;
  }
}

class CityList {
  String locationId = "";
  String name = "";
  String telephone = "";
  String latitude = "";
  String longitude = "";

  CityList(
      {required this.locationId,
      required this.name,
      required this.telephone,
      required this.latitude,
      required this.longitude});

/*  CityList.fromJson(Map<String, dynamic> json) {
    locationId = json['location_id'] ?? "";
    name =       json['name'] ?? "";
    telephone =  json['telephone'] ?? "";
    latitude =   json['latitude'] ?? "";
    longitude =  json['longitude'] ?? "";
  }*/
  factory CityList.fromJson(String str) => CityList.fromMap(json.decode(str));

  factory CityList.fromMap(Map<String, dynamic> json) => CityList(
      name: json['location_id'] ?? "",
      latitude: json['name'] ?? "",
      locationId: json['telephone'] ?? "",
      longitude: json['latitude'] ?? "",
      telephone: json['longitude'] ?? "");

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location_id'] = locationId;
    data['name'] = name;
    data['telephone'] = telephone;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
