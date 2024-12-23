import 'dart:convert';

class HomePageModel {
  bool? success;
  List<Category>? categories;
  List<Banners>? banners;
  List<dynamic>? homefills;
  List<Footer>? footer;

  HomePageModel({
    this.success,
    this.categories,
    this.banners,
    this.homefills,
    this.footer,
  });

  factory HomePageModel.fromJson(String str) =>
      HomePageModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory HomePageModel.fromMap(Map<String, dynamic> json) => HomePageModel(
        success: json["success"],
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromMap(x))),
        banners: json["banners"] == null
            ? []
            : List<Banners>.from(
                json["banners"]!.map((x) => Banners.fromMap(x))),
        homefills: json["homefills"] == null
            ? []
            : List<dynamic>.from(json["homefills"]!.map((x) => x)),
        footer: json["footer"] == null
            ? []
            : List<Footer>.from(json["footer"]!.map((x) => Footer.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toMap())),
        "banners": banners == null
            ? []
            : List<dynamic>.from(banners!.map((x) => x.toMap())),
        "homefills": homefills == null
            ? []
            : List<dynamic>.from(homefills!.map((x) => x)),
        "footer": footer == null
            ? []
            : List<dynamic>.from(footer!.map((x) => x.toMap())),
      };
}

class Banners {
  String? link;
  String? image;
  String? sortOrder;
  String? searchTerm;
  String? key;
  String? value;
  String? name;
  int? isAdword;
  String? weburl;
  String? headerTitle;

  Banners({
    this.link,
    this.image,
    this.sortOrder,
    this.searchTerm,
    this.key,
    this.value,
    this.name,
    this.isAdword,
    this.weburl,
    this.headerTitle,
  });

  factory Banners.fromJson(String str) => Banners.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Banners.fromMap(Map<String, dynamic> json) => Banners(
        link: json["link"],
        image: json["image"],
        sortOrder: json["sort_order"],
        searchTerm: json["search_term"],
        key: json["key"],
        value: json["value"],
        name: json["name"],
        isAdword: json["is_adword"],
        weburl: json["weburl"],
        headerTitle: json["header_title"],
      );

  Map<String, dynamic> toMap() => {
        "link": link,
        "image": image,
        "sort_order": sortOrder,
        "search_term": searchTerm,
        "key": key,
        "value": value,
        "name": name,
        "is_adword": isAdword,
        "weburl": weburl,
        "header_title": headerTitle,
      };
}

class Category {
  String? id;
  String? parentId;
  String? name;
  String? description;
  String? image;
  List<dynamic>? filterGroups;
  List<SubCategory>? subCategories;
  int quantitiy = 0;

  Category({
    this.id,
    this.parentId,
    this.name,
    this.description,
    this.image,
    this.filterGroups,
    this.subCategories,
  });

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        parentId: json["parent_id"],
        name: json["name"],
        description: json["description"],
        image: json["image"],
        filterGroups: json["filter_groups"] == null
            ? []
            : List<dynamic>.from(json["filter_groups"]!.map((x) => x)),
        subCategories: json["sub_categories"] == null
            ? []
            : List<SubCategory>.from(
                json["sub_categories"]!.map((x) => SubCategory.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "parent_id": parentId,
        "name": name,
        "description": description,
        "image": image,
        "filter_groups": filterGroups == null
            ? []
            : List<dynamic>.from(filterGroups!.map((x) => x)),
        "sub_categories": subCategories == null
            ? []
            : List<dynamic>.from(subCategories!.map((x) => x.toMap())),
      };
}

class SubCategory {
  String? categoryId;
  String? name;
  List<SubCategory>? subCategories;
  String? parentId;
  String? mobileSubCatImage;

  SubCategory({
    this.categoryId,
    this.name,
    this.subCategories,
    this.parentId,
    this.mobileSubCatImage,
  });

  factory SubCategory.fromJson(String str) =>
      SubCategory.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SubCategory.fromMap(Map<String, dynamic> json) => SubCategory(
      categoryId: json["category_id"].toString(),
      name: json["name"],
      subCategories: json["sub_categories"] == null
          ? []
          : List<SubCategory>.from(
              json["sub_categories"]!.map((x) => SubCategory.fromMap(x))),
      parentId: json["parent_id"].toString(),
      mobileSubCatImage: json['mobile_sub_cat_image'] ?? "");

  Map<String, dynamic> toMap() => {
        "category_id": categoryId,
        "name": name,
        "sub_categories": subCategories == null
            ? []
            : List<dynamic>.from(subCategories!.map((x) => x.toMap())),
        "parent_id": parentId,
        "mobile_sub_cat_image": mobileSubCatImage
      };
}

class Footer {
  Header? header;

  Footer({
    this.header,
  });

  factory Footer.fromJson(String str) => Footer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Footer.fromMap(Map<String, dynamic> json) => Footer(
        header: json["header"] == null ? null : Header.fromMap(json["header"]),
      );

  Map<String, dynamic> toMap() => {
        "header": header?.toMap(),
      };
}

class Header {
  String? contentType;
  String? heightRatio;
  String? image;
  String? searchTerm;
  String? sortOrder;
  String? key;
  String? value;
  String? name;
  String? weburl;

  Header({
    this.contentType,
    this.heightRatio,
    this.image,
    this.searchTerm,
    this.sortOrder,
    this.key,
    this.value,
    this.name,
    this.weburl,
  });

  factory Header.fromJson(String str) => Header.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Header.fromMap(Map<String, dynamic> json) => Header(
        contentType: json["content_type"],
        heightRatio: json["height_ratio"],
        image: json["image"],
        searchTerm: json["search_term"],
        sortOrder: json["sort_order"],
        key: json["key"],
        value: json["value"],
        name: json["name"],
        weburl: json["weburl"],
      );

  Map<String, dynamic> toMap() => {
        "content_type": contentType,
        "height_ratio": heightRatio,
        "image": image,
        "search_term": searchTerm,
        "sort_order": sortOrder,
        "key": key,
        "value": value,
        "name": name,
        "weburl": weburl,
      };
}
