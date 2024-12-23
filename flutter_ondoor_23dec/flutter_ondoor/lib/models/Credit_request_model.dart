import 'dart:convert';

class CreditRequestModel {
  int? creditprogram;
  int? showWallet;
  int? rewardEnableDisable;
  String? searchRequestTime;
  int? logEnable;
  Offer? offer;
  SmartOffer? smartOffer;
  TambolaObject? tambolaObject;
  bool? success;
  int? showComplaintHistory;
  String? offerPopupDuration;
  int? changeMobileFunctionality;
  int? linkMembershipCardEnableDisable;
  bool? isPopupBlock;
  bool? isSubscriptionEnabled;
  String? subscritionText;
  String? createSubscritionText;
  String? mySubscritionText;
  String? mySubscritionBottomTabText;
  String? mySubscritionBottomTabHistoryText;
  String? mySubscritionBottomTabRenewText;
  String? mySubscriptionHeaderTitle;
  String? addOnPaymentMessage;
  String? subscriptionDetails;
  String? addonProducts;
  String? editSubscription;
  String? deleteMessage;
  String? selectDateAddonHeading;
  String? disableDateMessage;
  String? finalBasketAddOnHeading;
  String? finalBasketAddOnFooter;
  String? productListHeading;
  String? selectStartDate;
  String? subscribeAnyProductMessage;
  String? subscribePopupHeading;
  String? morningText;
  String? eveningText;
  String? saveText;
  String? cancelText;
  String? resetText;
  String? selectAnyWeekdayForMorning;
  String? selectAnyWeekdayForEvening;
  String? selectQuantityForMorning;
  String? selectQuantityForEvening;
  String? selectAnyOptionToSave;
  bool? showMorningOption;
  bool? showEveningOption;
  String? unsubscribe_message;

  CreditRequestModel({
    this.creditprogram,
    this.showWallet,
    this.rewardEnableDisable,
    this.searchRequestTime,
    this.logEnable,
    this.offer,
    this.smartOffer,
    this.tambolaObject,
    this.success,
    this.showComplaintHistory,
    this.offerPopupDuration,
    this.changeMobileFunctionality,
    this.linkMembershipCardEnableDisable,
    this.isPopupBlock,
    this.isSubscriptionEnabled,
    this.subscritionText,
    this.createSubscritionText,
    this.mySubscritionText,
    this.mySubscritionBottomTabText,
    this.mySubscritionBottomTabHistoryText,
    this.mySubscritionBottomTabRenewText,
    this.mySubscriptionHeaderTitle,
    this.addOnPaymentMessage,
    this.subscriptionDetails,
    this.addonProducts,
    this.editSubscription,
    this.deleteMessage,
    this.selectDateAddonHeading,
    this.disableDateMessage,
    this.finalBasketAddOnHeading,
    this.finalBasketAddOnFooter,
    this.productListHeading,
    this.selectStartDate,
    this.subscribeAnyProductMessage,
    this.subscribePopupHeading,
    this.morningText,
    this.eveningText,
    this.saveText,
    this.cancelText,
    this.resetText,
    this.selectAnyWeekdayForMorning,
    this.selectAnyWeekdayForEvening,
    this.selectQuantityForMorning,
    this.selectQuantityForEvening,
    this.selectAnyOptionToSave,
    this.showMorningOption,
    this.showEveningOption,
    this.unsubscribe_message
  });

