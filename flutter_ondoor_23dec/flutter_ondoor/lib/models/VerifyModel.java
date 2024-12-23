import 'dart:convert';

class VerifyModel {
    bool? success;
    Data? data;
    List<Location>? locations;
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
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
        locations: json["locations"] == null ? [] : List<Location>.from(json["locations"]!.map((x) => Location.fromMap(x))),
        creditprogram: json["creditprogram"],
    );

    Map<String, dynamic> toMap() => {
        "success": success,
        "data": data?.toMap(),
        "locations": locations == null ? [] : List<dynamic>.from(locations!.map((x) => x.toMap())),
        "creditprogram": creditprogram,
    };
}

class Data {
    String? customerId;
    String? firstname;
    String? lastname;
    String? telephone;
    String? email;
    String? token;

    Data({
        this.customerId,
        this.firstname,
        this.lastname,
        this.telephone,
        this.email,
        this.token,
    });

    factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Data.fromMap(Map<String, dynamic> json) => Data(
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

class Location {
    String? locationId;
    String? name;

    Location({
        this.locationId,
        this.name,
    });

    factory Location.fromJson(String str) => Location.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Location.fromMap(Map<String, dynamic> json) => Location(
        locationId: json["location_id"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "location_id": locationId,
        "name": name,
    };
}
