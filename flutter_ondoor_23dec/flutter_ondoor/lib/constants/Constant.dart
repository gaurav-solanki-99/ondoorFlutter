import 'package:flutter/services.dart';

import '../utils/colors.dart';

class Constants {
  static const String SELECT_LOCATION_HEADER = "SELECT_LOCATION_HEADER";
  static const String delivery_location_search_hint =
      "delivery_location_search_hint";
  static const String current_location_txt = "current_location_txt";
  static const String saved_address = "saved_address";
  static const String recent_address = "recent_address";
  static const String fcmToken = "fcmToken";
  static const String serverToken = "serverToken";
  static const String ADDRESS = "ADDRESS";
  static const String SELECTED_ADDRESS = "SELECTED_ADDRESS";
  static const String LOCALITY = "LOCALITY";
  static const String CURRENTLY_SERVING_CITY_TEXT =
      "CURRENTLY_SERVING_CITY_TEXT";
  static const String WMS_STORE_ID = "WMS_STORE_ID";
  static const String STORE_CODE = "STORE_CODE";
  static const String STORE_ID = "STORE_ID";
  static const String STORE_Name = "STORE_NAME";
  static const String LOCATION_ID = "LOCATION_ID";
  static const String LOCATION_NAME = "LOCATION_NAME";
  static const String LOCATION_LAT = "LOCATION_LAT";
  static const String LOCATION_LONG = "LOCATION_LONG";
  static const String SAVED_ADDRESS = "SAVED_ADDRESS";
  static const String ADDRESS_1 = "ADDRESS_1";
  static const String ADDRESS_2 = "ADDRESS_2";
  static const String AREA_DETAIL = "AREA_DETAIL";
  static const String SELECTED_LOCATION_LAT = "SELECTED_LOCATION_LAT";
  static const String SELECTED_LOCATION_LONG = "SELECTED_LOCATION_LONG";
  static const String SELECTED_ADDRESS_TYPE = "SELECTED_ADDRESS_TYPE";
  static const String SAVED_CITY = "SAVED_CITY";
  static const String SAVED_STATE = "SAVED_STATE";
  static const String SAVED_STATE_ID = "SAVED_STATE_ID";
  static const String SAVED_LANDMARK = "SAVED_LANDMARK";
  static const String ADDRESS_ID = "ADDRESS_ID";
  static const String SAVED_SUB_ADDRESS = "SAVED_SUB_ADDRESS";
  static const String SAVED_FLatNumberAddress = "SAVED_FLatNumberAddress";
  static const String PostalCode = "POSTAL_CODE";
  static const String locationupdate = "locationupdate";
  static const String SELECTED_TIME_SLOT = "SELECTED_TIME_SLOT";
  static const String SELECTED_DELIVERY_ADDRESS = "SELECTED_DELIVERY_ADDRESS";
  static const String SELECTED_DATE_SLOT = "SELECTED_DATE_SLOT";
  static const String OrderPlaceFlow = "ORDER_PLACE_FLOW";
  static const String OrderidForEditOrder = "ORDER_ID_FOR_EDIT_ORDER";

  static const API_KEY = "AIzaSyCy7V0h_4ZF2OS4AlV6s_faKRJE3AdVDWc";
  static const double MAP_ZOOM_LEVEL = 20;
  static const double Sizelagre = 16.0;
  static const double SizeSmall = 12.0;
  static const double Size_7 = 7.0;
  static const double Size_10 = 10.0;
  static const double Size_11 = 11.0;
  static const double Size_20 = 20.0;
  static const double SizeMidium = 14.0;
  static const double SizeButton = 15.0;
  static const double Size_18 = 18.0;
  static const double SizeExtralagre = 18.0;
  static const ruppessymbol = "₹ ";

  //SharedPrefrences Constants
  static const String sp_currently_served_txt = "currently_served_txt";
  static const String sp_currently_served_city_txt =
      "currently_served_city_txt";
  static const String sp_set_delivery_location_header_txt =
      "set_delivery_location_header_txt";
  static const String sp_no_of_recent_items = "no_of_recent_items";
  static const String sp_SHOW_LOCATION_RETRY_ERROR =
      "SHOW_LOCATION_RETRY_ERROR";

  static const String sp_subscribePopupHeading = "subscribePopupHeading";
  static const String sp_morningText = "morningText";
  static const String sp_eveningText = "eveningText";
  static const String sp_saveText = "saveText";
  static const String sp_cancelText = "cancelText";
  static const String sp_resetText = "resetText";
  static const String sp_selectAnyWeekDayForMorning =
      "selectAnyWeekDayForMorning";
  static const String sp_selectAnyWeekDayForEvening =
      "selectAnyWeekDayForEvening";
  static const String sp_SelectQuantityForMorning = "SelectQuantityForMorning";
  static const String sp_SelectQuantityForEvening = "SelectQuantityForEvening";
  static const String sp_selectAnyOptionToSave = "selectAnyOptionToSave";
  static const String sp_SHOW_MORNING_OPTION = "SHOW_MORNING_OPTION";
  static const String sp_SHOW_EVENING_OPTION = "SHOW_EVENING_OPTION";
  static const String sp_SUBSCRIPTION_ID = "SUBSCRIPTION_ID";
  static const String sp_SUBSCRIPTION_START_DATE = "SUBSCRIPTION_START_DATE";
  static const String sp_ADDON_ID = "ADDON_ID";
  static const String sp_SUBSCRIPTION_LOCATION_ID = "SUBSCRIPTION_LOCATION_ID";