  factory CreditRequestModel.fromJson(String str) => CreditRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CreditRequestModel.fromMap(Map<String, dynamic> json) => CreditRequestModel(
    creditprogram: json["creditprogram"],
    showWallet: json["show_wallet"],
    rewardEnableDisable: json["reward_enable_disable"],
    searchRequestTime: json["search_request_time"]??"",
    logEnable: json["log_enable"],
    offer: json["offer"] == null ? null : Offer.fromMap(json["offer"]),
    smartOffer: json["smart_offer"] == null ? null : SmartOffer.fromMap(json["smart_offer"]),
    tambolaObject: json["tambola_object"] == null ? null : TambolaObject.fromMap(json["tambola_object"]),
    success: json["success"],
    showComplaintHistory: json["show_complaint_history"],
    offerPopupDuration: json["offer_popup_duration"]??"",
    changeMobileFunctionality: json["change_mobile_functionality"],
    linkMembershipCardEnableDisable: json["link_membership_card_enable_disable"],
    isPopupBlock: json["is_popup_block"],
    isSubscriptionEnabled: json["is_subscription_enabled"],
    subscritionText: json["subscrition_text"]??"",
    createSubscritionText: json["create_subscrition_text"]??"",
    mySubscritionText: json["my_subscrition_text"]??"",
    mySubscritionBottomTabText: json["my_subscrition_bottom_tab_text"]??"",
    mySubscritionBottomTabHistoryText: json["my_subscrition_bottom_tab_history_text"]??"",
    mySubscritionBottomTabRenewText: json["my_subscrition_bottom_tab_renew_text"]??"",
    mySubscriptionHeaderTitle: json["my_subscription_header_title"]??"",
    addOnPaymentMessage: json["add_on_payment_message"]??"",
    subscriptionDetails: json["subscription_details"]??"",
    addonProducts: json["addon_products"]??"",
    editSubscription: json["edit_subscription"]??"",
    deleteMessage: json["delete_message"]??"",
    selectDateAddonHeading: json["select_date_addon_heading"]??"",
    disableDateMessage: json["disable_date_message"]??"",
    finalBasketAddOnHeading: json["final_basket_add_on_heading"]??"",
    finalBasketAddOnFooter: json["final_basket_add_on_footer"]??"",
    productListHeading: json["product_list_heading"]??"",
    selectStartDate: json["select_start_date"]??"",
    subscribeAnyProductMessage: json["subscribe_any_product_message"]??"",
    subscribePopupHeading: json["subscribe_popup_heading"]??"",
    morningText: json["morning_text"]??"",
    eveningText: json["evening_text"]??"",
    saveText: json["save_text"]??"",
    cancelText: json["cancel_text"]??"",
    resetText: json["reset_text"]??"",
    selectAnyWeekdayForMorning: json["select_any_weekday_for_morning"]??"",
    selectAnyWeekdayForEvening: json["select_any_weekday_for_evening"]??"",
    selectQuantityForMorning: json["select_quantity_for_morning"]??"",
    selectQuantityForEvening: json["select_quantity_for_evening"]??"",
    selectAnyOptionToSave: json["select_any_option_to_save"]??"",
    showMorningOption: json["show_morning_option"],
    showEveningOption: json["show_evening_option"],
    unsubscribe_message: json["unsubscribe_message"]??"",
  );

  Map<String, dynamic> toMap() => {
    "creditprogram": creditprogram,
    "show_wallet": showWallet,
    "reward_enable_disable": rewardEnableDisable,
    "search_request_time": searchRequestTime,
    "log_enable": logEnable,
    "offer": offer?.toMap(),
    "smart_offer": smartOffer?.toMap(),
    "tambola_object": tambolaObject?.toMap(),
    "success": success,
    "show_complaint_history": showComplaintHistory,
    "offer_popup_duration": offerPopupDuration,
    "change_mobile_functionality": changeMobileFunctionality,
    "link_membership_card_enable_disable": linkMembershipCardEnableDisable,
    "is_popup_block": isPopupBlock,
    "is_subscription_enabled": isSubscriptionEnabled,
    "subscrition_text": subscritionText,
    "create_subscrition_text": createSubscritionText,
    "my_subscrition_text": mySubscritionText,
    "my_subscrition_bottom_tab_text": mySubscritionBottomTabText,
    "my_subscrition_bottom_tab_history_text": mySubscritionBottomTabHistoryText,
    "my_subscrition_bottom_tab_renew_text": mySubscritionBottomTabRenewText,
    "my_subscription_header_title": mySubscriptionHeaderTitle,
    "add_on_payment_message": addOnPaymentMessage,
    "subscription_details": subscriptionDetails,
    "addon_products": addonProducts,
    "edit_subscription": editSubscription,
    "delete_message": deleteMessage,
    "select_date_addon_heading": selectDateAddonHeading,
    "disable_date_message": disableDateMessage,
    "final_basket_add_on_heading": finalBasketAddOnHeading,
    "final_basket_add_on_footer": finalBasketAddOnFooter,
    "product_list_heading": productListHeading,
    "select_start_date": selectStartDate,
    "subscribe_any_product_message": subscribeAnyProductMessage,
    "subscribe_popup_heading": subscribePopupHeading,
    "morning_text": morningText,
    "evening_text": eveningText,
    "save_text": saveText,
    "cancel_text": cancelText,
    "reset_text": resetText,
    "select_any_weekday_for_morning": selectAnyWeekdayForMorning,
    "select_any_weekday_for_evening": selectAnyWeekdayForEvening,
    "select_quantity_for_morning": selectQuantityForMorning,
    "select_quantity_for_evening": selectQuantityForEvening,
    "select_any_option_to_save": selectAnyOptionToSave,
    "show_morning_option": showMorningOption,
    "show_evening_option": showEveningOption,
    "unsubscribe_message": unsubscribe_message,
  };
}

