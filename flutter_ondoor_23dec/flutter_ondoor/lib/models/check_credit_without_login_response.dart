class CheckCreditWithoutLoginResponse {
  int? creditprogram;
  int? showWallet;
  int? rewardEnableDisable;
  String? searchRequestTime;
  int? logEnable;
  Offer? offer;
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

  CheckCreditWithoutLoginResponse(
      {this.creditprogram,
      this.showWallet,
      this.rewardEnableDisable,
      this.searchRequestTime,
      this.logEnable,
      this.offer,
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
      this.showEveningOption});

  CheckCreditWithoutLoginResponse.fromJson(Map<String, dynamic> json) {
    creditprogram = json['creditprogram'] ?? 0;
    showWallet = json['show_wallet'] ?? 0;
    rewardEnableDisable = json['reward_enable_disable'] ?? 0;
    searchRequestTime = json['search_request_time'] ?? "";
    logEnable = json['log_enable'] ?? 0;
    offer = json['offer'] != null ? Offer.fromJson(json['offer']) : Offer();
    tambolaObject = json['tambola_object'] != null
        ? TambolaObject.fromJson(json['tambola_object'])
        : TambolaObject();
    success = json['success'] ?? "";
    showComplaintHistory = json['show_complaint_history'] ?? 0;
    offerPopupDuration = json['offer_popup_duration'] ?? "";
    changeMobileFunctionality = json['change_mobile_functionality'] ?? 0;
    linkMembershipCardEnableDisable =
        json['link_membership_card_enable_disable'] ?? 0;
    isPopupBlock = json['is_popup_block'] ?? false;
    isSubscriptionEnabled = json['is_subscription_enabled'] ?? false;
    subscritionText = json['subscrition_text'] ?? "";
    createSubscritionText = json['create_subscrition_text'] ?? "";
    mySubscritionText = json['my_subscrition_text'] ?? "";
    mySubscritionBottomTabText = json['my_subscrition_bottom_tab_text'] ?? "";
    mySubscritionBottomTabHistoryText =
        json['my_subscrition_bottom_tab_history_text'] ?? "";
    mySubscritionBottomTabRenewText =
        json['my_subscrition_bottom_tab_renew_text'] ?? "";
    mySubscriptionHeaderTitle = json['my_subscription_header_title'] ?? "";
    addOnPaymentMessage = json['add_on_payment_message'] ?? "";
    subscriptionDetails = json['subscription_details'] ?? "";
    addonProducts = json['addon_products'] ?? "";
    editSubscription = json['edit_subscription'] ?? "";
    deleteMessage = json['delete_message'] ?? "";
    selectDateAddonHeading = json['select_date_addon_heading'] ?? "";
    disableDateMessage = json['disable_date_message'] ?? "";
    finalBasketAddOnHeading = json['final_basket_add_on_heading'] ?? "";
    finalBasketAddOnFooter = json['final_basket_add_on_footer'] ?? "";
    productListHeading = json['product_list_heading'] ?? "";
    selectStartDate = json['select_start_date'] ?? "";
    subscribeAnyProductMessage = json['subscribe_any_product_message'] ?? "";
    subscribePopupHeading = json['subscribe_popup_heading'] ?? "";
    morningText = json['morning_text'] ?? "";
    eveningText = json['evening_text'] ?? "";
    saveText = json['save_text'] ?? "";
    cancelText = json['cancel_text'] ?? "";
    resetText = json['reset_text'] ?? "";
    selectAnyWeekdayForMorning = json['select_any_weekday_for_morning'] ?? "";
    selectAnyWeekdayForEvening = json['select_any_weekday_for_evening'] ?? "";
    selectQuantityForMorning = json['select_quantity_for_morning'] ?? "";
    selectQuantityForEvening = json['select_quantity_for_evening'] ?? "";
    selectAnyOptionToSave = json['select_any_option_to_save'] ?? "";
    showMorningOption = json['show_morning_option'] ?? false;
    showEveningOption = json['show_evening_option'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['creditprogram'] = creditprogram;
    data['show_wallet'] = showWallet;
    data['reward_enable_disable'] = rewardEnableDisable;
    data['search_request_time'] = searchRequestTime;
    data['log_enable'] = logEnable;
    if (offer != null) {
      data['offer'] = offer!.toJson();
    }
    if (tambolaObject != null) {
      data['tambola_object'] = tambolaObject!.toJson();
    }
    data['success'] = success;
    data['show_complaint_history'] = showComplaintHistory;
    data['offer_popup_duration'] = offerPopupDuration;
    data['change_mobile_functionality'] = changeMobileFunctionality;
    data['link_membership_card_enable_disable'] =
        linkMembershipCardEnableDisable;
    data['is_popup_block'] = isPopupBlock;
    data['is_subscription_enabled'] = isSubscriptionEnabled;
    data['subscrition_text'] = subscritionText;
    data['create_subscrition_text'] = createSubscritionText;
    data['my_subscrition_text'] = mySubscritionText;
    data['my_subscrition_bottom_tab_text'] = mySubscritionBottomTabText;
    data['my_subscrition_bottom_tab_history_text'] =
        mySubscritionBottomTabHistoryText;
    data['my_subscrition_bottom_tab_renew_text'] =
        mySubscritionBottomTabRenewText;
    data['my_subscription_header_title'] = mySubscriptionHeaderTitle;
    data['add_on_payment_message'] = addOnPaymentMessage;
    data['subscription_details'] = subscriptionDetails;
    data['addon_products'] = addonProducts;
    data['edit_subscription'] = editSubscription;
    data['delete_message'] = deleteMessage;
    data['select_date_addon_heading'] = selectDateAddonHeading;
    data['disable_date_message'] = disableDateMessage;
    data['final_basket_add_on_heading'] = finalBasketAddOnHeading;
    data['final_basket_add_on_footer'] = finalBasketAddOnFooter;
    data['product_list_heading'] = productListHeading;
    data['select_start_date'] = selectStartDate;
    data['subscribe_any_product_message'] = subscribeAnyProductMessage;
    data['subscribe_popup_heading'] = subscribePopupHeading;
    data['morning_text'] = morningText;
    data['evening_text'] = eveningText;
    data['save_text'] = saveText;
    data['cancel_text'] = cancelText;
    data['reset_text'] = resetText;
    data['select_any_weekday_for_morning'] = selectAnyWeekdayForMorning;
    data['select_any_weekday_for_evening'] = selectAnyWeekdayForEvening;
    data['select_quantity_for_morning'] = selectQuantityForMorning;
    data['select_quantity_for_evening'] = selectQuantityForEvening;
    data['select_any_option_to_save'] = selectAnyOptionToSave;
    data['show_morning_option'] = showMorningOption;
    data['show_evening_option'] = showEveningOption;
    return data;
  }
}

class Offer {
  dynamic freeDeliveryAmount;
  // Null? offerList;
  int? isOffer;

  Offer({this.freeDeliveryAmount, /*this.offerList, */ this.isOffer});

  Offer.fromJson(Map<String, dynamic> json) {
    freeDeliveryAmount = json['free_delivery_amount'] ?? 0;
    // offerList = json['offer_list'];
    isOffer = json['is_offer'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['free_delivery_amount'] = freeDeliveryAmount;
    // data['offer_list'] = offerList;
    data['is_offer'] = isOffer;
    return data;
  }
}

class TambolaObject {
  bool? isTambolaVisible;
  String? tambolaText;
  String? tambolaHeaderText;
  String? tambolaUrl;
  String? imgTambola;

  TambolaObject(
      {this.isTambolaVisible,
      this.tambolaText,
      this.tambolaHeaderText,
      this.tambolaUrl,
      this.imgTambola});

  TambolaObject.fromJson(Map<String, dynamic> json) {
    isTambolaVisible = json['is_tambola_visible'] ?? false;
    tambolaText = json['tambola_text'] ?? "";
    tambolaHeaderText = json['tambola_header_text'] ?? "";
    tambolaUrl = json['tambola_url'] ?? "";
    imgTambola = json['img_tambola'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_tambola_visible'] = isTambolaVisible;
    data['tambola_text'] = tambolaText;
    data['tambola_header_text'] = tambolaHeaderText;
    data['tambola_url'] = tambolaUrl;
    data['img_tambola'] = imgTambola;
    return data;
  }
}
