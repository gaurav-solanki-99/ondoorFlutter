class AddressResponse {
  bool? success;
  int? addressId;
  String? message;
  String? data;

  AddressResponse({this.success, this.addressId, this.message});

  AddressResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    addressId = json['address_id'] ?? 0;
    message = json['message'] ?? "";
    data = json['data'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['address_id'] = addressId;
    data['message'] = message;
    data['data'] = data;
    return data;
  }
}