  //subscription text
  static const String sp_SUBSCRIPTION_TEXT = "SUBSCRIPTION_TEXT";
  static const String sp_CREATE_SUBSCRIPTION_TEXT = "CREATE_SUBSCRIPTION_TEXT";
  static const String sp_MY_SUBSCRIPTION_TEXT = "MY_SUBSCRIPTION_TEXT";
  static const String sp_MY_SUBSCRIPTION_BOTTOM_TAB_TEXT =
      "MY_SUBSCRIPTION_BOTTOM_TAB_TEXT";
  static const String sp_MY_SUBSCRIPTION_BOTTOM_TAB_HISTORY_TEXT =
      "MY_SUBSCRIPTION_BOTTOM_TAB_HISTORY_TEXT";
  static const String sp_MY_SUBSCRIPTION_BOTTOM_TAB_RENEW_TEXT =
      "MY_SUBSCRIPTION_BOTTOM_TAB_RENEW_TEXT";
  static const String sp_MY_SUBSCRIPTION_HEADER_TITLE =
      "MY_SUBSCRIPTION_HEADER_TITLE";
  static const String sp_UNSUBSCRIBE_MESSAGE = "UNSUBSCRIBE_MESSAGE";
  static const String sp_ADD_ON_PAYMENT_MESSAGE = "ADD_ON_PAYMENT_MESSAGE";
  static const String sp_SUBSCRIPTION_DETAILS = "SUBSCRIPTION_DETAILS";
  static const String sp_ADDON_PRODUCTS = "ADDON_PRODUCTS";
  static const String sp_EDIT_SUBSCRIPTION = "EDIT_SUBSCRIPTION";
  static const String sp_ARE_YOU_SURE_YOU_WANT_TO_DELETE =
      "ARE_YOU_SURE_YOU_WANT_TO_DELETE";
  static const String sp_SELECT_DATE_ADDON_HEADING =
      "SELECT_DATE_ADDON_HEADING";
  static const String sp_DISABLE_DATE_MESSAGE = "DISABLE_DATE_MESSAGE";
  static const String sp_FINAL_BASKET_ADD_ON_HEADING =
      "FINAL_BASKET_ADD_ON_HEADING";
  static const String sp_FINAL_BASKET_ADD_ON_FOOTER =
      "FINAL_BASKET_ADD_ON_FOOTER";

  static const String sp_CustomerId = "CUSTOMER_ID";
  static const String sp_notificationdata = "NotificationDate";
  static const String sp_CustomerName = "CUSTOMER_NAME";
  static const String sp_FirstNAME = "FIRST_NAME";
  static const String sp_LastName = "LAST_NAME";
  static const String sp_Company_Name = "Company_Name";
  static const String sp_MOBILE_NO = "MOBILE_NO";
  static const String sp_EMAIL = "EMAIL";
  static const String sp_TOKEN = "TOKEN";
  static const String sp_CREDIT_PROGRAM = "CREDIT_PROGRAM";
  static const String sp_AccessTOEKN = "ACCESS_TOKEN";
  static const String sp_TOKENTYPE = "TOKEN_TYPE";
  static const String sp_TOKENEXPIREIN = "TOKEN_EXPIRE_IN";
  static const String sp_NotificationCount = "sp_NotificationCount";

  static const String sp_fromRoute = "fromRoute";
  static const String sp_reorder_json = "fromRoute";
  static const String sp_VerifyRoute = "VerifyRoute";
  static const String sp_searchtext = "SearchText";
  static const String sp_searchHistory = "SearchHistory";
  static const String sp_isGoogleSpeechActive = "GoogleSpeechActive";
  static const String sp_homepageproducts = "homepageproducts";
  static const String sp_bannerProductTitle = "BannerProductTitle";
  static const String isRatedonPlayStore = "isRatedonPlayStore";
  static const String selectedTimeSlot = "selectedTimeSlot";
  static const String selectedDateSlot = "selectedDateSlot";
  static const String selected_date_Text = "selected_date_Text";
  static const String selected_payment_Method = "selected_payment_Method";

  static var notificationdata = "";
  static var tv_email = "";
  static var tv_name = "";
  static var tv_number = "";
  static String show_notification_bach = "show_notification_bach";
}
