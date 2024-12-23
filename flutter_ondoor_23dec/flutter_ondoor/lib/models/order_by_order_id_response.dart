import 'dart:convert';

import 'AllProducts.dart';

class OrderbyOrderIdResponse {
  bool? success;
  OrderData? data;

  OrderbyOrderIdResponse({
    this.success,
    this.data,
  });

  factory OrderbyOrderIdResponse.fromRawJson(String str) =>
      OrderbyOrderIdResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderbyOrderIdResponse.fromJson(Map<String, dynamic> json) =>
      OrderbyOrderIdResponse(
        success: json["success"],
        data: json["data"] == null
            ? OrderData()
            : OrderData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class OrderData {
  String? orderId;
  String? customerId;
  String? orderStatusId;
  String? locationId;
  String? invoiceNo;
  int? dateAdded;
  String? paymentAddress;
  String? paymentMethod;
  String? paymentCode;
  String? campaignId;
  String? shippingAddress;
  String? shippingMethod;
  List<ProductUnit>? products;
  bool? offerOrder;
  String? offerOrderMsg;
  List<OrderTotal>? totals;
  String? comment;
  List<OrderHistory>? histories;

  OrderData({
    this.orderId,
    this.customerId,
    this.orderStatusId,
    this.locationId,
    this.invoiceNo,
    this.dateAdded,
    this.paymentAddress,
    this.paymentMethod,
    this.paymentCode,
    this.campaignId,
    this.shippingAddress,
    this.shippingMethod,
    this.products,
    this.offerOrder,
    this.offerOrderMsg,
    this.totals,
    this.comment,
    this.histories,
  });

  factory OrderData.fromRawJson(String str) =>
      OrderData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
        orderId: json["order_id"],
        customerId: json["customer_id"],
        orderStatusId: json["order_status_id"],
        locationId: json["location_id"],
        invoiceNo: json["invoice_no"],
        dateAdded: json["date_added"],
        paymentAddress: json["payment_address"],
        paymentMethod: json["payment_method"],
        paymentCode: json["payment_code"],
        campaignId: json["campaign_id"],
        shippingAddress: json["shipping_address"],
        shippingMethod: json["shipping_method"],
        products: json["products"] == null
            ? []
            : List<ProductUnit>.from(json["products"]!
                .map((x) => ProductUnit.fromJson(jsonEncode(x)))),
        offerOrder: json["offer_order"],
        offerOrderMsg: json["offer_order_msg"],
        totals: json["totals"] == null
            ? []
            : List<OrderTotal>.from(
                json["totals"]!.map((x) => OrderTotal.fromJson(x))),
        comment: json["comment"],
        histories: json["histories"] == null
            ? []
            : List<OrderHistory>.from(
                json["histories"]!.map((x) => OrderHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "customer_id": customerId,
        "order_status_id": orderStatusId,
        "location_id": locationId,
        "invoice_no": invoiceNo,
        "date_added": dateAdded,
        "payment_address": paymentAddress,
        "payment_method": paymentMethod,
        "payment_code": paymentCode,
        "campaign_id": campaignId,
        "shipping_address": shippingAddress,
        "shipping_method": shippingMethod,
        "products": products == null
            ? []
            : List<ProductUnit>.from(products!.map((x) => x.toJson())),
        "offer_order": offerOrder,
        "offer_order_msg": offerOrderMsg,
        "totals": totals == null
            ? []
            : List<dynamic>.from(totals!.map((x) => x.toJson())),
        "comment": comment,
        "histories": histories == null
            ? []
            : List<dynamic>.from(histories!.map((x) => x.toJson())),
      };
}

class OrderHistory {
  int? dateAdded;
  String? status;
  String? comment;

  OrderHistory({
    this.dateAdded,
    this.status,
    this.comment,
  });

  factory OrderHistory.fromRawJson(String str) =>
      OrderHistory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderHistory.fromJson(Map<String, dynamic> json) => OrderHistory(
        dateAdded: json["date_added"],
        status: json["status"],
        comment: json["comment"],
      );

  Map<String, dynamic> toJson() => {
        "date_added": dateAdded,
        "status": status,
        "comment": comment,
      };
}

class OrderSubProduct {
  OrderSubProduct();

  factory OrderSubProduct.fromRawJson(String str) =>
      OrderSubProduct.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderSubProduct.fromJson(Map<String, dynamic> json) =>
      OrderSubProduct();

  Map<String, dynamic> toJson() => {};
}

class OrderTotal {
  String? subTotal;
  String? flatShippingRate;
  String? total;
  String? discount;
  String? wallet;
  String? reward;
  String? promowallet;
  String? cartDiscount;

  OrderTotal({
    this.subTotal,
    this.flatShippingRate,
    this.total,
    this.discount,
    this.wallet,
    this.reward,
    this.promowallet,
    this.cartDiscount,
  });

  factory OrderTotal.fromRawJson(String str) =>
      OrderTotal.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderTotal.fromJson(Map<String, dynamic> json) => OrderTotal(
        subTotal: json["sub_total"],
        flatShippingRate: json["Flat_Shipping_Rate"],
        total: json["total"],
        discount: json["discount"],
        wallet: json["wallet"],
        reward: json["reward"],
        promowallet: json["promowallet"],
        cartDiscount: json["cart_discount"],
      );

  Map<String, dynamic> toJson() => {
        "sub_total": subTotal,
        "Flat_Shipping_Rate": flatShippingRate,
        "total": total,
        "discount": discount,
        "wallet": wallet,
        "reward": reward,
        "promowallet": promowallet,
        "cart_discount": cartDiscount,
      };
}
