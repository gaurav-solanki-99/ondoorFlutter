import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/models/HomepageModel.dart';

class OrderSummaryProducts {
  bool success;
  String backgroundColor;
  String backgroundImage;
  String appbarTitle;
  String appbarTitleColor;
  List<OrderSummaryProductsDatum> data;

  OrderSummaryProducts({
    required this.success,
    required this.backgroundColor,
    required this.backgroundImage,
    required this.appbarTitle,
    required this.appbarTitleColor,
    required this.data,
  });

  factory OrderSummaryProducts.fromJson(String str) =>
      OrderSummaryProducts.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderSummaryProducts.fromMap(Map<String, dynamic> json) =>
      OrderSummaryProducts(
        success: json["success"],
        backgroundColor: json["background_color"] ?? '',
        backgroundImage: json["background_image"] ?? "",
        appbarTitle: json["appbar_title"] ?? "",
        appbarTitleColor: json["appbar_title_color"] ?? "",
        data: List<OrderSummaryProductsDatum>.from(
            json["data"].map((x) => OrderSummaryProductsDatum.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "background_color": backgroundColor,
        "background_image": backgroundImage,
        "appbar_title": appbarTitle,
        "appbar_title_color": appbarTitleColor,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class OrderSummaryProductsDatum {
  String uitype;
  String model_type;
  String url;
  String title;
  String subtitle;
  String backgroundColor;
  String ui_appbar_bg_color;
  String ui_appbar_text_color;
  String backgroundImage;
  String titleColor;
  String textColor;
  String button_text_color = "";
  String button_background = "";
  String category_id = "";
  dynamic data;
  List<ProductData> lisProductData = [];
  List<Banners> listbanners = [];
  List<SubCategory> listsubcategory = [];
  List<Category> listcategory = [];
  ScrollController scrollController = ScrollController();
  int pageNumber = 1;
  bool isLoadMore = true;
  String button_text = "";

  OrderSummaryProductsDatum(
      {required this.uitype,
      required this.model_type,
      required this.url,
      required this.title,
      required this.subtitle,
      required this.backgroundColor,
      required this.ui_appbar_bg_color,
      required this.ui_appbar_text_color,
      required this.backgroundImage,
      required this.titleColor,
      required this.textColor,
      required this.data,
      required this.button_text,
      required this.button_text_color,
      required this.button_background,
      required this.category_id});

  factory OrderSummaryProductsDatum.fromJson(String str) =>
      OrderSummaryProductsDatum.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderSummaryProductsDatum.fromMap(Map<String, dynamic> json) =>
      OrderSummaryProductsDatum(
        uitype: json["ui_type"],
        model_type: json["model_type"] ?? "",
        url: json["url"],
        title: json["title"],
        subtitle: json["subtitle"],
        backgroundColor: json["background_color"],
        ui_appbar_bg_color: json["ui_appbar_bg_color"] ?? "",
        ui_appbar_text_color: json["ui_appbar_text_color"] ?? "",
        backgroundImage: json["background_image"],
        titleColor: json["title_color"],
        textColor: json["text_color"],
        button_text_color: json["button_text_color"] ?? "",
        button_background: json["button_background"] ?? "",
        category_id: json["category_id"] ?? "",
        data: json["data"],
        button_text: json["button_text"] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "uitype": uitype,
        "model_type": model_type,
        "url": url,
        "title": title,
        "subtitle": subtitle,
        "background_color": backgroundColor,
        "ui_appbar_bg_color": ui_appbar_bg_color,
        "ui_appbar_text_color": ui_appbar_text_color,
        "background_image": backgroundImage,
        "title_color": titleColor,
        "text_color": textColor,
        "button_text": button_text,
        "button_text_color": button_text_color,
        "button_background": button_background,
        "category_id": category_id,
        "data": data
      };
}
