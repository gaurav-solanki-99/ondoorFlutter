import 'dart:convert';

class GetFilterResponse {
  bool? success;
  FilterData? data;

  GetFilterResponse({
    this.success,
    this.data,
  });

  factory GetFilterResponse.fromRawJson(String str) =>
      GetFilterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetFilterResponse.fromJson(Map<String, dynamic> json) =>
      GetFilterResponse(
        success: json["success"],
        data: FilterData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data!.toJson(),
      };
}

class FilterData {
  List<FilterGroup>? filterGroups;

  FilterData({
    this.filterGroups,
  });

  factory FilterData.fromRawJson(String str) =>
      FilterData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FilterData.fromJson(Map<String, dynamic> json) => FilterData(
        filterGroups: List<FilterGroup>.from(
            json["filter_groups"].map((x) => FilterGroup.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "filter_groups":
            List<dynamic>.from(filterGroups!.map((x) => x.toJson())),
      };
}

class FilterGroup {
  String? filterGroupId;
  String? name;
  List<Filter>? filter;

  FilterGroup({
    this.filterGroupId,
    this.name,
    this.filter,
  });

  factory FilterGroup.fromRawJson(String str) =>
      FilterGroup.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FilterGroup.fromJson(Map<String, dynamic> json) => FilterGroup(
        filterGroupId: json["filter_group_id"],
        name: json["name"],
        filter:
            List<Filter>.from(json["filter"].map((x) => Filter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "filter_group_id": filterGroupId,
        "name": name,
        "filter": List<dynamic>.from(filter!.map((x) => x.toJson())),
      };
}

class Filter {
  String? filterId;
  String? title;
  String? name;
  bool isChecked = false;

  Filter({
    this.filterId,
    this.title,
    this.name,
  });

  factory Filter.fromRawJson(String str) => Filter.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
        filterId: json["filter_id"] ?? "",
        title: json["title"] ?? "",
        name: json["name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "filter_id": filterId,
        "title": title,
        "name": name,
      };
}
