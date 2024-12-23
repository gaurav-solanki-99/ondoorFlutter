class GetCityResponse {
  bool? success;
  List<CityData>? data;
  String? message;
  String? cityHeading;
  String? cityList;

  GetCityResponse(
      {this.success, this.data, this.message, this.cityHeading, this.cityList});

  GetCityResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    if (json['data'] != null) {
      data = <CityData>[];
      json['data'].forEach((v) {
        data!.add(CityData.fromJson(v));
      });
    }
    message = json['message'] ?? "";
    cityHeading = json['city_heading'] ?? "";
    cityList = json['city_list'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['city_heading'] = cityHeading;
    data['city_list'] = cityList;
    return data;
  }
}

class CityData {
  String? locationId;
  String? name;
  String? telephone;
  String? latitude;
  String? longitude;

  CityData(
      {this.locationId,
      this.name,
      this.telephone,
      this.latitude,
      this.longitude});

  CityData.fromJson(Map<String, dynamic> json) {
    locationId = json['location_id'] ?? "";
    name = json['name'] ?? "";
    telephone = json['telephone'] ?? "";
    latitude = json['latitude'] ?? "";
    longitude = json['longitude'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['location_id'] = locationId;
    data['name'] = name;
    data['telephone'] = telephone;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