class Offer {
  String? freeDeliveryAmount;
  dynamic offerList;
  int? isOffer;

  Offer({
    this.freeDeliveryAmount,
    this.offerList,
    this.isOffer,
  });

  factory Offer.fromJson(String str) => Offer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Offer.fromMap(Map<String, dynamic> json) => Offer(
    freeDeliveryAmount: json["free_delivery_amount"],
    offerList: json["offer_list"],
    isOffer: json["is_offer"],
  );

  Map<String, dynamic> toMap() => {
    "free_delivery_amount": freeDeliveryAmount,
    "offer_list": offerList,
    "is_offer": isOffer,
  };
}

class SmartOffer {
  SmartOfferList? smartOfferList;
  int? isOffer;

  SmartOffer({
    this.smartOfferList,
    this.isOffer,
  });

  factory SmartOffer.fromJson(String str) => SmartOffer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SmartOffer.fromMap(Map<String, dynamic> json) => SmartOffer(
    smartOfferList: json["smart_offer_list"] == null ? null : SmartOfferList.fromMap(json["smart_offer_list"]),
    isOffer: json["is_offer"],
  );

  Map<String, dynamic> toMap() => {
    "smart_offer_list": smartOfferList?.toMap(),
    "is_offer": isOffer,
  };
}

class SmartOfferList {
  String? isAdword;
  String? offerTitle;
  String? heading;
  String? subHeading;
  String? imageUrl;
  String? footer;
  String? subFooter;
  Metadata? metadata;

  SmartOfferList({
    this.isAdword,
    this.offerTitle,
    this.heading,
    this.subHeading,
    this.imageUrl,
    this.footer,
    this.subFooter,
    this.metadata,
  });

  factory SmartOfferList.fromJson(String str) => SmartOfferList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SmartOfferList.fromMap(Map<String, dynamic> json) => SmartOfferList(
    isAdword: json["is_adword"],
    offerTitle: json["offer_title"],
    heading: json["heading"],
    subHeading: json["sub_heading"],
    imageUrl: json["image_url"],
    footer: json["footer"],
    subFooter: json["sub_footer"],
    metadata: json["metadata"] == null ? null : Metadata.fromMap(json["metadata"]),
  );

  Map<String, dynamic> toMap() => {
    "is_adword": isAdword,
    "offer_title": offerTitle,
    "heading": heading,
    "sub_heading": subHeading,
    "image_url": imageUrl,
    "footer": footer,
    "sub_footer": subFooter,
    "metadata": metadata?.toMap(),
  };
}

class Metadata {
  String? key;
  String? value;
  String? name;
  String? weburl;

  Metadata({
    this.key,
    this.value,
    this.name,
    this.weburl,
  });

  factory Metadata.fromJson(String str) => Metadata.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Metadata.fromMap(Map<String, dynamic> json) => Metadata(
    key: json["key"],
    value: json["value"],
    name: json["name"],
    weburl: json["weburl"],
  );

  Map<String, dynamic> toMap() => {
    "key": key,
    "value": value,
    "name": name,
    "weburl": weburl,
  };
}

class TambolaObject {
  bool? isTambolaVisible;
  String? tambolaText;
  String? tambolaHeaderText;
  String? tambolaUrl;
  String? imgTambola;

  TambolaObject({
    this.isTambolaVisible,
    this.tambolaText,
    this.tambolaHeaderText,
    this.tambolaUrl,
    this.imgTambola,
  });

  factory TambolaObject.fromJson(String str) => TambolaObject.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TambolaObject.fromMap(Map<String, dynamic> json) => TambolaObject(
    isTambolaVisible: json["is_tambola_visible"],
    tambolaText: json["tambola_text"],
    tambolaHeaderText: json["tambola_header_text"],
    tambolaUrl: json["tambola_url"],
    imgTambola: json["img_tambola"],
  );

  Map<String, dynamic> toMap() => {
    "is_tambola_visible": isTambolaVisible,
    "tambola_text": tambolaText,
    "tambola_header_text": tambolaHeaderText,
    "tambola_url": tambolaUrl,
    "img_tambola": imgTambola,
  };
}
