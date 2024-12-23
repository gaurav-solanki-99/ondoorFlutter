import 'dart:convert';

class GetOrderHistoryResponse {
  bool? success;
  List<OrderHistoryData>? data;
  String? error; // Add an error field to capture error messages

  GetOrderHistoryResponse({this.success, this.data, this.error});

  factory GetOrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      // If there is an error field, handle it
      return GetOrderHistoryResponse(
        success: json["success"] ?? false,
        error: json["error"] ?? "Unknown error",
      );
    }

    return GetOrderHistoryResponse(
      success: json["success"] ?? false,
      data: json["data"] == null
          ? []
          : List<OrderHistoryData>.from(
              json["data"].map((x) => OrderHistoryData.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() => {
        "success": success,
        "data": data == null
            ? []
            : List<OrderHistoryData>.from(data!.map((x) => x.toMap())),
        "error": error,
      };
}

class OrderHistoryData {
  String? orderId;
  String? orderStatusId;
  String? orderStatusName;
  String? orderDate;
  String? sortDate;
  String? customerId;
  String? totals;
  int? reOrder;
  String? type;
  String? totalItem;
  String? image;
  List<String> imageArray = [];

  OrderHistoryData({
    this.orderId,
    this.orderStatusId,
    this.orderStatusName,
    this.orderDate,
    this.sortDate,
    this.customerId,
    this.totals,
    this.reOrder,
    this.type,
    this.totalItem,
    this.image,
  });

  factory OrderHistoryData.fromMap(Map<String, dynamic> json) =>
      OrderHistoryData(
        orderId: json['order_id'] ?? "",
        orderStatusId: json['order_status_id'] ?? "",
        orderStatusName: json['order_status_name'] ?? "",
        orderDate: json['order_date'] ?? "",
        sortDate: json['sort_date'] ?? "",
        customerId: json['customer_id'] ?? "",
        totals: json['totals'] ?? "",
        reOrder: json['re_order'] ?? 0,
        type: json['type'] ?? "",
        image: json['image'] ?? "",
        totalItem: json['total item'] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "order_id": orderId,
        "order_status_id": orderStatusId,
        "order_status_name": orderStatusName,
        "order_date": orderDate,
        "sort_date": sortDate,
        "customer_id": customerId,
        "totals": totals,
        "re_order": reOrder,
        "type": type,
        "total_item": totalItem,
        "image": image,
      };
}
