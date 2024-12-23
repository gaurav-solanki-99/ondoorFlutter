import 'dart:convert';

import 'package:flutter/cupertino.dart';

class NotificationListResponse {
  bool? success;
  List<NotificationData>? data;
  int? statusCode;
  String? statusText;
  NotificationListResponse(
      {this.success, this.data, this.statusCode, this.statusText});

  NotificationListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    statusCode = json["statusCode"] ?? 0;
    statusText = json['statusText'] ?? "";
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(new NotificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['statusCode'] = statusCode;
    data['statusText'] = statusText;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationData {
  String? title;
  String? description;
  String? notificationType;
  Metadata? metadata;
  String? image;
  String? startDate;
  bool isExpanded = false;

  NotificationData(
      {this.title,
      this.description,
      this.notificationType,
      this.metadata,
      this.image,
      this.startDate});

  NotificationData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    notificationType = json['notification_type'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    image = json['image'];
    startDate = json['start_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['notification_type'] = this.notificationType;
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    data['image'] = this.image;
    data['start_date'] = this.startDate;
    return data;
  }
}

class Metadata {
  String? weburl;
  String? key;
  String? value;
  String? name;

  Metadata({this.weburl, this.key, this.value, this.name});

  Metadata.fromJson(Map<String, dynamic> json) {
    weburl = json['weburl'];
    key = json['key'];
    value = json['value'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['weburl'] = this.weburl;
    data['key'] = this.key;
    data['value'] = this.value;
    data['name'] = this.name;
    return data;
  }
}
