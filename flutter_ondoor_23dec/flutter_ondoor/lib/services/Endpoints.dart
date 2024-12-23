// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

class Endpoints {
  // Base URLs

  static const String BASE_URL = "https://app16.ondoor.com/";
  static const String AppVersionCode = "79";
  // static const String BASE_URL = "http://ondoorapp.tekzee.in/";
  // static const String BASE_URL = "http://ec2-52-221-219-180.ap-southeast-1.compute.amazonaws.com/";
/*  */ /*kReleaseMode
      ?*/ /*
      "http://ondoorapp.tekzee.in/" */ /*:

       "https://app16.ondoor.com/"*/ /*;*/
  //Feeds
  static const String Feed2 = "index.php?route=feed2/";
  static const String Feed3 = "index.php?route=feed3/";
  static const String Feed4 = "index.php?route=feed4/";
  static const String Feed5 = "index.php?route=feed5/";
  static const String Feed6 = "index.php?route=feed6/";

  //Endpoints
  // static const String getNewCategory = "${Feed4}common_api/getNewCategoryDynamicVF1";
  /* static const String getNewCategory = "feed6/getCategory";
  static const String getCategoriesItem = "${Feed5}common_api/getCategoriesItemFV1";
  static const String validateApp = "${Feed5}common_api/validateAppVersion&version=";
  static const String checkCreditRequestEndpoint = "index.php?route=feed4/credit_program/checkCreditrequestWithoutLogin";
  static const String getCocoCodebyLatLngEndpoint = "index.php?route=feed5/common_api/getCocoCodeByLatLng";
  static const String getSeachProductV1 = "feed5/getSearchProductsV1";
  static const String getBannerProducts = "feed5/getSearchBannerProductsByTag";
  static const String getFeaturedProduct = "app16/$Feed4/common_api/getFeaturedProductListFV1";
  static const String checkCreditRequestwithoutLogin = "${Feed4}credit_program/checkCreditrequestWithoutLogin";
  static const String checkCreditRequest = "${Feed4}credit_program/checkCreditrequest";
  static const String registerduser = "${Feed3}user_api/registerV1";
  static const String verifyotp = "${Feed2}user_api/verify_token";
  static const String getToken = "${Feed2}user_api/gettoken&grant_type=client_credentials";
  static const String shippingCharges = "${Feed3}pre_order/shipping_chargev2";
  static const String productValidation = "${Feed5}pre_order/ProductValidation";
  static const String locationProductValidation = "${Feed5}pre_order/LocationProductValidation";
  static const String getOrderbyCustomerId = "${Feed5}post_order/getOrderByCustomerIDFV1";
  static const String getProfile = "${Feed2}user_api/getProfile";
  static const String rewardSummary = "${Feed2}reward/CustomerRewardSummary";
  static const String getshoppingList = "${Feed3}shoppinglist/getshoppinglist";
  static const String addshoppingList = "${Feed3}shoppinglist/addshoppinglist";
  static const String editProfile = "${Feed3}user_api/editProfileNew";
  static const String notificationList = "${Feed3}common_api/GeneralNotification";
  static const String reorder = "${Feed4}post_order/getReorderByOrderId";
  static const String renameShoppingList = "${Feed3}shoppinglist/renameshoppinglist";
  static const String deleteShoppingList = "${Feed3}shoppinglist/deleteshoppinglist";
  static const String productFromShoppingList = "${Feed3}shoppinglist/getProductFromShoppingList";
  static const String getOrderByOrderIDExtendedFV1 = "${Feed3}order_apiv2/getOrderByOrderIDExtendedFV1";
  static const String cocoByLatLng = "${Feed5}common_api/getCocoCodeByLatLng";
  static const String getOrderonPhone = "${Feed5}common_api/getOrderOnPhone";
  static const String getContactUs = "${Feed4}common_api/getContactUSReasonV2";
  static const String getPage = "${Feed3}common_api/getPage";
  static const String contactUs = "${Feed4}common_api/contactUsV3";
  static const String getLatestOrder = "ondoor_app/${Feed4}common_api/getLatestOrdersV3";
  static const String getCities = "${Feed5}common_api/getCity";
  static const String listAddress = "${Feed5}address_api/listAddressFV1";
  static const String deleteAddress = "${Feed2}address_api/deleteAddress";
  static const String addAddress = "${Feed5}address_api/addAddressFV1";
  static const String getTimeSlot = "${Feed3}timeslot_api/getTimeSlotsNewV1";
  static const String getFilter = "${Feed3}common_api/getfilter";
  static const String getFilterData = "${Feed3}common_api/getfilterdata";
  static const String getSimilarProducts = "${Feed4}common_api/getSimilarProductByCategaryFV1";
  static const String beforeYourCheckout = "${Feed4}common_api/beforeYourCheckout";
  static const String getProductPagination = "${Feed4}common_api/getProductPagination";
  static const String getTopSellingProductHomeScreenFV1 = "${Feed6}common_api/homeScreenViewAPI";
  static const String addNotification = "${Feed3}common_api/addNotification";
  static const String saveOrdertoDataBase = "${Feed6}pre_order/saveOrderToDatabase";
  static const String cancelOrderbyOrderId = "${Feed6}order_apiv2/cancelOrderByOrderId";
  static const String getOrderByOrderId = "${Feed5}post_order/getOrderByOrderId";*/

