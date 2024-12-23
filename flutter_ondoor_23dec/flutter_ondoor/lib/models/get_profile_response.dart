import 'dart:convert';

class GetProfileResponse {
  bool? success;
  ProfileData? data;

  GetProfileResponse({this.success, this.data});

  GetProfileResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    data = json['data'] != null
        ? ProfileData.fromMap(json['data'])
        : ProfileData();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toMap();
    }
    return data;
  }
}

class ProfileData {
  String? firstname;
  String? lastname;
  String? email;
  String? telephone;
  String? dateOfBirth;
  String? anniversaryDate;
  String? rewardBalance;
  String? gstNo;
  String? gstFirmName;

  ProfileData(
      {this.firstname,
      this.lastname,
      this.email,
      this.telephone,
      this.dateOfBirth,
      this.anniversaryDate,
      this.rewardBalance,
      this.gstNo,
      this.gstFirmName});

  factory ProfileData.fromJson(String str) =>
      ProfileData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProfileData.fromMap(Map<String, dynamic> json) => ProfileData(
      firstname: json['firstname'] ?? "",
      lastname: json['lastname'] ?? "",
      rewardBalance: json['reward_balance'] ?? '',
      anniversaryDate: json['anniversary_date'] ?? "",
      dateOfBirth: json['date_of_birth'] ?? "",
      telephone: json['telephone'] ?? "",
      email: json['email'] ?? "",
      gstFirmName: json['gst_firm_name'] ?? "",
      gstNo: json['gst_no'] ?? ""
      /*     success: json['success'] ?? false,
          shoppinglist: json["shoppinglist"] == null
              ? []
              : List<Shoppinglist>.from(
              json["shoppinglist"].map((x) => Shoppinglist.fromMap(x)))*/
      );

  Map<String, dynamic> toMap() => {
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "telephone": telephone,
        "date_of_birth": dateOfBirth,
        "reward_balance": rewardBalance,
        "anniversary_date": anniversaryDate,
        "gst_no": gstNo,
        "gst_firm_name": gstFirmName,
      };
  /*ProfileData.fromJson(Map<String, dynamic> json) {
    firstname = json['firstname'] ?? "";
    lastname = json['lastname'] ?? "";
    email = json['email'] ?? "";
    telephone = json['telephone'] ?? "";
    dateOfBirth = json['date_of_birth'] ?? "";
    anniversaryDate = json['anniversary_date'] ?? "";
    rewardBalance = json['reward_balance'] ?? "";
    gstNo = json['gst_no'] ?? "";
    gstFirmName = json['gst_firm_name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['email'] = this.email;
    data['telephone'] = this.telephone;
    data['date_of_birth'] = this.dateOfBirth;
    data['anniversary_date'] = this.anniversaryDate;
    data['reward_balance'] = this.rewardBalance;
    data['gst_no'] = this.gstNo;
    data['gst_firm_name'] = this.gstFirmName;
    return data;
  }*/
}
