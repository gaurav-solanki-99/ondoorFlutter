import 'dart:convert';

class GetCocoCodeByLatLngResponse {
  bool success = false;
  String message = "";
  CoCoCodeData? data;
  String changeAddressMessage = "";

  GetCocoCodeByLatLngResponse(
      {required this.success,
      required this.message,
      required this.data,
      required this.changeAddressMessage});
  factory GetCocoCodeByLatLngResponse.fromJson(String str) =>
      GetCocoCodeByLatLngResponse.fromMap(json.decode(str));

  factory GetCocoCodeByLatLngResponse.fromMap(Map<String, dynamic> json) =>
      GetCocoCodeByLatLngResponse(
          success: json['success'],
          message: json['message'],
          data: json['data'] != null
              ? CoCoCodeData.fromJson(json['data'])
              : CoCoCodeData(),
          changeAddressMessage: json['change_address_message']);
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['message'] = message;
    data['data'] = this.data!.toJson();
    data['change_address_message'] = changeAddressMessage;
    return data;
  }
}

class CoCoCodeData {
  String? storeId;
  String? storeCode;
  String? storeName;
  String? locationId;
  String? wmsStoreId;
  String? cityName;
  String? telephone;
  String? distance;
  dynamic? inputLat;
  dynamic? inputLng;

  CoCoCodeData(
      {this.storeId,
      this.storeCode,
      this.storeName,
      this.locationId,
      this.wmsStoreId,
      this.cityName,
      this.telephone,
      this.distance,
      this.inputLat,
      this.inputLng});

  CoCoCodeData.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'] ?? "";
    storeCode = json['store_code'] ?? "";
    storeName = json['store_name'] ?? "";
    locationId = json['location_id'] ?? "";
    wmsStoreId = json['wms_store_id'] ?? "";
    cityName = json['city_name'] ?? "";
    telephone = json['telephone'] ?? "";
    distance = json['distance'] ?? "";
    inputLat = json['input_lat'] ?? "";
    inputLng = json['input_lng'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store_id'] = storeId;
    data['store_code'] = storeCode;
    data['store_name'] = storeName;
    data['location_id'] = locationId;
    data['wms_store_id'] = wmsStoreId;
    data['city_name'] = cityName;
    data['telephone'] = telephone;
    data['distance'] = distance;
    data['input_lat'] = inputLat;
    data['input_lng'] = inputLng;
    return data;
  }
}
