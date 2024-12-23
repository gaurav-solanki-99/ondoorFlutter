import 'dart:convert';

class VerifyModel {
  bool? success;
  VerifyData? data;
  List<Locations>? locations;
  int? creditprogram;

  VerifyModel({
    this.success,
    this.data,
    this.locations,
    this.creditprogram,
  });

  factory VerifyModel.fromJson(String str) => VerifyModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VerifyModel.fromMap(Map<String, dynamic> json) => VerifyModel(
    success: json["success"],
    data: json["data"] == null ? null : VerifyData.fromMap(json["data"]),
    locations: json["locations"] == null ? [] : List<Locations>.from(json["locations"]!.map((x) => Locations.fromMap(x))),
    creditprogram: json["creditprogram"],
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "data": data?.toMap(),
    "locations": locations == null ? [] : List<dynamic>.from(locations!.map((x) => x.toMap())),
    "creditprogram": creditprogram,
  };
}

class VerifyData {
  String? customerId;
  String? firstname;
  String? lastname;
  String? telephone;
  String? email;
  String? token;

  VerifyData({
    this.customerId,
    this.firstname,
    this.lastname,
    this.telephone,
    this.email,
    this.token,
  });

  factory VerifyData.fromJson(String str) => VerifyData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VerifyData.fromMap(Map<String, dynamic> json) => VerifyData(
    customerId: json["customer_id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    telephone: json["telephone"],
    email: json["email"],
    token: json["token"],
  );

  Map<String, dynamic> toMap() => {
    "customer_id": customerId,
    "firstname": firstname,
    "lastname": lastname,
    "telephone": telephone,
    "email": email,
    "token": token,
  };
}

class Locations {
  String? locationId;
  String? name;

  Locations({
    this.locationId,
    this.name,
  });

  factory Locations.fromJson(String str) => Locations.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Locations.fromMap(Map<String, dynamic> json) => Locations(
    locationId: json["location_id"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "location_id": locationId,
    "name": name,
  };
}
