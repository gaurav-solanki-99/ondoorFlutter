import 'dart:convert';

class OrderHistoryDetailResponse {
  OrderHistoryDetailResponse({
    required this.success,
    required this.data,
  });

  final bool? success;
  final OrderHistoryDetailData? data;

  factory OrderHistoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryDetailResponse(
      success: json["success"],
      data: json["data"] == null
          ? null
          : OrderHistoryDetailData.fromJson(json["data"]),
    );
  }
}

class OrderHistoryDetailData {
  OrderHistoryDetailData({
    this.editkey,
    this.offerOrderMsg,
    this.paymentAddress,
    this.paymentMethod,
    this.orderStatusName,
    this.products,
    this.offerOrder,
    this.type,
    this.reOrder,
    this.histories,
    this.comment,
    this.totals,
    this.vouchers,
    this.walletPopup,
    this.discount,
    this.orderDate,
    this.orderStatusId,
    this.shippingMethod,
    this.shippingAddress,
    this.invoiceNo,
    this.customerId,
    this.deliveryTime,
    this.deliveryDate,
    this.orderId,
  });

  final String? editkey;
  final String? offerOrderMsg;
  final String? paymentAddress;
  final String? paymentMethod;
  final String? orderStatusName;
  final List<Product>? products;
  final bool? offerOrder;
  final String? type;
  final int? reOrder;
  final List<History>? histories;
  final String? comment;
  final List<Total>? totals;
  final List<dynamic>? vouchers;
  final int? walletPopup;
  final String? discount;
  final DateTime? orderDate;
  final String? orderStatusId;
  final String? shippingMethod;
  final String? shippingAddress;
  final String? invoiceNo;
  final String? customerId;
  final String? deliveryTime;
  final DateTime? deliveryDate;
  final String? orderId;

  factory OrderHistoryDetailData.fromJson(Map<String, dynamic> json) {
    return OrderHistoryDetailData(
      editkey: json["editkey"],
      offerOrderMsg: json["offer_order_msg"],
      paymentAddress: json["payment_address"],
      paymentMethod: json["payment_method"],
      orderStatusName: json["order_status_name"],
      products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
      offerOrder: json["offer_order"],
      type: json["type"],
      reOrder: json["re_order"],
      histories: json["histories"] == null ? [] : List<History>.from(json["histories"]!.map((x) => History.fromJson(x))),
      comment: json["comment"],
      totals: json["totals"] == null ? [] : List<Total>.from(json["totals"]!.map((x) => Total.fromJson(x))),
      vouchers: json["vouchers"] == null ? [] : List<dynamic>.from(json["vouchers"]!.map((x) => x)),
      walletPopup: json["wallet_popup"],
      discount: json["discount"],
      orderDate: DateTime.tryParse(json["order_date"] ?? ""),
      orderStatusId: json["order_status_id"],
      shippingMethod: json["shipping_method"],
      shippingAddress: json["shipping_address"],
      invoiceNo: json["invoice_no"],
      customerId: json["customer_id"],
      deliveryTime: json["delivery_time"],
      deliveryDate: DateTime.tryParse(json["delivery_date"] ?? ""),
      orderId: json["order_id"],
    );
  }
}

class History {
  History({
    required this.dateAdded,
    required this.status,
    required this.comment,
  });

  final String? dateAdded;
  final String? status;
  final String? comment;

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      dateAdded: json["date_added"],
      status: json["status"],
      comment: json["comment"],
    );
  }
}

class Product {
  Product({
    required this.name,
    required this.weight_unit,
    required this.image,
    required this.model,
    required this.option,
    required this.quantity,
    required this.price,
    required this.mrp_price,
    required this.total,
    required this.productReturn,
    required this.customMsg,
    required this.productStatusData,
    required this.sellerProduct,
  });
  String toJson() => json.encode(toMap());

  final String? name;
  final String? model;
  final String? image;
  final String? weight_unit;
  final List<dynamic> option;
  final String? quantity;
  final String? price;
  final String? mrp_price;
  final String? total;
  final String? productReturn;
  final String? customMsg;
  final List<dynamic> productStatusData;
  final int? sellerProduct;
  Map<String, dynamic> toMap() => {
        "name": name,
        "weight_unit": weight_unit,
        "mrp_price": mrp_price,
        "image": image,
        "model": model,
        "quantity": quantity,
        "price": price,
        "total": total,
        "productReturn": productReturn,
        "customMsg": customMsg,
        "sellerProduct": sellerProduct,
      };
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      mrp_price: json['mrp_price'] ?? "0",
      weight_unit: json['weight_unit'] ?? "",
      image: json['image'] ?? "",
      name: json["name"],
      model: json["model"],
      option: json["option"] == null
          ? []
          : List<dynamic>.from(json["option"]!.map((x) => x)),
      quantity: json["quantity"],
      price: json["price"],
      total: json["total"],
      productReturn: json["return"],
      customMsg: json["custom_msg"],
      productStatusData: json["product_status_data"] == null
          ? []
          : List<dynamic>.from(json["product_status_data"]!.map((x) => x)),
      sellerProduct: json["seller_product"],
    );
  }
}

class Total {
  Total({
    required this.subTotal,
    required this.flatShippingRate,
    required this.total,
    required this.discount,
    required this.wallet,
    required this.sodexo,
    required this.reward,
    required this.promowallet,
    required this.cartDiscount,
  });

  final String? subTotal;
  final String? flatShippingRate;
  final String? total;
  final String? discount;
  final String? wallet;
  final String? sodexo;
  final String? reward;
  final String? promowallet;
  final String? cartDiscount;

  factory Total.fromJson(Map<String, dynamic> json) {
    return Total(
      subTotal: json["sub_total"].toString()??"",
      flatShippingRate: json["Flat_Shipping_Rate"].toString()??"",
      total: json["total"].toString()??"",
      discount: json["discount"].toString()??"",
      wallet: json["wallet"].toString()??"",
      sodexo: json["sodexo"].toString()??"",
      reward: json["reward"].toString()??"",
      promowallet: json["promowallet"].toString()??"",
      cartDiscount: json["cart_discount"].toString()??"",
    );
  }
}