  // static const String getNewCategory = "${Feed6}common_api/getNewCategoryDynamicVF1";
  static const String getNewCategory = "feed6/getCategory";
  static const String getCategoriesItem =
      "${Feed6}common_api/getCategoriesItemFV1";
  static const String validateApp =
      "${Feed6}common_api/validateAppVersion&version=";
  static const String checkCreditRequestEndpoint =
      "index.php?route=feed4/credit_program/checkCreditrequestWithoutLogin";
  static const String getCocoCodebyLatLngEndpoint =
      "index.php?route=feed5/common_api/getCocoCodeByLatLng";
  static const String getSeachProductV1 = "feed6/getSearchProductsV1";
  static const String getEditSearchProduct = "feed6/getEditSearchProduct";
  static const String getBannerProducts = "feed6/getSearchBannerProductsByTag";
  static const String getFeaturedProduct =
      "$Feed6/common_api/getFeaturedProductListFV1";
  static const String checkCreditRequestwithoutLogin =
      "${Feed6}credit_program/checkCreditrequestWithoutLogin";
  static const String checkCreditRequest =
      "${Feed6}credit_program/checkCreditrequest";
  static const String registerduser = "${Feed6}user_api/registerV1";
  static const String verifyotp = "${Feed6}user_api/verify_token";
  static const String getToken =
      "${Feed6}user_api/gettoken&grant_type=client_credentials";
  static const String shippingCharges = "${Feed6}pre_order/shipping_chargev2";
  static const String productValidation = "${Feed6}pre_order/ProductValidation";
  static const String locationProductValidation =
      "${Feed6}pre_order/LocationProductValidation";
  static const String getOrderbyCustomerId =
      "${Feed6}post_order/getOrderByCustomerIDFV1";
  static const String getProfile = "${Feed6}user_api/getProfile";
  static const String rewardSummary = "${Feed6}reward/CustomerRewardSummary";
  static const String getshoppingList = "${Feed6}shoppinglist/getshoppinglist";
  static const String addshoppingList = "${Feed6}shoppinglist/addshoppinglist";
  static const String editProfile = "${Feed6}user_api/editProfileNew";
  static const String notificationList =
      "${Feed6}common_api/GeneralNotification";
  static const String reorder = "${Feed6}post_order/getReorderByOrderId";
  static const String renameShoppingList =
      "${Feed6}shoppinglist/renameshoppinglist";
  static const String deleteShoppingList =
      "${Feed6}shoppinglist/deleteshoppinglist";
  static const String productFromShoppingList =
      "${Feed6}shoppinglist/getProductFromShoppingList";
  static const String getCategoriesItemV1 = "feed6/getCategoriesItemV1";
  static const String orderByOrderID =
      "${Feed6}order_apiv2/getOrderByOrderIDExtendedFV1";
  static const String cocoByLatLng = "${Feed6}common_api/getCocoCodeByLatLng";
  static const String getOrderonPhone = "${Feed6}common_api/getOrderOnPhone";
  static const String getContactUs = "${Feed6}common_api/getContactUSReasonV2";
  static const String getPage = "${Feed6}common_api/getPage";
  static const String contactUs = "${Feed6}common_api/contactUsV3";
  static const String getLatestOrder =
      "ondoor_app/${Feed6}common_api/getLatestOrdersV3";
  static const String getCities = "${Feed6}common_api/getCity";
  static const String listAddress = "${Feed6}address_api/listAddressFV1";
  static const String deleteAddress = "${Feed6}address_api/deleteAddress";
  static const String addAddress = "${Feed6}address_api/addAddressFV1";
  static const String getTimeSlot = "${Feed6}timeslot_api/getTimeSlotsNewV1";
  static const String getTimeSlotApi = "${Feed6}timeslot_api/getTimeSlotsNew";
  static const String getFilter = "${Feed6}common_api/getfilter";
  static const String getFilterData = "${Feed6}common_api/getfilterdata";
  static const String getSimilarProducts =
      "${Feed6}common_api/getSimilarProductByCategaryFV2";
  static const String beforeYourCheckout =
      "${Feed6}common_api/beforeYourCheckoutV1";
  static const String getProductPagination =
      "${Feed6}common_api/getProductPaginationV1";
  static const String getTopSellingProductHomeScreenFV1 =
      "${Feed6}common_api/homeScreenViewAPIV1";
  static const String addNotification = "${Feed6}common_api/addNotification";
  static const String saveOrdertoDataBase =
      "${Feed6}pre_order/saveOrderToDatabase";
  static const String getOrderByOrderId =
      "${Feed6}post_order/getOrderByOrderId";
  static const String cancelOrderbyOrderId =
      "${Feed6}order_apiv2/cancelOrderByOrderId";
  static const String getOrderByOrderIDExtendedFV1 =
      "${Feed6}order_apiv2/getOrderByOrderIDExtendedFV1";
  static const String editOrderByCustomer =
      "${Feed6}post_order/editorderbycustomer";
  // index.php?route=feed3/post_order/changeOrderDeliverySlot
  static const String changeDeliverySlot =
      "${Feed6}post_order/changeOrderDeliverySlot";
  static const String PAYTM_CHECkSUM_URL = "paytm/generateChecksumFV1.php";
  static const String GENERATE_CHECkSUM_UPI = "paytm/generateChecksumupi.php";

  static const String generateChecksumupi = "paytm/generateChecksumupi.php";
  static const String checkOnlinePayment =
      "${Feed3}post_order/checkOnlinePayment";
}
