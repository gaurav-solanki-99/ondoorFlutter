class GetLatestOrderResponse {
  bool? success;
  List<LatestOrderData>? data;
  String? message;

  GetLatestOrderResponse({this.success, this.data, this.message});

  GetLatestOrderResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <LatestOrderData>[];
      json['data'].forEach((v) {
        data!.add(new LatestOrderData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class LatestOrderData {
  String? orderId;
  String? total;
  String? name;

  LatestOrderData({this.orderId, this.total, this.name});

  LatestOrderData.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    total = json['total'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['total'] = this.total;
    data['name'] = this.name;
    return data;
  }
}
