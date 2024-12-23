class OrderOnPhoneResponse {
  bool? success;
  String? message;
  OrderOnPhoneData? data;

  OrderOnPhoneResponse({this.success, this.message, this.data});

  OrderOnPhoneResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? "";
    data = json['data'] != null
        ? OrderOnPhoneData.fromJson(json['data'])
        : OrderOnPhoneData();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class OrderOnPhoneData {
  String? telephone;

  OrderOnPhoneData({this.telephone});

  OrderOnPhoneData.fromJson(Map<String, dynamic> json) {
    telephone = json['telephone'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['telephone'] = telephone;
    return data;
  }
}
