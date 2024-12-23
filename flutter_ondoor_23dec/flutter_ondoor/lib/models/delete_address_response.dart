class DeleteAddressResponse {
  bool? success;
  String? message;

  DeleteAddressResponse({this.success, this.message});

  DeleteAddressResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}
