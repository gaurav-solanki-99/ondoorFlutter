import 'dart:convert';

class FilterDataParams {
  String? filterGroupId;
  List<String>? filter;

  FilterDataParams({
    this.filterGroupId,
    this.filter,
  });

  factory FilterDataParams.fromRawJson(String str) =>
      FilterDataParams.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FilterDataParams.fromJson(Map<String, dynamic> json) =>
      FilterDataParams(
        filterGroupId: json["filter_group_id"] ?? "",
        filter: json["filter"] == null
            ? []
            : List<String>.from(json["filter"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "filter_group_id": filterGroupId,
        "filter": List<String>.from(filter!.map((x) => x)),
      };
}
