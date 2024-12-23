import 'dart:convert';

class ContactUsReasonListResponse {
  bool? success;
  String? header;
  String? greetings;
  String? greetingsDescription;
  String? description;
  String? categoryHint;
  String? subcategoryHint;
  String? orderCategoryHint;
  String? pickProductHeading;
  String? productListHeading;
  String? productListSubHeading;
  String? productListSubmitButtonText;
  String? productListDismissButtonText;
  String? message;
  List<ContactUsReasonCategory>? categories;

  ContactUsReasonListResponse({
    this.success,
    this.header,
    this.greetings,
    this.greetingsDescription,
    this.description,
    this.categoryHint,
    this.subcategoryHint,
    this.orderCategoryHint,
    this.pickProductHeading,
    this.productListHeading,
    this.productListSubHeading,
    this.productListSubmitButtonText,
    this.productListDismissButtonText,
    this.message,
    this.categories,
  });

  factory ContactUsReasonListResponse.fromJson(String str) =>
      ContactUsReasonListResponse.fromMap(json.decode(str));

  factory ContactUsReasonListResponse.fromMap(Map<String, dynamic> json) =>
      ContactUsReasonListResponse(
        success: json['success'],
        header: json['header'],
        greetings: json['greetings'],
        greetingsDescription: json['greetings_description'],
        description: json['description'],
        categoryHint: json['category_hint'],
        subcategoryHint: json['subcategory_hint'],
        orderCategoryHint: json['order_category_hint'],
        pickProductHeading: json['pick_product_heading'],
        productListHeading: json['product_list_heading'],
        productListSubHeading: json['product_list_sub_heading'],
        productListSubmitButtonText: json['product_list_submit_button_text'],
        productListDismissButtonText: json['product_list_dismiss_button_text'],
        message: json['message'],
        categories: json['categories'] == null
            ? null
            : List<ContactUsReasonCategory>.from(
                json['categories'].map(
                  (x) => ContactUsReasonCategory.fromMap(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'success': success,
      'header': header,
      'greetings': greetings,
      'greetings_description': greetingsDescription,
      'description': description,
      'category_hint': categoryHint,
      'subcategory_hint': subcategoryHint,
      'order_category_hint': orderCategoryHint,
      'pick_product_heading': pickProductHeading,
      'product_list_heading': productListHeading,
      'product_list_sub_heading': productListSubHeading,
      'product_list_submit_button_text': productListSubmitButtonText,
      'product_list_dismiss_button_text': productListDismissButtonText,
      'message': message,
    };
    if (categories != null) {
      data['categories'] =
          categories!.map((category) => category.toJson()).toList();
    }
    return data;
  }
}

class ContactUsReasonCategory {
  String? id;
  String? category;
  String? name;
  List<ContactUsReasonSubCategory>? subCategories;
  String? isProduct;
  String? commentBox;

  ContactUsReasonCategory({
    this.id,
    this.category,
    this.name,
    this.subCategories,
    this.isProduct,
    this.commentBox,
  });

  factory ContactUsReasonCategory.fromJson(String str) =>
      ContactUsReasonCategory.fromMap(json.decode(str));

  factory ContactUsReasonCategory.fromMap(Map<String, dynamic> json) =>
      ContactUsReasonCategory(
        id: json['id'] ?? "",
        category: json['category'] ?? "",
        name: json['name'] ?? "",
        commentBox: json['comment_box'] ?? "",
        isProduct: json['is_product'] ?? "",
        subCategories: json['sub_categories'] == null
            ? []
            : List<ContactUsReasonSubCategory>.from(
                json['sub_categories'].map(
                  (x) => ContactUsReasonSubCategory.fromMap(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'category': category,
      'name': name,
      'is_product': isProduct,
      'comment_box': commentBox,
    };
    if (subCategories != null) {
      data['sub_categories'] =
          subCategories!.map((subcategory) => subcategory.toJson()).toList();
    }
    return data;
  }
}

class ContactUsReasonSubCategory {
  String? id;
  String? subName;
  String? name;
  String? orderidRequired;
  String? commentBox;

  ContactUsReasonSubCategory({
    this.id,
    this.subName,
    this.name,
    this.orderidRequired,
    this.commentBox,
  });

  factory ContactUsReasonSubCategory.fromMap(Map<String, dynamic> json) =>
      ContactUsReasonSubCategory(
        id: json['id'],
        subName: json['sub_name'],
        name: json['name'],
        orderidRequired: json['orderid_required'],
        commentBox: json['comment_box'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'sub_name': subName,
      'name': name,
      'orderid_required': orderidRequired,
      'comment_box': commentBox,
    };
    return data;
  }
}
