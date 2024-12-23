class GetPagesResponse {
  bool? success;
  PagesData? data;

  GetPagesResponse({this.success, this.data});

  GetPagesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    data =
        json['data'] != null ? PagesData.fromJson(json['data']) : PagesData();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PagesData {
  String? informationId;
  String? bottom;
  String? sortOrder;
  String? status;
  String? languageId;
  String? title;
  String? description;

  PagesData(
      {this.informationId,
      this.bottom,
      this.sortOrder,
      this.status,
      this.languageId,
      this.title,
      this.description});

  PagesData.fromJson(Map<String, dynamic> json) {
    informationId = json['information_id'] ?? "";
    bottom = json['bottom'] ?? "";
    sortOrder = json['sort_order'] ?? "";
    status = json['status'] ?? "";
    languageId = json['language_id'] ?? "";
    title = json['title'] ?? "";
    description = json['description'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['information_id'] = this.informationId;
    data['bottom'] = this.bottom;
    data['sort_order'] = this.sortOrder;
    data['status'] = this.status;
    data['language_id'] = this.languageId;
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}
